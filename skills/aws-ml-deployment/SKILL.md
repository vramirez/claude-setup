---
name: aws-ml-deployment
description: Deploy ML models to AWS SageMaker endpoints and invoke Bedrock LLMs. Use when deploying trained models to production, setting up SageMaker endpoints, configuring A/B testing, invoking Bedrock models, estimating deployment costs, or setting up model monitoring.
allowed-tools: Bash, BashOutput, Read, Write, Glob, Grep
---

# AWS ML Deployment

Workflows for deploying ML models on SageMaker and invoking LLMs via Bedrock. Covers endpoint creation, A/B testing, monitoring, and cost management.

## When to Activate This Skill

Activate this skill when:
- Deploying a trained model to a SageMaker endpoint
- Setting up A/B testing between model versions
- Invoking Bedrock foundation models for LLM inference
- Estimating deployment costs for ML infrastructure
- Setting up model monitoring and drift detection
- Creating inference containers

## Prerequisites

Verify AWS access before any operation:

```bash
aws sts get-caller-identity
aws configure get region
```

## SageMaker Model Deployment

### Step 1: Package Model

```python
import tarfile
from pathlib import Path

def package_model(model_dir: str, output_path: str = 'model.tar.gz') -> str:
    """Package model artifacts into SageMaker-expected format."""
    with tarfile.open(output_path, 'w:gz') as tar:
        for f in Path(model_dir).iterdir():
            tar.add(f, arcname=f.name)
    print(f"Model packaged: {output_path}")
    return output_path
```

Upload to S3:
```bash
aws s3 cp model.tar.gz s3://navigate-train/models/<project>/<version>/model.tar.gz
```

### Step 2: Inference Script

SageMaker requires `model_fn`, `input_fn`, `predict_fn`, `output_fn`:

```python
# inference.py -- placed alongside model artifacts
import joblib
import json
import os

def model_fn(model_dir: str):
    """Load model from the model directory."""
    model = joblib.load(os.path.join(model_dir, 'model.pkl'))
    pipeline = joblib.load(os.path.join(model_dir, 'pipeline.pkl'))
    return {'model': model, 'pipeline': pipeline}

def input_fn(request_body: str, content_type: str = 'application/json'):
    """Deserialize input data."""
    if content_type == 'application/json':
        return json.loads(request_body)
    raise ValueError(f"Unsupported content type: {content_type}")

def predict_fn(input_data, model_dict: dict):
    """Run prediction."""
    import pandas as pd
    df = pd.DataFrame(input_data['instances'])
    features = model_dict['pipeline'].transform(df)
    predictions = model_dict['model'].predict(features)
    probabilities = model_dict['model'].predict_proba(features)
    return {
        'predictions': predictions.tolist(),
        'probabilities': probabilities.tolist(),
    }

def output_fn(prediction, accept: str = 'application/json'):
    """Serialize prediction output."""
    return json.dumps(prediction)
```

### Step 3: Deploy Endpoint

```python
import sagemaker
from sagemaker.sklearn import SKLearnModel
from datetime import datetime

def deploy_sklearn_endpoint(
    model_s3_uri: str,
    instance_type: str = 'ml.t2.medium',
    instance_count: int = 1,
    endpoint_name: str = None,
) -> str:
    """Deploy a scikit-learn model to SageMaker endpoint."""
    session = sagemaker.Session()
    role = sagemaker.get_execution_role()

    if endpoint_name is None:
        endpoint_name = f"model-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

    model = SKLearnModel(
        model_data=model_s3_uri,
        role=role,
        framework_version='1.2-1',
        py_version='py3',
        entry_point='inference.py',
    )

    model.deploy(
        initial_instance_count=instance_count,
        instance_type=instance_type,
        endpoint_name=endpoint_name,
    )

    print(f"Endpoint deployed: {endpoint_name}")
    return endpoint_name
```

### Step 4: Invoke Endpoint

```python
import boto3
import json

def invoke_endpoint(endpoint_name: str, payload: dict) -> dict:
    """Invoke a SageMaker endpoint."""
    client = boto3.client('sagemaker-runtime')
    response = client.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType='application/json',
        Body=json.dumps(payload),
    )
    return json.loads(response['Body'].read().decode())
```

```bash
# CLI quick test
aws sagemaker-runtime invoke-endpoint \
  --endpoint-name my-model-endpoint \
  --content-type application/json \
  --body '{"instances": [{"feature1": 1.0, "feature2": "value"}]}' \
  /dev/stdout
```

## A/B Testing with Production Variants

