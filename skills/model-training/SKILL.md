---
name: model-training
description: ML model training, evaluation, hyperparameter tuning, and experiment tracking workflows. Use when training scikit-learn, XGBoost, LightGBM, or HuggingFace models, running cross-validation, tuning hyperparameters, or comparing experiments.
allowed-tools: Bash, BashOutput, Read, Write, Glob, Grep
---

# Model Training

Workflows for training, evaluating, and tracking ML experiments. Covers classical ML and HuggingFace fine-tuning.

## When to Activate This Skill

Activate this skill when:
- Training or evaluating ML models
- Running cross-validation or hyperparameter tuning
- Comparing model performance across experiments
- Fine-tuning HuggingFace transformers
- Setting up experiment tracking and logging

## Experiment Structure

Organize every experiment consistently:

```
experiments/
  <experiment-name>/
    config.json          # Hyperparameters, data paths, random seed
    train.py             # Training script
    evaluate.py          # Evaluation script
    results/
      metrics.json       # Final metrics
      confusion_matrix.png
      feature_importances.png
    models/
      model.pkl          # or model directory for HuggingFace
    logs/
      training.log
```

### Config Standard

```python
from dataclasses import dataclass, asdict
import json

@dataclass
class ExperimentConfig:
    experiment_name: str
    random_seed: int = 42
    test_size: float = 0.2
    model_type: str = "xgboost"
    target_column: str = "label"
    data_path: str = "data/processed/features.parquet"
    model_params: dict = None

    def save(self, path: str) -> None:
        with open(path, 'w') as f:
            json.dump(asdict(self), f, indent=2)

    @classmethod
    def load(cls, path: str) -> 'ExperimentConfig':
        with open(path) as f:
            return cls(**json.load(f))
```

## Classical ML Training

### Baseline Model (Always Start Here)

```python
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
import numpy as np

def train_baseline(X, y, random_seed: int = 42) -> dict:
    """Train baseline models with cross-validation."""
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=random_seed)

    baselines = {
        'logistic_regression': LogisticRegression(max_iter=1000, random_state=random_seed),
        'random_forest': RandomForestClassifier(n_estimators=100, random_state=random_seed),
    }

    results = {}
    for name, model in baselines.items():
        scores = cross_val_score(model, X, y, cv=cv, scoring='f1_weighted')
        results[name] = {
            'mean_f1': float(np.mean(scores)),
            'std_f1': float(np.std(scores)),
            'scores': scores.tolist(),
        }
        print(f"{name}: F1={np.mean(scores):.4f} (+/- {np.std(scores):.4f})")

    return results
```

### XGBoost / LightGBM

```python
import xgboost as xgb
import lightgbm as lgb

def train_xgboost(X_train, y_train, X_val, y_val, params: dict = None) -> xgb.XGBClassifier:
    """Train XGBoost with early stopping."""
    default_params = {
        'n_estimators': 1000,
        'max_depth': 6,
        'learning_rate': 0.1,
        'subsample': 0.8,
        'colsample_bytree': 0.8,
        'random_state': 42,
        'eval_metric': 'logloss',
        'early_stopping_rounds': 50,
    }
    if params:
        default_params.update(params)

    model = xgb.XGBClassifier(**default_params)
    model.fit(X_train, y_train, eval_set=[(X_val, y_val)], verbose=False)
    print(f"Best iteration: {model.best_iteration}")
    return model

def train_lightgbm(X_train, y_train, X_val, y_val, params: dict = None) -> lgb.LGBMClassifier:
    """Train LightGBM with early stopping."""
    default_params = {
        'n_estimators': 1000,
        'max_depth': -1,
        'learning_rate': 0.1,
        'num_leaves': 31,
        'subsample': 0.8,
        'colsample_bytree': 0.8,
        'random_state': 42,
    }
    if params:
        default_params.update(params)

    model = lgb.LGBMClassifier(**default_params)
    model.fit(
        X_train, y_train,
        eval_set=[(X_val, y_val)],
        callbacks=[lgb.early_stopping(50), lgb.log_evaluation(0)],
    )
    return model
```

### Hyperparameter Tuning

```python
from sklearn.model_selection import RandomizedSearchCV, StratifiedKFold
from scipy.stats import randint, uniform

def tune_xgboost(X, y, n_iter: int = 50, random_seed: int = 42) -> dict:
    """Randomized hyperparameter search for XGBoost."""
    param_distributions = {
        'max_depth': randint(3, 10),
        'learning_rate': uniform(0.01, 0.3),
        'n_estimators': randint(100, 1000),
        'subsample': uniform(0.6, 0.4),
        'colsample_bytree': uniform(0.6, 0.4),
        'min_child_weight': randint(1, 10),
        'gamma': uniform(0, 0.5),
    }

    search = RandomizedSearchCV(
        xgb.XGBClassifier(random_state=random_seed, eval_metric='logloss'),
        param_distributions=param_distributions,
        n_iter=n_iter,
        cv=StratifiedKFold(n_splits=5, shuffle=True, random_state=random_seed),
        scoring='f1_weighted',
        random_state=random_seed,
        n_jobs=-1,
        verbose=1,
    )
    search.fit(X, y)

    print(f"Best F1: {search.best_score_:.4f}")
    print(f"Best params: {search.best_params_}")
    return {'best_score': float(search.best_score_), 'best_params': search.best_params_}
```

## Evaluation

### Comprehensive Evaluation Report

