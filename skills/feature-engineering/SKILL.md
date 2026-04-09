---
name: feature-engineering
description: Systematic feature engineering workflows for ML pipelines. Use when exploring data, creating features, handling missing values, encoding categoricals, scaling numerics, or building sklearn transformation pipelines.
allowed-tools: Bash, BashOutput, Read, Write, Glob, Grep
---

# Feature Engineering

Systematic workflows for transforming raw data into ML-ready features. Covers exploration, cleaning, transformation, and pipeline construction.

## When to Activate This Skill

Activate this skill when:
- Exploring a new dataset for ML modeling
- Creating or transforming features from raw data
- Building sklearn preprocessing pipelines
- Handling missing values, outliers, or categorical encoding
- Performing feature selection or dimensionality reduction

## Step 1: Data Exploration

Always start by understanding the data before transforming it.

```python
import pandas as pd
import numpy as np

def explore_dataset(df: pd.DataFrame, target_col: str = None) -> None:
    """Print comprehensive data summary."""
    print(f"Shape: {df.shape}")
    print(f"\nDtypes:\n{df.dtypes.value_counts()}")
    print(f"\nMissing values:\n{df.isnull().sum()[df.isnull().sum() > 0]}")
    print(f"\nNumeric summary:\n{df.describe()}")
    print(f"\nCategorical columns:")
    for col in df.select_dtypes(include='object').columns:
        print(f"  {col}: {df[col].nunique()} unique, top={df[col].mode().iloc[0]}")
    if target_col:
        print(f"\nTarget distribution:\n{df[target_col].value_counts(normalize=True)}")
```

### Checklist Before Engineering Features

- [ ] Check shape and dtypes
- [ ] Identify target variable and its distribution (class imbalance?)
- [ ] Quantify missing values per column (>50% missing = consider dropping)
- [ ] Check cardinality of categorical columns
- [ ] Look for date/time columns to extract temporal features
- [ ] Check for duplicate rows
- [ ] Identify potential data leakage columns (IDs, future-looking features)

## Step 2: Missing Value Strategies

Choose strategy based on data characteristics:

```python
from sklearn.impute import SimpleImputer, KNNImputer

# Numeric: median (robust to outliers)
numeric_imputer = SimpleImputer(strategy='median')

# Categorical: most frequent or constant
categorical_imputer = SimpleImputer(strategy='most_frequent')

# When relationships matter: KNN imputation
knn_imputer = KNNImputer(n_neighbors=5)

# Create missing indicator features (missingness can be informative)
from sklearn.impute import MissingIndicator
indicator = MissingIndicator(features='missing-only')
```

**Decision guide:**
- Random missing (<5%): median/mode imputation
- Structured missing (5-30%): KNN or model-based imputation + missing indicator
- Heavy missing (>50%): Drop column unless missingness is the signal

## Step 3: Feature Transformations

### Numeric Features

```python
from sklearn.preprocessing import (
    StandardScaler, RobustScaler, PowerTransformer,
    QuantileTransformer, KBinsDiscretizer
)

# Standard: zero mean, unit variance (use when algorithm assumes normality)
scaler = StandardScaler()

# Robust: use when outliers are present
scaler = RobustScaler()

# Power transform: make skewed distributions more Gaussian
transformer = PowerTransformer(method='yeo-johnson')

# Binning: convert continuous to ordinal (useful for tree stumps, interactions)
binner = KBinsDiscretizer(n_bins=5, encode='ordinal', strategy='quantile')
```

### Categorical Features

```python
from sklearn.preprocessing import OrdinalEncoder, OneHotEncoder, TargetEncoder

# Low cardinality (<10 categories): one-hot encoding
ohe = OneHotEncoder(handle_unknown='ignore', sparse_output=False)

# Ordinal (natural order): ordinal encoding
oe = OrdinalEncoder(categories=[['low', 'medium', 'high']])

# High cardinality (>10 categories): target encoding
te = TargetEncoder(smooth='auto')
```

**Decision guide:**
- Linear models: one-hot for low cardinality, target encoding for high
- Tree models: ordinal encoding works well (trees split on thresholds)
- High cardinality (>50): target encoding or hash encoding

### Temporal Features

```python
def extract_datetime_features(df: pd.DataFrame, col: str) -> pd.DataFrame:
    """Extract useful features from a datetime column."""
    dt = pd.to_datetime(df[col])
    return pd.DataFrame({
        f'{col}_hour': dt.dt.hour,
        f'{col}_dayofweek': dt.dt.dayofweek,
        f'{col}_month': dt.dt.month,
        f'{col}_is_weekend': dt.dt.dayofweek.isin([5, 6]).astype(int),
        f'{col}_quarter': dt.dt.quarter,
    })
```

