# ☁️ Compute Services Quick Reference

> A quick-reference guide to AWS compute services: **EC2**, **Lambda**, and **ECS**.

---

## 📑 Table of Contents

- [Amazon EC2 (Elastic Compute Cloud)](#amazon-ec2-elastic-compute-cloud)
  - [Service Overview](#service-overview)
  - [Instance Families](#instance-families)
  - [Pricing Models](#pricing-models)
  - [Key Limits](#key-limits)
  - [Exam Tips](#exam-tips)
- [AWS Lambda](#aws-lambda)
  - [Service Overview](#service-overview-1)
  - [Configuration](#configuration)
  - [Invocation Types](#invocation-types)
  - [Pricing](#pricing)
  - [Key Limits](#key-limits-1)
  - [Exam Tips](#exam-tips-1)
- [Amazon ECS (Elastic Container Service)](#amazon-ecs-elastic-container-service)
  - [Service Overview](#service-overview-2)
  - [Launch Types](#launch-types)
  - [Task Definition](#task-definition)
  - [Services](#services)
  - [Pricing (Fargate)](#pricing-fargate)
  - [Key Limits](#key-limits-2)
  - [Exam Tips](#exam-tips-2)

---

## Amazon EC2 (Elastic Compute Cloud)

### Service Overview

- Virtual servers in the cloud
- Pay for compute capacity by the hour/second
- Full control over OS and configuration

### Instance Families

| Family | Type | Sizes | Best For | Starting Cost |
|---|---|---|---|---|
| **T-Series** | Burstable | t3.nano – t3.2xlarge | Variable workloads (baseline CPU + burst credits) | $0.0052/hr (t3.micro) |
| **M-Series** | General Purpose | m5.large – m5.24xlarge | Web servers, applications (balanced compute/memory/network) | $0.096/hr (m5.large) |
| **C-Series** | Compute Optimized | c5.large – c5.24xlarge | Batch processing, HPC (high-performance processors) | $0.085/hr (c5.large) |
| **R-Series** | Memory Optimized | r5.large – r5.24xlarge | Databases, caches (memory-intensive apps) | $0.126/hr (r5.large) |
| **P-Series** | GPU | p3.2xlarge – p3.16xlarge | ML training, rendering (NVIDIA Tesla V100 GPUs) | $3.06/hr (p3.2xlarge) |

### Pricing Models

| Model | Commitment | Discount | Best For |
|---|---|---|---|
| **On-Demand** | None | Most expensive | Unpredictable workloads |
| **Reserved Instances** | 1 or 3 year | Up to 72% (All/Partial/No upfront) | Steady-state workloads |
| **Spot Instances** | None (bid-based) | Up to 90% (can be interrupted) | Fault-tolerant workloads |
| **Savings Plans** | 1 or 3 year | Up to 72% (flexible across instance types) | Variable but consistent usage |

### Key Limits

- Default: **20 instances** per region
- Request increase: up to **1000s**
- Max EBS volumes per instance: **28**
- Max network interfaces: varies by type
- Max instance store: varies by type

### Exam Tips

- ✅ Burstable (T) for variable workloads
- ✅ Reserved for 24/7 predictable workloads
- ✅ Spot for batch/fault-tolerant jobs
- ✅ Placement groups for HPC
- ✅ Enhanced networking for high throughput

---

## AWS Lambda

### Service Overview

- Serverless compute (no servers to manage)
- Pay only for compute time consumed
- Automatic scaling from zero to thousands

### Configuration

| Setting | Range | Notes |
|---|---|---|
| **Memory** | 128 MB – 10,240 MB (10 GB) | CPU scales proportionally; more memory = faster execution but higher cost |
| **Timeout** | 1 second – 15 minutes (900s) | Default is 3 seconds; set based on function needs |
| **Ephemeral Storage** | 512 MB – 10,240 MB | Temporary storage at `/tmp`, cleared between invocations |
| **Concurrency** | Default 1000 per region | Reserved concurrency guarantees capacity; provisioned concurrency pre-warms instances |

### Invocation Types

| Type | Behavior | Common Triggers | Retry Behavior |
|---|---|---|---|
| **Synchronous** | Caller waits for response | API Gateway, ALB, direct invoke | Client responsibility |
| **Asynchronous** | Lambda queues event, returns immediately | S3, SNS, EventBridge | Automatic (2 retries) |
| **Event Source Mapping** | Lambda polls the event source | SQS, Kinesis, DynamoDB Streams | Batch processing |

### Pricing

- **Requests:** $0.20 per 1M requests
- **Compute:** $0.0000166667 per GB-second
  - 1 GB memory, 1 second = $0.0000166667
  - 128 MB memory, 100 ms = $0.0000002083

**Free Tier (monthly):**
- 1M free requests
- 400,000 GB-seconds compute

**Example Cost** — 1M invocations, 512MB, 200ms average:

| Component | Calculation | Cost |
|---|---|---|
| Requests | — | $0.20 |
| Compute | 1M × 0.5GB × 0.2s × $0.0000166667 | $1.67 |
| **Total** | | **$1.87/month** |

### Key Limits

- Deployment package: **50 MB** (zipped), **250 MB** (unzipped)
- Environment variables: **4 KB** total
- Layers: **5** per function
- Concurrent executions: **1000** per region (soft limit)
- Invocation payload: **6 MB** (sync), **256 KB** (async)

### Exam Tips

- ✅ 15-minute max timeout
- ✅ Stateless (use S3/DynamoDB for state)
- ✅ Cold starts — provisioned concurrency solves this
- ✅ EventBridge for cron jobs
- ✅ DLQ for failed async invocations

---

## Amazon ECS (Elastic Container Service)

### Service Overview

- Managed container orchestration
- Run Docker containers at scale
- Two launch types: **EC2** and **Fargate**

### Launch Types

| Launch Type | Who Manages Infrastructure | Trade-off | Best For |
|---|---|---|---|
| **EC2** | You manage EC2 instances | More control, lower cost; responsible for scaling/patching | Cost optimization, custom requirements |
| **Fargate** | AWS manages infrastructure | Serverless containers; pay only for vCPU and memory | Operational simplicity |

### Task Definition

Defines container configuration:

- Docker image
- CPU/Memory requirements
- Port mappings
- Environment variables
- Logging configuration

**Example:**

```json
{
  "family": "web-app",
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [{
    "name": "web",
    "image": "nginx:latest",
    "portMappings": [{
      "containerPort": 80
    }]
  }]
}
```

### Services

Maintains the desired count of tasks:

- Auto Scaling integration
- Load balancer integration
- Rolling deployments
- Service discovery

### Pricing (Fargate)

- **vCPU:** $0.04048 per vCPU per hour
- **Memory:** $0.004445 per GB per hour

**Example Task** (0.25 vCPU, 0.5 GB):

| Period | Calculation | Cost |
|---|---|---|
| Hourly | 0.25 × $0.04048 + 0.5 × $0.004445 | $0.0123 |
| Monthly (24/7) | — | **$8.93** |

### Key Limits

- Tasks per service: **10,000**
- Services per cluster: **5,000**
- Container instances per cluster: **5,000**
- Task definition size: **64 KB**

### Exam Tips

- ✅ Fargate for serverless containers
- ✅ EC2 for cost optimization at scale
- ✅ Service discovery with Cloud Map
- ✅ ECS Anywhere for on-premises
- ✅ Task roles for IAM permissions

---

*Reference compiled May 2026*