```python
from sklearn.metrics import (
    classification_report, confusion_matrix, roc_auc_score,
    average_precision_score
)
import json

def evaluate_model(model, X_test, y_test, output_dir: str) -> dict:
    """Generate comprehensive evaluation metrics and save artifacts."""
    y_pred = model.predict(X_test)
    y_proba = model.predict_proba(X_test) if hasattr(model, 'predict_proba') else None

    metrics = {
        'classification_report': classification_report(y_test, y_pred, output_dict=True),
        'confusion_matrix': confusion_matrix(y_test, y_pred).tolist(),
    }

    if y_proba is not None and len(np.unique(y_test)) == 2:
        metrics['roc_auc'] = float(roc_auc_score(y_test, y_proba[:, 1]))
        metrics['average_precision'] = float(average_precision_score(y_test, y_proba[:, 1]))

    with open(f'{output_dir}/metrics.json', 'w') as f:
        json.dump(metrics, f, indent=2)

    print(classification_report(y_test, y_pred))
    if 'roc_auc' in metrics:
        print(f"ROC AUC: {metrics['roc_auc']:.4f}")

    return metrics
```

### Experiment Comparison

```python
import pandas as pd

def compare_experiments(results: dict[str, dict]) -> pd.DataFrame:
    """Compare metrics across experiments."""
    rows = []
    for name, metrics in results.items():
        report = metrics['classification_report']
        rows.append({
            'experiment': name,
            'accuracy': report['accuracy'],
            'f1_weighted': report['weighted avg']['f1-score'],
            'precision_weighted': report['weighted avg']['precision'],
            'recall_weighted': report['weighted avg']['recall'],
        })
    df = pd.DataFrame(rows).sort_values('f1_weighted', ascending=False)
    print(df.to_string(index=False))
    return df
```

## HuggingFace Fine-Tuning

### Text Classification

```python
from transformers import (
    AutoTokenizer, AutoModelForSequenceClassification,
    TrainingArguments, Trainer
)
from datasets import Dataset
from sklearn.metrics import f1_score
import numpy as np

def fine_tune_classifier(
    train_texts: list[str],
    train_labels: list[int],
    val_texts: list[str],
    val_labels: list[int],
    model_name: str = 'bert-base-uncased',
    num_labels: int = 2,
    output_dir: str = './models/fine-tuned',
    epochs: int = 3,
    batch_size: int = 16,
    learning_rate: float = 2e-5,
) -> Trainer:
    """Fine-tune a HuggingFace transformer for classification."""
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSequenceClassification.from_pretrained(
        model_name, num_labels=num_labels
    )

    def tokenize(examples):
        return tokenizer(examples['text'], truncation=True, padding='max_length', max_length=128)

    train_dataset = Dataset.from_dict({'text': train_texts, 'label': train_labels}).map(tokenize, batched=True)
    val_dataset = Dataset.from_dict({'text': val_texts, 'label': val_labels}).map(tokenize, batched=True)

    training_args = TrainingArguments(
        output_dir=output_dir,
        num_train_epochs=epochs,
        per_device_train_batch_size=batch_size,
        per_device_eval_batch_size=batch_size * 2,
        learning_rate=learning_rate,
        weight_decay=0.01,
        eval_strategy='epoch',
        save_strategy='epoch',
        load_best_model_at_end=True,
        metric_for_best_model='f1',
        seed=42,
        logging_steps=50,
    )

    def compute_metrics(eval_pred):
        logits, labels = eval_pred
        preds = np.argmax(logits, axis=-1)
        return {'f1': f1_score(labels, preds, average='weighted'), 'accuracy': (preds == labels).mean()}

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        compute_metrics=compute_metrics,
    )

    trainer.train()
    return trainer
```

## Model Persistence

```python
import joblib
from pathlib import Path

def save_model(model, pipeline, config: ExperimentConfig, output_dir: str) -> None:
    """Save model, pipeline, and config together."""
    path = Path(output_dir)
    path.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, path / 'model.pkl')
    joblib.dump(pipeline, path / 'pipeline.pkl')
    config.save(str(path / 'config.json'))
    print(f"Model saved to {path}")

def load_model(model_dir: str):
    """Load model and pipeline for inference."""
    path = Path(model_dir)
    model = joblib.load(path / 'model.pkl')
    pipeline = joblib.load(path / 'pipeline.pkl')
    config = ExperimentConfig.load(str(path / 'config.json'))
    return model, pipeline, config
```

## Testing Training Code

```python
import pytest
import numpy as np
from sklearn.datasets import make_classification
from sklearn.ensemble import RandomForestClassifier

@pytest.fixture
def toy_dataset():
    """Small dataset for fast tests."""
    X, y = make_classification(n_samples=100, n_features=10, random_state=42)
    return X, y

def test_baseline_returns_all_models(toy_dataset):
    X, y = toy_dataset
    results = train_baseline(X, y)
    assert 'logistic_regression' in results
    assert 'random_forest' in results
    assert all(0 < r['mean_f1'] < 1 for r in results.values())

def test_model_predictions_deterministic(toy_dataset):
    X, y = toy_dataset
    model1 = train_xgboost(X[:80], y[:80], X[80:], y[80:])
    model2 = train_xgboost(X[:80], y[:80], X[80:], y[80:])
    np.testing.assert_array_equal(model1.predict(X[80:]), model2.predict(X[80:]))

def test_evaluate_model_saves_metrics(toy_dataset, tmp_path):
    X, y = toy_dataset
    model = RandomForestClassifier(random_state=42).fit(X[:80], y[:80])
    metrics = evaluate_model(model, X[80:], y[80:], str(tmp_path))
    assert (tmp_path / 'metrics.json').exists()
    assert 'classification_report' in metrics
```