```python
import boto3

def deploy_ab_test(
    model_a_s3: str,
    model_b_s3: str,
    traffic_split: float = 0.5,
    instance_type: str = 'ml.t2.medium',
    endpoint_name: str = 'ab-test-endpoint',
) -> str:
    """Deploy two model versions with traffic splitting."""
    session = sagemaker.Session()
    role = sagemaker.get_execution_role()
    client = boto3.client('sagemaker')

    model_a = SKLearnModel(model_data=model_a_s3, role=role,
                           framework_version='1.2-1', py_version='py3',
                           entry_point='inference.py')
    model_b = SKLearnModel(model_data=model_b_s3, role=role,
                           framework_version='1.2-1', py_version='py3',
                           entry_point='inference.py')

    container_a = model_a.prepare_container_def(instance_type)
    container_b = model_b.prepare_container_def(instance_type)

    model_a_name = f'{endpoint_name}-a'
    model_b_name = f'{endpoint_name}-b'

    client.create_model(ModelName=model_a_name, ExecutionRoleArn=role,
                        PrimaryContainer=container_a)
    client.create_model(ModelName=model_b_name, ExecutionRoleArn=role,
                        PrimaryContainer=container_b)

    client.create_endpoint_config(
        EndpointConfigName=endpoint_name,
        ProductionVariants=[
            {
                'VariantName': 'model-a',
                'ModelName': model_a_name,
                'InitialInstanceCount': 1,
                'InstanceType': instance_type,
                'InitialVariantWeight': traffic_split,
            },
            {
                'VariantName': 'model-b',
                'ModelName': model_b_name,
                'InitialInstanceCount': 1,
                'InstanceType': instance_type,
                'InitialVariantWeight': 1 - traffic_split,
            },
        ],
    )

    client.create_endpoint(EndpointName=endpoint_name,
                           EndpointConfigName=endpoint_name)
    print(f"A/B endpoint creating: {endpoint_name}")
    print(f"  model-a: {traffic_split*100:.0f}% traffic")
    print(f"  model-b: {(1-traffic_split)*100:.0f}% traffic")
    return endpoint_name
```

## Bedrock LLM Inference

```python
import boto3
import json

def invoke_bedrock(
    prompt: str,
    model_id: str = 'anthropic.claude-3-sonnet-20240229-v1:0',
    max_tokens: int = 1024,
    temperature: float = 0.0,
) -> str:
    """Invoke a Bedrock foundation model."""
    client = boto3.client('bedrock-runtime')

    body = json.dumps({
        'anthropic_version': 'bedrock-2023-05-31',
        'max_tokens': max_tokens,
        'temperature': temperature,
        'messages': [{'role': 'user', 'content': prompt}],
    })

    response = client.invoke_model(
        modelId=model_id,
        contentType='application/json',
        accept='application/json',
        body=body,
    )

    result = json.loads(response['body'].read())
    return result['content'][0]['text']


def invoke_bedrock_streaming(
    prompt: str,
    model_id: str = 'anthropic.claude-3-sonnet-20240229-v1:0',
    max_tokens: int = 1024,
):
    """Stream responses from Bedrock for lower time-to-first-token."""
    client = boto3.client('bedrock-runtime')

    body = json.dumps({
        'anthropic_version': 'bedrock-2023-05-31',
        'max_tokens': max_tokens,
        'messages': [{'role': 'user', 'content': prompt}],
    })

    response = client.invoke_model_with_response_stream(
        modelId=model_id,
        contentType='application/json',
        body=body,
    )

    for event in response['body']:
        chunk = json.loads(event['chunk']['bytes'])
        if chunk['type'] == 'content_block_delta':
            yield chunk['delta']['text']
```

```bash
# List available Bedrock models
aws bedrock list-foundation-models --query 'modelSummaries[].modelId' --output table
```

## Cost Estimation

### SageMaker Endpoint Costs

| Instance Type | vCPUs | Memory | GPU | On-Demand $/hr | Use Case |
|--------------|-------|--------|-----|-----------------|----------|
| ml.t2.medium | 2 | 4 GB | - | $0.065 | Dev/test, low traffic |
| ml.m5.large | 2 | 8 GB | - | $0.134 | Production, moderate traffic |
| ml.c5.xlarge | 4 | 8 GB | - | $0.238 | CPU-intensive inference |
| ml.g4dn.xlarge | 4 | 16 GB | T4 | $0.736 | GPU inference (NLP models) |
| ml.inf1.xlarge | 4 | 8 GB | Inferentia | $0.297 | Optimized inference |

**Monthly cost formula**: `hourly_rate x 24 x 30 x instance_count`

Example: ml.t2.medium 24/7 = $0.065 x 720 = ~$47/month

### Bedrock Costs (per 1K tokens)

| Model | Input $/1K | Output $/1K |
|-------|-----------|------------|
| Claude 3 Haiku | $0.00025 | $0.00125 |
| Claude 3 Sonnet | $0.003 | $0.015 |
| Claude 3.5 Sonnet | $0.003 | $0.015 |