### Text Features (Basic)

```python
def extract_text_features(df: pd.DataFrame, col: str) -> pd.DataFrame:
    """Extract basic text statistics."""
    return pd.DataFrame({
        f'{col}_length': df[col].str.len(),
        f'{col}_word_count': df[col].str.split().str.len(),
        f'{col}_has_uppercase': df[col].str.contains(r'[A-Z]').astype(int),
    })
```

For deep text features (embeddings, TF-IDF), use the model-training skill.

## Step 4: Interaction Features

```python
# Ratio features (common in financial/business data)
df['price_per_unit'] = df['total_price'] / df['quantity'].clip(lower=1)

# Polynomial interactions (use sparingly)
from sklearn.preprocessing import PolynomialFeatures
poly = PolynomialFeatures(degree=2, interaction_only=True, include_bias=False)

# Aggregation features (group statistics)
def add_group_stats(df: pd.DataFrame, group_col: str, value_col: str) -> pd.DataFrame:
    """Add group-level statistics as features."""
    stats = df.groupby(group_col)[value_col].agg(['mean', 'std', 'min', 'max'])
    stats.columns = [f'{group_col}_{value_col}_{s}' for s in stats.columns]
    return df.merge(stats, left_on=group_col, right_index=True, how='left')
```

## Step 5: Build sklearn Pipeline

Always use pipelines for reproducibility and to prevent data leakage.

```python
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

def build_preprocessing_pipeline(
    numeric_features: list[str],
    categorical_features: list[str],
    high_cardinality_features: list[str] | None = None,
) -> ColumnTransformer:
    """Build a reusable preprocessing pipeline."""
    numeric_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', RobustScaler()),
    ])

    categorical_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False)),
    ])

    transformers = [
        ('num', numeric_transformer, numeric_features),
        ('cat', categorical_transformer, categorical_features),
    ]

    if high_cardinality_features:
        high_card_transformer = Pipeline(steps=[
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('encoder', TargetEncoder(smooth='auto')),
        ])
        transformers.append(('high_card', high_card_transformer, high_cardinality_features))

    return ColumnTransformer(transformers=transformers, remainder='drop')
```

## Step 6: Feature Selection

Run after initial feature engineering to reduce dimensionality.

```python
from sklearn.feature_selection import (
    SelectKBest, mutual_info_classif, SequentialFeatureSelector
)
from sklearn.ensemble import RandomForestClassifier

# Filter method: fast, good for initial screening
selector = SelectKBest(score_func=mutual_info_classif, k=20)

# Wrapper method: slower, better results
sfs = SequentialFeatureSelector(
    RandomForestClassifier(n_estimators=100, random_state=42),
    n_features_to_select=15,
    direction='forward',
    scoring='f1_weighted',
    cv=3,
)

# Importance-based: from a trained tree model
def get_feature_importances(model, feature_names: list[str]) -> pd.Series:
    """Extract and sort feature importances."""
    importances = pd.Series(model.feature_importances_, index=feature_names)
    return importances.sort_values(ascending=False)
```

## Testing Feature Engineering

Write tests for every transformation function:

```python
import pytest
import pandas as pd
import numpy as np

def test_extract_datetime_features():
    df = pd.DataFrame({'ts': ['2024-01-15 14:30:00', '2024-06-22 09:00:00']})
    result = extract_datetime_features(df, 'ts')
    assert 'ts_hour' in result.columns
    assert result['ts_hour'].iloc[0] == 14
    assert result['ts_is_weekend'].iloc[0] == 0

def test_group_stats_handles_single_group():
    df = pd.DataFrame({'group': ['a', 'a', 'a'], 'val': [1, 2, 3]})
    result = add_group_stats(df, 'group', 'val')
    assert result['group_val_mean'].iloc[0] == 2.0

def test_pipeline_handles_missing_values():
    df = pd.DataFrame({'num': [1.0, np.nan, 3.0], 'cat': ['a', None, 'b']})
    pipeline = build_preprocessing_pipeline(['num'], ['cat'])
    result = pipeline.fit_transform(df)
    assert not np.isnan(result).any()
```

## Common Pitfalls

1. **Data leakage**: Never fit scalers/encoders on test data. Always use pipelines.
2. **Target leakage**: Features derived from the target or future information.
3. **High cardinality one-hot**: Explodes dimensionality. Use target encoding instead.
4. **Scaling tree models**: Trees do not need feature scaling -- skip it.
5. **Imputing then dropping**: If you impute missing values, you lose the missingness signal. Add indicator features.
