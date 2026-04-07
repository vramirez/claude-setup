---
name: aws-infrastructure
description: Manage AWS resources, deploy infrastructure with CDK, run SageMaker training jobs, and interact with S3. Use when deploying to AWS, training ML models on GPU, managing cloud resources, or working with S3 storage.
allowed-tools: Bash, BashOutput, Read, Write, Glob, Grep
---

# AWS Infrastructure

Manage AWS cloud resources using AWS CLI, CDK, and boto3. Provides workflows for ML training, S3 storage, and infrastructure deployment.

## When to Activate This Skill

Activate this skill when:
- User needs to deploy or manage AWS resources
- Training ML models on SageMaker GPU instances
- Working with S3 buckets (upload, download, sync)
- Deploying infrastructure with CDK
- Checking AWS account status or credentials

## Prerequisites

Before running AWS commands, verify credentials are configured:

```bash
aws sts get-caller-identity
```

If this fails, credentials need to be configured via `aws configure` or environment variables.

## Core Workflows

### 1. Verify AWS Access

Always verify credentials before AWS operations:

```bash
# Check current identity
aws sts get-caller-identity

# Check configured region
aws configure get region

# List available profiles
aws configure list-profiles
```

### 2. S3 Operations

```bash
# List buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://bucket-name/
aws s3 ls s3://bucket-name/ --recursive

# Upload file
aws s3 cp local-file.txt s3://bucket-name/path/

# Download file
aws s3 cp s3://bucket-name/path/file.txt ./local-file.txt

# Sync directory
aws s3 sync ./local-dir s3://bucket-name/prefix/
aws s3 sync s3://bucket-name/prefix/ ./local-dir

# Create bucket
aws s3 mb s3://new-bucket-name --region us-east-1

# Delete file
aws s3 rm s3://bucket-name/path/file.txt

# Delete bucket (must be empty)
aws s3 rb s3://bucket-name
```

### 3. SageMaker Training

For ML model training on GPU instances:

```bash
# Navigate to training infrastructure
cd infra/sagemaker-training/

# Launch training job (uses spot instances for cost savings)
python launch_training.py --epochs 5 --wait

# Launch with custom instance type
python launch_training.py --instance-type ml.g4dn.xlarge --epochs 10

# Check training job status
aws sagemaker describe-training-job --training-job-name <job-name>

# List recent training jobs
aws sagemaker list-training-jobs --max-results 10

# Download trained model after completion
aws s3 cp s3://navigate-train/output/<job-name>/output/model.tar.gz .
tar -xzf model.tar.gz -C ./model/
```

### 4. CDK Infrastructure Deployment

```bash
# Navigate to CDK project
cd infra/sagemaker-training/

# Install CDK dependencies
pip install -r cdk_requirements.txt

# Synthesize CloudFormation template (preview)
cdk synth

# Deploy stack
cdk deploy

# Deploy with auto-approve
cdk deploy --require-approval never

# Destroy stack
cdk destroy

# List stacks
cdk list

# Show differences
cdk diff
```

### 5. EC2 Operations (if needed)

```bash
# List running instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]' --output table

# Start/stop instance
aws ec2 start-instances --instance-ids i-xxxxx
aws ec2 stop-instances --instance-ids i-xxxxx
```

### 6. CloudWatch Logs

```bash
# List log groups
aws logs describe-log-groups --query 'logGroups[].logGroupName'

# Tail logs (requires aws logs tail or similar)
aws logs tail /aws/sagemaker/TrainingJobs --follow
```

## Project-Specific Resources

### S3 Buckets
- `navigate-train` - ML model training data and artifacts
  - `data/` - Training datasets
  - `output/` - Model artifacts from SageMaker jobs
  - `source/` - Training source code archives

### Infrastructure Code
- `infra/sagemaker-training/`
  - `train.py` - Standalone training script for SageMaker
  - `launch_training.py` - Script to launch SageMaker training jobs
  - `cdk_stack.py` - CDK stack for IAM roles and resources
  - `requirements.txt` - Training environment dependencies

## Cost Management

### Spot Instances
Training jobs use spot instances by default (~70% cost savings):
- `ml.g4dn.xlarge` - ~$0.16/hr spot vs $0.53/hr on-demand
- Training typically completes in 5-15 minutes

### Cleanup
Always clean up unused resources:
```bash
# Delete old training job artifacts
aws s3 rm s3://navigate-train/output/old-job/ --recursive

# Destroy CDK stacks when not needed
cdk destroy
```

## Troubleshooting

### Credentials Issues
```bash
# Check if credentials are expired
aws sts get-caller-identity

# Re-configure if needed
aws configure
```

### SageMaker Job Failures
```bash
# Get failure reason
aws sagemaker describe-training-job --training-job-name <job-name> \
  --query 'FailureReason'

# Check CloudWatch logs
aws logs get-log-events \
  --log-group-name /aws/sagemaker/TrainingJobs \
  --log-stream-name <job-name>/algo-1-xxxxx
```

### Permission Errors
Ensure IAM user/role has required permissions:
- `AmazonSageMakerFullAccess` for training jobs
- `AmazonS3FullAccess` for S3 operations
- CDK requires `cloudformation:*`, `iam:*`, `s3:*` permissions

## Security Best Practices

1. **Never hardcode credentials** - Use AWS CLI profiles or environment variables
2. **Never commit AWS account IDs** - Use `aws sts get-caller-identity` dynamically
3. **Use least privilege** - Create specific IAM roles for each use case
4. **Enable MFA** - For production accounts
5. **Rotate credentials** - Regularly rotate access keys

## Common Patterns

### Upload Data and Train Model
```bash
# 1. Upload training data
aws s3 cp data/training.json s3://navigate-train/data/

# 2. Launch training
cd infra/sagemaker-training/
python launch_training.py --epochs 5 --wait

# 3. Download model
aws s3 cp s3://navigate-train/output/<job>/output/model.tar.gz .
tar -xzf model.tar.gz -C ./trained_model/
```

### Deploy New Infrastructure
```bash
# 1. Update CDK code
# 2. Preview changes
cdk diff

# 3. Deploy
cdk deploy

# 4. Verify
aws cloudformation describe-stacks --stack-name EventClassifierTraining
```