```python
def estimate_bedrock_cost(
    input_tokens: int,
    output_tokens: int,
    model_id: str = 'claude-3-sonnet',
    calls_per_day: int = 100,
) -> dict:
    """Estimate monthly Bedrock costs."""
    rates = {
        'claude-3-haiku': (0.00025, 0.00125),
        'claude-3-sonnet': (0.003, 0.015),
    }
    input_rate, output_rate = rates.get(model_id, rates['claude-3-sonnet'])

    cost_per_call = (input_tokens / 1000 * input_rate) + (output_tokens / 1000 * output_rate)
    daily_cost = cost_per_call * calls_per_day
    monthly_cost = daily_cost * 30

    return {
        'cost_per_call': f'${cost_per_call:.4f}',
        'daily_cost': f'${daily_cost:.2f}',
        'monthly_cost': f'${monthly_cost:.2f}',
    }
```

## Endpoint Management

### Check Status

```bash
# List all endpoints
aws sagemaker list-endpoints --query 'Endpoints[].{Name:EndpointName,Status:EndpointStatus}' --output table

# Describe specific endpoint
aws sagemaker describe-endpoint --endpoint-name my-endpoint
```

### Cleanup (Cost Control)

Always clean up when done testing:

```python
def cleanup_endpoint(endpoint_name: str) -> None:
    """Delete endpoint, config, and model to stop billing."""
    client = boto3.client('sagemaker')

    endpoint_desc = client.describe_endpoint(EndpointName=endpoint_name)
    config_name = endpoint_desc['EndpointConfigName']

    config_desc = client.describe_endpoint_config(EndpointConfigName=config_name)
    model_names = [v['ModelName'] for v in config_desc['ProductionVariants']]

    client.delete_endpoint(EndpointName=endpoint_name)
    print(f"Deleted endpoint: {endpoint_name}")

    client.delete_endpoint_config(EndpointConfigName=config_name)
    print(f"Deleted config: {config_name}")

    for model_name in model_names:
        client.delete_model(ModelName=model_name)
        print(f"Deleted model: {model_name}")
```

```bash
# Quick CLI cleanup
aws sagemaker delete-endpoint --endpoint-name my-endpoint
aws sagemaker delete-endpoint-config --endpoint-config-name my-endpoint
aws sagemaker delete-model --model-name my-model
```

## Model Monitoring

### Data Capture for Drift Detection

```python
from sagemaker.model_monitor import DataCaptureConfig

data_capture_config = DataCaptureConfig(
    enable_capture=True,
    sampling_percentage=100,
    destination_s3_uri='s3://navigate-train/monitoring/data-capture',
    capture_options=['Input', 'Output'],
)

# Pass to deploy call
predictor = model.deploy(
    instance_type='ml.t2.medium',
    initial_instance_count=1,
    data_capture_config=data_capture_config,
)
```

### Basic Drift Check

```python
import json
import numpy as np

def check_prediction_drift(
    baseline_metrics_path: str,
    recent_predictions_path: str,
    threshold: float = 0.1,
) -> dict:
    """Compare recent predictions against baseline distribution."""
    with open(baseline_metrics_path) as f:
        baseline = json.load(f)

    with open(recent_predictions_path) as f:
        recent = json.load(f)

    baseline_mean = baseline['prediction_mean']
    recent_mean = np.mean(recent['predictions'])
    drift = abs(recent_mean - baseline_mean) / baseline_mean

    return {
        'baseline_mean': baseline_mean,
        'recent_mean': float(recent_mean),
        'drift_pct': float(drift * 100),
        'alert': drift > threshold,
    }
```

## Docker Container for Custom Inference

When built-in SageMaker containers are insufficient:

```dockerfile
FROM python:3.11-slim

RUN pip install --no-cache-dir \
    scikit-learn==1.4.0 \
    xgboost==2.0.3 \
    pandas==2.2.0 \
    flask==3.0.0 \
    gunicorn==21.2.0

COPY inference.py /opt/ml/code/
COPY serve.py /opt/ml/code/

WORKDIR /opt/ml/code
EXPOSE 8080

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "serve:app"]
```

Build and push to ECR:
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/ml-inference:latest"

docker build -t ml-inference -f Dockerfile.inference .
docker tag ml-inference:latest $ECR_URI

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
aws ecr create-repository --repository-name ml-inference 2>/dev/null || true
docker push $ECR_URI
```

## Deployment Checklist

- [ ] Model evaluated on hold-out test set with acceptable metrics
- [ ] Inference script tested locally with sample payloads
- [ ] Model artifacts uploaded to S3 with versioned path
- [ ] Instance type selected based on latency requirements and cost
- [ ] Endpoint name follows convention: `<project>-<model>-<version>`
- [ ] Data capture enabled for monitoring
- [ ] Cost estimate reviewed and approved
- [ ] Cleanup plan documented (when to delete endpoint)
- [ ] Rollback plan: previous model version S3 URI noted
