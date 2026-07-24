# 🖥️ Amazon EC2 — Complete Reference Guide

> A comprehensive reference for Amazon Elastic Compute Cloud (EC2), covering fundamentals, instance types, pricing models, operations, and production-grade best practices.

---

## 📑 Table of Contents

- [Introduction](#-introduction)
- [EC2 Fundamentals](#-ec2-fundamentals)
- [Instance Types and Families](#-instance-types-and-families)
  - [General Purpose (M, T, Mac)](#general-purpose-m-t-mac)
  - [Compute Optimized (C)](#compute-optimized-c)
  - [Memory Optimized (R, X, z, High Memory)](#memory-optimized-r-x-z-high-memory)
  - [Storage Optimized (I, D, H)](#storage-optimized-i-d-h)
  - [Accelerated Computing (P, G, F, Inf, Trn)](#accelerated-computing-p-g-f-inf-trn)
  - [Instance Type Selection Guide](#instance-type-selection-guide)
- [Amazon Machine Images (AMIs)](#-amazon-machine-images-amis)
- [Instance Lifecycle](#-instance-lifecycle)
- [Instance Pricing Models](#-instance-pricing-models)
  - [On-Demand Instances](#on-demand-instances)
  - [Reserved Instances (RIs)](#reserved-instances-ris)
  - [Savings Plans](#savings-plans)
  - [Spot Instances](#spot-instances)
  - [Dedicated Hosts & Dedicated Instances](#dedicated-hosts--dedicated-instances)
- [Placement Groups](#-placement-groups)
- [Enhanced Networking](#-enhanced-networking)
- [Elastic IP Addresses](#-elastic-ip-addresses)
- [Instance Metadata and User Data](#-instance-metadata-and-user-data)
- [EC2 Storage Options](#-ec2-storage-options)
- [Production-Level Knowledge](#-production-level-knowledge)
  - [Fleet Management at Scale](#fleet-management-at-scale)
  - [Advanced Auto Scaling Patterns](#advanced-auto-scaling-patterns)
  - [Disaster Recovery and High Availability](#disaster-recovery-and-high-availability)
  - [Cost Optimization Strategies](#cost-optimization-strategies)
- [Tips & Best Practices](#-tips--best-practices)
- [Pitfalls & Remedies](#-pitfalls--remedies)
- [Summary](#-summary)
- [Hands-On Lab Exercise](#-hands-on-lab-exercise)
- [Review Questions](#-review-questions)

---

## 🚀 Introduction

Amazon Elastic Compute Cloud (EC2) is the backbone of AWS compute services, providing resizable virtual servers that form the foundation for countless applications and workloads. Since its launch in 2006, EC2 has revolutionized how organizations provision and manage computing resources, transforming weeks of procurement cycles into minutes of API calls. Understanding EC2 is fundamental to becoming an effective AWS Solutions Architect.

EC2's flexibility is both its greatest strength and its biggest challenge. With hundreds of instance types, multiple pricing models, various storage options, and complex networking configurations, making optimal decisions requires deep understanding of both the service and your workload requirements. A poorly chosen instance type can waste thousands of dollars monthly, while incorrect Auto Scaling configurations can leave your application unavailable during traffic spikes.

The true power of EC2 extends far beyond simply launching virtual machines. Modern EC2 architectures leverage:

- **Auto Scaling** for elasticity
- **Application Load Balancers** for traffic distribution
- **AMIs** for repeatable deployments
- **Placement strategies** for performance optimization

Successful production deployments require mastering instance lifecycle management, implementing comprehensive monitoring, designing effective patching strategies, and optimizing costs through Reserved Instances and Savings Plans.

---

## ⚙️ EC2 Fundamentals

Amazon EC2 provides secure, resizable compute capacity in the cloud. Each instance is a virtual server that you can configure with the operating system, applications, and data needed for your workload.

### Key Characteristics

| Characteristic | Description |
|---|---|
| **Elasticity** | Scale up or down within minutes |
| **Complete Control** | Root access to each instance |
| **Flexible Pricing** | Pay only for what you use |
| **Integrated** | Works seamlessly with other AWS services |
| **Secure** | Leverages VPC, security groups, and IAM |
| **Reliable** | 99.99% SLA when properly architected |

### Instance Components

1. **vCPUs** — Virtual central processing units
2. **Memory (RAM)** — Instance memory in GiB
3. **Storage** — Instance store (ephemeral) or EBS (persistent)
4. **Network** — Enhanced networking capabilities
5. **GPU/Accelerators** — For specific workloads (ML, graphics)

---

## 🏗️ Instance Types and Families

EC2 offers over 400 instance types organized into families optimized for different use cases.

### Naming Convention

```
Format: [Family][Generation].[Size]
Example: m5.2xlarge
```

- `m` = General Purpose family
- `5` = 5th generation
- `2xlarge` = Size (8 vCPUs, 32 GiB RAM)

### Additional Suffixes

| Suffix | Meaning | Example |
|---|---|---|
| `a` | AMD processors | `m5a.large` |
| `n` | Enhanced networking | `c5n.xlarge` |
| `d` | Instance store volumes | `m5d.large` |
| `e` | Extra storage or memory | `r5e.xlarge` |
| `metal` | Bare metal | `c5.metal` |

---

### General Purpose (M, T, Mac)

Balanced compute, memory, and networking for diverse workloads.

**M6i Family (Latest Intel)**
- **Use Cases:** Web servers, small databases, development environments
- **vCPUs:** 1 to 128
- **Memory:** 4 GiB to 512 GiB
- **Network:** Up to 50 Gbps
- **Example:** `m6i.xlarge` — 4 vCPUs, 16 GiB RAM

**T3/T4g Family (Burstable)**
- **Use Cases:** Websites, microservices, dev/test, small databases
- **Special Feature:** CPU credits for burst performance
- **Cost:** Lowest cost per hour
- **Baseline Performance:** 20–40% of vCPU
- **Burst:** Up to 100% when credits available
- **Example:** `t3.medium` — 2 vCPUs, 4 GiB RAM, 20% baseline

> **CPU Credits Explained**
> - T3.medium earns 24 credits/hour
> - Each credit = 1 vCPU at 100% for 1 minute
> - Baseline (20%) uses 12 credits/hour
> - Surplus: 12 credits/hour for bursting

**Mac Instances**
- **Use Cases:** iOS/macOS development, testing
- **Host:** Dedicated Mac mini hardware
- **OS:** macOS Monterey, Ventura, Sonoma
- **Minimum Allocation:** 24 hours

---

### Compute Optimized (C)

High-performance processors for compute-intensive workloads.

**C6i Family**
- **Use Cases:** Batch processing, media transcoding, gaming servers, scientific modeling
- **vCPUs:** 2 to 128
- **Memory:** 4 GiB to 256 GiB
- **Processor:** 3rd Gen Intel Xeon (3.5 GHz)
- **Network:** Up to 50 Gbps
- **Price:** Higher CPU-to-memory ratio

**C7g Family (Graviton3)**
- **Processor:** AWS Graviton3 (ARM)
- **Performance:** Up to 25% better than C6g
- **Cost:** Up to 20% lower than comparable Intel
- **Use Cases:** High-performance computing, gaming, video encoding

---

### Memory Optimized (R, X, z, High Memory)

Large memory for memory-intensive applications.

**R6i Family**
- **Use Cases:** In-memory databases (Redis, SAP HANA), big data analytics
- **vCPUs:** 2 to 128
- **Memory:** 16 GiB to 1,024 GiB (1 TB)
- **Memory-to-vCPU Ratio:** 8:1

**X2iedn Family (High Memory & Storage)**
- **Use Cases:** Memory-intensive databases, in-memory analytics
- **vCPUs:** 2 to 128
- **Memory:** 16 GiB to 4,096 GiB (4 TB)
- **Memory-to-vCPU Ratio:** 32:1
- **Storage:** Up to 3.8 TB NVMe SSD

**High Memory Instances**
- **Sizes:** 3 TB, 6 TB, 9 TB, 12 TB, 18 TB, 24 TB
- **Use Cases:** SAP HANA, in-memory databases
- **Special:** Bare metal only

---

### Storage Optimized (I, D, H)

High sequential read/write access to large datasets on local storage.

**I3/I3en Family**
- **Use Cases:** NoSQL databases (Cassandra, MongoDB), data warehousing, Elasticsearch
- **Storage:** NVMe SSD instance store
- **IOPS:** Up to 3.3 million random read IOPS
- **Throughput:** Up to 16 GB/s sequential read
- **Sizes:** 1.9 TB to 60 TB local NVMe storage

**D3/D3en Family**
- **Use Cases:** Distributed file systems, data processing, MapReduce
- **Storage:** HDD instance store
- **Capacity:** Up to 336 TB local HDD storage
- **Throughput:** Up to 6.2 GB/s sequential read
- **Cost:** Lowest cost per GB of storage

---

### Accelerated Computing (P, G, F, Inf, Trn)

Hardware accelerators for ML, graphics, and high-performance computing.

**P4d Family (GPU — NVIDIA A100)**
- **Use Cases:** Machine learning training, HPC simulations
- **GPUs:** 8x NVIDIA A100 (40 GB each)
- **GPU Memory:** 320 GB total
- **Network:** 400 Gbps ENA, 4x 100 Gbps GPUDirect RDMA
- **Cost:** $32.77/hour (on-demand)

**G5 Family (GPU — NVIDIA A10G)**
- **Use Cases:** Graphics workstations, game streaming, ML inference
- **GPUs:** 1 to 8 NVIDIA A10G (24 GB each)
- **Cost:** Lower than P4 for inference workloads

**Inf1 Family (AWS Inferentia)**
- **Use Cases:** ML inference at scale
- **Accelerators:** AWS Inferentia chips
- **Performance:** 2.3x higher throughput than G4
- **Cost:** 70% lower cost than GPU instances

**Trn1 Family (AWS Trainium)**
- **Use Cases:** Deep learning training
- **Accelerators:** AWS Trainium chips
- **Performance:** Up to 50% cost savings vs P4d

---

### Instance Type Selection Guide

| Workload | Recommended Family | Rationale |
|---|---|---|
| Web/App Servers | T3, M6i | Balanced resources, cost-effective |
| Microservices | T3, T4g | Burstable, low cost |
| Batch Processing | C6i, C7g | High CPU performance |
| In-Memory Cache | R6i, R6g | Large memory |
| Relational Databases | R6i, M6i | Memory + storage performance |
| NoSQL Databases | I3, I3en | High IOPS local storage |
| Data Warehousing | D3, I3en | Large storage capacity |
| Video Encoding | C6i, C6g | High CPU, cost-efficient |
| ML Training | P4d, Trn1 | GPUs or ML accelerators |
| ML Inference | G5, Inf1 | Cost-optimized for inference |
| SAP HANA | X2iedn, High Memory | Very large memory requirements |

---

## 💿 Amazon Machine Images (AMIs)

An AMI is a template containing the software configuration (OS, applications, settings) needed to launch an EC2 instance.

### AMI Components

1. **Root Volume Template** — OS and boot configuration
2. **Launch Permissions** — Who can use the AMI
3. **Block Device Mapping** — Volumes to attach at launch

### AMI Types

**1. AWS-Provided AMIs**
- Amazon Linux 2023 (AL2023) — *Recommended*
- Amazon Linux 2 (AL2) — Previous generation
- Ubuntu, Red Hat Enterprise Linux (RHEL), Windows Server
- Optimized for EC2, pre-configured, regularly updated

**2. Marketplace AMIs**
- Third-party software pre-installed
- Commercial software (SQL Server, WordPress, etc.)
- Pay for software usage plus EC2 costs

**3. Community AMIs**
- Shared by AWS community
- Free, but no warranty
- Security and compliance responsibility on user

**4. Custom AMIs**
- Your own images
- Pre-configured applications
- Golden images for consistent deployments

### AMI Lifecycle

```
1. Launch instance
2. Customize (install software, configure)
3. Create AMI from instance
4. Launch new instances from AMI
5. Share AMI (optional)
6. Copy AMI to other regions (optional)
7. Deregister AMI when no longer needed
```

### AMI Backing

**EBS-Backed AMIs**
- Root device is EBS volume
- Can be stopped without data loss
- Faster boot times (typically < 1 minute)
- Most common type

**Instance Store-Backed AMIs**
- Root device is instance store volume
- Cannot be stopped (only terminated)
- Data lost on stop/terminate
- Slower boot times
- Less common, specific use cases

---

## 🔄 Instance Lifecycle

Understanding the complete instance lifecycle is critical for proper management.

### Instance States

```
pending → running → stopping → stopped → terminated
                                   ↓
                              shutting-down → terminated
```

| State | Billed | Can Connect | Notes |
|---|---|---|---|
| **Pending** | No | No | Instance is launching |
| **Running** | Yes (per second) | Yes | Operations: Stop, reboot, terminate |
| **Stopping** | Brief period | No | Instance is shutting down |
| **Stopped** | No (only EBS volumes) | No | Operations: Start, terminate, modify |
| **Shutting-down** | No | No | Instance is terminating |
| **Terminated** | No | — | Cannot be restarted; EBS volumes can be preserved if configured |

### Important Behaviors

**Stop vs. Terminate**
- **Stop:** Instance can be restarted, keeps EBS volumes, data persists
- **Terminate:** Instance deleted, instance store data lost, EBS volumes deleted (unless configured otherwise)

**Instance Store Data**
- Lost on: Stop, terminate, hardware failure
- Persists on: Reboot

**EBS Volume Data**
- Persists through: Stop, reboot
- Configurable on terminate: `DeleteOnTermination` flag

**Public IP Changes**
- Public IP changes when instance stopped/started
- Elastic IP persists through stop/start
- Private IP persists unless instance terminated

---

## 💰 Instance Pricing Models

EC2 offers multiple pricing models to optimize costs.

### On-Demand Instances

**Characteristics**
- Pay per second (Linux) or per hour (Windows)
- No commitment
- No upfront payment
- Highest hourly cost

**Use Cases**
- Development and testing
- Unpredictable workloads
- Short-term, spiky workloads
- Applications being tested for the first time

**Pricing Example**
```
m6i.xlarge (4 vCPUs, 16 GiB RAM)
Cost: $0.192/hour = $140.16/month (730 hours)
```

---

### Reserved Instances (RIs)

**Characteristics**
- 1-year or 3-year commitment
- Up to 75% discount vs On-Demand
- Payment options: All Upfront, Partial Upfront, No Upfront
- Region or AZ specific

**Types**

1. **Standard Reserved Instances**
   - Highest discount (up to 75%)
   - Cannot change instance family
   - Can change: AZ, instance size (within same family), network type

2. **Convertible Reserved Instances**
   - Lower discount (up to 54%)
   - Can change instance family, OS, tenancy
   - More flexibility

**Regional vs. Zonal RIs**
- **Regional:** Applies to any AZ in region, provides capacity priority
- **Zonal:** Specific AZ, provides capacity reservation

**Pricing Example**
```
m6i.xlarge - 3 year, All Upfront
On-Demand: $140.16/month × 36 months = $5,045.76
Reserved (Standard): $2,500 upfront = $69.44/month
Savings: 50%
```

---

### Savings Plans

**Characteristics**
- Commitment to consistent usage ($/hour) for 1 or 3 years
- Up to 72% discount
- More flexible than Reserved Instances

**Types**

1. **Compute Savings Plans**
   - Most flexible
   - Applies to: EC2, Lambda, Fargate
   - Any instance family, size, OS, tenancy, region
   - Up to 66% discount

2. **EC2 Instance Savings Plans**
   - Less flexible than Compute
   - Specific instance family in specific region
   - Can change: size, OS, tenancy
   - Up to 72% discount

**Comparison**

| Feature | Reserved Instances | Savings Plans |
|---|---|---|
| Commitment | Specific instance type | Usage amount ($/hour) |
| Discount | Up to 75% | Up to 72% |
| Flexibility | Limited | High |
| Coverage | EC2 only | EC2, Lambda, Fargate |
| Applies to | Specific instance configuration | Automatically applies |

> **Recommendation:** Savings Plans for most workloads due to flexibility.

---

### Spot Instances

**Characteristics**
- Use spare EC2 capacity
- Up to 90% discount vs On-Demand
- Can be interrupted with 2-minute warning
- Price fluctuates based on supply/demand

**Use Cases**
- Fault-tolerant workloads
- Batch processing
- Big data analytics
- CI/CD pipelines
- Stateless web servers

**Not Suitable For**
- Databases
- Stateful applications without proper architecture
- Jobs that cannot be interrupted

**Pricing Example**
```
m6i.xlarge On-Demand: $0.192/hour
m6i.xlarge Spot (average): $0.058/hour
Savings: 70%
```

**Interruption Handling**

AWS provides a 2-minute warning via:
1. EC2 instance metadata
2. CloudWatch Events
3. EventBridge

**Best Practices**
- Use Spot Fleet for mixed instance types
- Implement checkpointing in applications
- Use Spot Instance interruption notices
- Combine with On-Demand for baseline capacity

---

### Dedicated Hosts & Dedicated Instances

**Dedicated Hosts**
- Physical server fully dedicated to your use
- Visibility into physical cores, sockets
- Use existing server-bound software licenses (Windows Server, SQL Server, SUSE Linux)
- Per-host billing
- Most expensive option

**Dedicated Instances**
- Instances run on hardware dedicated to a single customer
- May share hardware with other instances in the same account
- Per-instance billing
- No control over physical server placement

**Comparison**

| Feature | Dedicated Host | Dedicated Instance | Default (Shared) |
|---|---|---|---|
| Hardware | Fully dedicated physical server | Dedicated, but AWS-managed | Shared multi-tenant |
| Visibility | Sockets, cores, host ID | None | None |
| License | BYOL supported | Limited | No BYOL |
| Cost | Highest | High | Lowest |
| Use Case | Compliance, licensing | Compliance | Most workloads |

---

## 📍 Placement Groups

Control instance placement for performance or reliability.

**1. Cluster Placement Group**
- Instances placed close together in a single AZ
- **Benefit:** Lowest latency (10 Gbps+ network)
- **Use Cases:** HPC, tightly coupled applications, big data
- **Limitation:** Limited to single AZ
- **Failure Impact:** Single rack failure affects all

**2. Partition Placement Group**
- Instances spread across logical partitions
- Each partition on separate racks with independent network/power
- **Benefit:** Reduces correlated failures
- **Use Cases:** Distributed databases (Cassandra, Kafka), HDFS
- **Partitions:** Up to 7 per AZ
- **Max Instances:** Hundreds per group

**3. Spread Placement Group**
- Each instance on distinct hardware
- **Benefit:** Maximum availability
- **Use Cases:** Critical applications, small clusters
- **Limitation:** Max 7 instances per AZ per group
- **Isolation:** Each instance on a different rack

### Placement Strategy Selection

| Requirement | Placement Group |
|---|---|
| Lowest latency | Cluster |
| Distributed database | Partition |
| Critical single instances | Spread |
| No specific requirement | None (default) |

---

## 🌐 Enhanced Networking

Provides higher bandwidth, higher packet-per-second (PPS) performance, and lower latency.

**1. Elastic Network Adapter (ENA)**
- **Bandwidth:** Up to 100 Gbps
- **Instances:** Most current generation (m5, c5, r5, etc.)
- **Enabled:** By default on Amazon Linux AMI
- **Cost:** No additional charge

**2. Intel 82599 VF (Legacy)**
- **Bandwidth:** Up to 10 Gbps
- **Instances:** Older generation (c3, r3, etc.)
- **Status:** Being phased out

**Benefits**
- Lower latency
- Lower jitter
- Higher PPS
- Better network throughput

**Enabling Enhanced Networking**

```bash
# Check if enhanced networking is enabled
aws ec2 describe-instances \
    --instance-ids i-1234567890abcdef0 \
    --query 'Reservations[].Instances[].EnaSupport'

# Enable enhanced networking on AMI
aws ec2 modify-instance-attribute \
    --instance-id i-1234567890abcdef0 \
    --ena-support
```

---

## 🌍 Elastic IP Addresses

Static IPv4 addresses for dynamic cloud computing.

**Characteristics**
- **Persistence:** Remains associated with AWS account
- **Remapping:** Can be remapped between instances
- **Availability:** Maintains during instance stop/start
- **Limit:** 5 per region (soft limit)
- **Cost:** Free when associated with running instance, $0.005/hour when unassociated

**Use Cases**
- Failover between instances
- Whitelisting in firewalls
- DNS pointing to specific IP
- Recovering from instance failures

**Best Practices**
- Use Elastic Load Balancer instead when possible
- Release unused Elastic IPs to avoid charges
- Use for specific use cases, not routine deployments

---

## 🧾 Instance Metadata and User Data

### Instance Metadata

Access instance information from within the instance.

**Endpoint:** `http://169.254.169.254/latest/meta-data/`

**Available Information**
- AMI ID
- Instance ID
- Instance type
- Public/private IP addresses
- Security groups
- IAM role credentials
- User data

**Example**

```bash
# Get instance ID
curl http://169.254.169.254/latest/meta-data/instance-id

# Get IAM role credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/role-name

# Get availability zone
curl http://169.254.169.254/latest/meta-data/placement/availability-zone
```

### User Data

Script executed at instance launch (only once on first boot).

**Use Cases**
- Install software
- Configure settings
- Download application code
- Register with services

**Example**

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
```

---

## 💾 EC2 Storage Options

| Storage Type | Description |
|---|---|
| **EBS (Elastic Block Store)** | Persistent block storage, attached to a single instance, survives instance termination (if configured), snapshotable |
| **Instance Store** | Temporary block storage, physically attached to host, high I/O performance, data lost on stop/terminate/hardware failure |
| **EFS (Elastic File System)** | Network file system (NFS), shared across multiple instances, regional service (multi-AZ) |
| **FSx** | Managed file systems (Windows, Lustre, NetApp ONTAP, OpenZFS) |

---

## 🏭 Production-Level Knowledge

Managing hundreds or thousands of EC2 instances requires automation, standardization, and sophisticated tooling.

### Fleet Management at Scale

**AWS Systems Manager for Fleet Management**

Systems Manager provides a unified interface for managing EC2 fleets without SSH access.

Key capabilities:
1. **Session Manager** — Secure shell access
2. **Run Command** — Execute scripts at scale
3. **Patch Manager** — Automated patching
4. **State Manager** — Configuration compliance
5. **Inventory** — Asset management

### Advanced Auto Scaling Patterns

**Predictive Scaling**
Use ML to forecast traffic and scale proactively.

**Mixed Instances Policy (Spot + On-Demand)**

Benefits:
- 70% of capacity from Spot (huge savings)
- 30% from On-Demand (baseline reliability)
- Multiple instance types (flexibility)
- Capacity-optimized allocation (fewer interruptions)

**Lifecycle Hooks for Graceful Handling**
- Handle Auto Scaling lifecycle hooks
- Perform graceful shutdown or warmup tasks
- Termination hooks and launch hooks

### Disaster Recovery and High Availability

- Cross-region AMI copy automation
- Auto recovery for instance failures (via CloudWatch alarm or instance recovery configuration)

### Cost Optimization Strategies

- **Reserved Instance Planning Tool** — Analyze instance usage to recommend Reserved Instances
- **Spot Instance Best Practices** — Create Spot Fleet with diversified instance types

---

## 💡 Tips & Best Practices

### Instance Type Selection Tips

**Tip 1: Start with Burstable Instances for Variable Workloads**

For workloads with variable CPU usage (web servers, dev environments):
- Use T3/T4g instances
- Monitor CPU credits
- Switch to M5 if consistently bursting

```bash
# Monitor CPU credit balance
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUCreditBalance \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 3600 \
    --statistics Average \
    --query 'Datapoints[*].[Timestamp,Average]' \
    --output table
```

**Tip 2: Use Graviton (ARM) Instances for Cost Savings**

Graviton2/3 instances (T4g, M6g, C6g, R6g) offer:
- Up to 40% better price-performance
- Lower power consumption
- Compatible with most Linux workloads

```bash
# Test if your application works on ARM
docker run --platform linux/arm64 your-image:tag

# For compiled applications, recompile for ARM64
gcc -march=armv8-a your-app.c -o your-app
```

**Tip 3: Right-Size Regularly** — Analyze instance utilization and suggest right-sizing.

### AMI Management Tips

**Tip 4: Implement AMI Lifecycle Management** — Automate cleanup of old AMIs on a schedule.

**Tip 5: Version Your AMIs**

```bash
# Good naming convention
MyApp-v1.2.3-20250115-prod
MyApp-v1.2.3-20250115-hotfix

# Tag with metadata
aws ec2 create-tags \
    --resources $AMI_ID \
    --tags Key=Version,Value=1.2.3 \
           Key=GitCommit,Value=abc123 \
           Key=BuildDate,Value=2025-01-15 \
           Key=Environment,Value=production
```

**Tip 6: Test AMIs Before Production** — Launch a test instance, run automated tests, then promote or fix.

### Auto Scaling Tips

**Tip 7: Use Multiple Scaling Policies** — Combine target tracking (baseline), step scaling (aggressive), and scheduled scaling (known patterns).

**Tip 8: Set Appropriate Cooldown Periods**

```bash
# Default cooldown (applies to simple scaling)
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name myapp-asg \
    --default-cooldown 300 \
    ...
```

**Tip 9: Use Termination Policies Strategically**

```bash
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name myapp-asg \
    --termination-policies \
        OldestLaunchTemplate \
        OldestInstance
```

Available termination policies:
- `OldestInstance` — Terminate oldest instance
- `NewestInstance` — Terminate newest instance
- `OldestLaunchConfiguration`/`OldestLaunchTemplate` — Oldest config
- `ClosestToNextInstanceHour` — Minimize billing
- `Default` — Balanced across AZs, then oldest launch config
- `AllocationStrategy` — For Spot instances

### Security Tips

**Tip 10: Never Store Credentials in AMIs**

```bash
# Bad - credentials in AMI
echo "API_KEY=secret123" >> /etc/environment

# Good - use Parameter Store or Secrets Manager
aws ssm get-parameter \
    --name /myapp/api-key \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text
```

**Tip 11: Use IMDSv2 for Enhanced Security** — Require IMDSv2 on new instances and update existing ones.

**Tip 12: Encrypt EBS Volumes by Default** — Enable account-level default EBS encryption and encrypt existing volumes.

### Monitoring Tips

**Tip 13: Enable Detailed Monitoring for Production** — At launch and for existing instances.

**Tip 14: Create Custom CloudWatch Dashboards** — Build dashboards with CPU utilization and network traffic widgets.

**Tip 15: Set Up Status Check Alarms with Auto-Recovery** — Cover both system status checks (AWS infrastructure issues) and instance status checks (guest OS/network issues).

### Cost Optimization Tips

**Tip 16: Use Savings Plans Over Reserved Instances** — Calculate commitment based on steady-state usage, not peak.

**Tip 17: Leverage Spot Instances for Fault-Tolerant Workloads** — Check Spot price history and request Spot with a max price.

**Tip 18: Implement Instance Scheduling**

```
Running 24/7:                              $140/month
Running business hours only (12h/5d):      $42/month
Savings:                                   $98/month per instance
```

**Tip 19: Delete Unused Resources** — Find stopped instances (still incurring EBS costs), unattached EBS volumes, and unused Elastic IPs.

**Tip 20: Use AWS Compute Optimizer** — Get right-sizing recommendations for instances.

---

## ⚠️ Pitfalls & Remedies

### Pitfall 1: Selecting Wrong Instance Type for Workload

**Problem:** Choosing instance types based on familiarity rather than workload requirements, leading to over- or under-provisioning.

**Why It Happens**
- Defaulting to "safe" choices (e.g., always using m5.large)
- Not understanding workload characteristics
- Copying instance types from other projects
- Not testing different options

**Impact**
- Wasted money on over-provisioned resources
- Poor performance from under-provisioned resources
- Inability to scale effectively
- High latency for end users

**Example**

```
Scenario: Machine learning inference application

Wrong Choice: m5.xlarge ($140/month)
 - General purpose instance
 - CPU-based inference (slow)
 - No GPU acceleration

Right Choice: g4dn.xlarge ($390/month) or inf1.xlarge ($210/month)
 - GPU/Inferentia acceleration
 - 10x faster inference
 - Better cost per inference
```

**Remedy**
1. Profile your workload (CPU, memory, disk I/O, network, application-level)
2. Match instance family to workload characteristics
3. Use AWS Compute Optimizer recommendations
4. Test multiple instance types with load tests before selecting

**Prevention:** Always profile workloads before selecting instance types, use Compute Optimizer, test multiple types during development, review quarterly, and document selection rationale.

---

### Pitfall 2: Not Implementing Graceful Shutdown

**Problem:** Applications terminated abruptly without completing in-flight requests or saving state, leading to data loss or inconsistent state.

**Why It Happens**
- Not handling termination signals
- Assuming instances will run forever
- No graceful shutdown logic in application
- Not using Auto Scaling lifecycle hooks

**Impact**
- Lost transactions
- Corrupted data
- Poor user experience
- Difficult troubleshooting

**Remedy**
1. Handle termination signals in application code
2. Implement a systemd service for proper shutdown
3. Use Auto Scaling lifecycle hooks (with a Lambda handler)
4. Test graceful shutdown manually and via Auto Scaling

**Prevention:** Implement graceful shutdown from day one, test regularly, monitor shutdown times, use lifecycle hooks, and document procedures.

---

### Pitfall 3: Improper Use of User Data

**Problem:** User data scripts failing silently, running on every boot instead of once, or containing sensitive information in plain text.

**Why It Happens**
- No error handling in user data scripts
- Misunderstanding user data execution (runs only on first boot)
- Embedding secrets directly in user data
- No logging or debugging mechanisms

**Impact**
- Instances not properly configured
- Security vulnerabilities from exposed secrets
- Difficult troubleshooting
- Inconsistent instance state

**Remedy**
1. Use a proper user data script structure
2. Use cloud-init for more control
3. Never embed secrets in user data
4. Debug user data failures via logs
5. Use Systems Manager Run Command for complex post-launch configuration

**Prevention:** Use configuration management tools (Ansible, Chef, Puppet), never embed secrets, always log execution, test scripts before deployment, and consider Systems Manager for post-launch configuration.

---

### Pitfall 4: Not Monitoring and Rightsizing Instances

**Problem:** Running instances at wrong sizes indefinitely, wasting money on over-provisioned resources or suffering performance issues from under-provisioned instances.

**Why It Happens**
- "Set it and forget it" mentality
- No regular review process
- Lack of monitoring and alerting
- Fear of impacting production
- Not understanding current resource usage

**Impact**
- Wasted budget on over-provisioned instances (30–50% waste common)
- Poor application performance from under-sized instances
- Failed capacity planning
- Budget overruns

**Example**

```
Running Instance: m5.2xlarge (8 vCPUs, 32 GiB RAM)
Cost: $280/month

Actual Usage:
- CPU: 15% average
- Memory: 8 GB used (25%)
- Network: Minimal

Right Size: t3.large (2 vCPUs, 8 GiB RAM)
Cost: $60/month
Savings: $220/month (78%)

Annual Savings per instance: $2,640
```

**Remedy**
1. Implement continuous monitoring (CPU, memory via CloudWatch agent, network)
2. Automate rightsizing to safely resize instances
3. Schedule weekly rightsizing analysis via Lambda

**Prevention:** Enable AWS Compute Optimizer, schedule monthly reviews, automate monitoring/alerting, use CloudWatch dashboards, implement gradual rollout, and test in non-production first.

---

### Pitfall 5: Not Implementing Proper Backup Strategy

**Problem:** No backups, inconsistent backups, or backups not tested for recovery, leading to data loss during disasters.

**Why It Happens**
- Assuming AWS automatically backs up everything
- No clear backup requirements
- Manual backup processes that get skipped
- Cost concerns about backup storage
- No testing of backup restoration

**Impact**
- Catastrophic data loss
- Extended downtime during recovery
- Regulatory compliance failures
- Unable to meet RPO/RTO requirements
- Business continuity failures

**Remedy**
1. Implement AWS Backup (vault, plan, selection, tags)
2. Implement application-consistent backups using pre/post scripts
3. Implement cross-region backup replication
4. Automate backup monitoring to check for recent successful backups

**Prevention:** Enable AWS Backup for critical resources, tag resources for automated backup, test restoration monthly, monitor compliance daily, replicate cross-region, document RPO/RTO, and automate backup testing.

---

### Pitfall 6: Ignoring Instance Metadata Security

**Problem:** Not securing the Instance Metadata Service (IMDS), allowing attackers to steal IAM credentials if they gain access to the instance.

**Why It Happens**
- Using default IMDSv1 (less secure)
- Not understanding IMDS security implications
- Legacy applications that don't support IMDSv2
- No security hardening process

**Impact**
- IAM credential theft via SSRF attacks
- Privilege escalation
- Lateral movement in AWS environment
- Data exfiltration

**Attack Example**

```bash
# Attacker exploits SSRF vulnerability in application
# Using IMDSv1 (no token required)
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/MyRole

# Returns temporary credentials
{
 "AccessKeyId": "ASIAIOSFODNN7EXAMPLE",
 "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
 "Token": "very-long-token",
 "Expiration": "2025-01-15T12:00:00Z"
}

# Attacker now has your IAM role credentials
```

**Remedy**
1. Require IMDSv2 on all instances
2. Update applications for IMDSv2
3. Audit IMDS configuration across the fleet
4. Implement IMDS firewall rules (e.g., restrict access from containers)
5. Monitor IMDS access

**Prevention:** Require IMDSv2 on all new instances, migrate existing instances, run regular security audits, keep SDKs updated, implement defense-in-depth, and monitor IMDS access.

---

## 📌 Summary

Amazon EC2 is the cornerstone of AWS compute services, providing flexible, scalable virtual servers for virtually any workload. Success with EC2 requires deep understanding of instance types, pricing models, AMI management, Auto Scaling, and operational best practices.

### Key Takeaways

- **Choose instance types based on workload characteristics** — Profile your applications to match CPU, memory, storage, and network requirements to the appropriate instance family
- **Leverage multiple pricing models** — Use On-Demand for flexibility, Reserved Instances or Savings Plans for steady-state workloads, and Spot Instances for fault-tolerant applications
- **Automate with Auto Scaling** — Implement Auto Scaling Groups with appropriate scaling policies to handle variable load while maintaining availability
- **Master AMI management** — Create standardized AMIs for consistent deployments, version them properly, and implement lifecycle management
- **Implement comprehensive monitoring** — Use CloudWatch with custom metrics, set up meaningful alarms, and create dashboards for operational visibility
- **Prioritize security** — Use IMDSv2, implement proper IAM roles, encrypt volumes, and follow least-privilege principles
- **Plan for disaster recovery** — Implement automated backups, test restoration procedures, and replicate critical data across regions
- **Right-size continuously** — Regularly analyze utilization and adjust instance types to optimize performance and cost

Understanding EC2 deeply enables you to build cost-effective, highly available, and performant applications in AWS. The compute foundation you've built here will support your entire cloud architecture.

---

## 🧪 Hands-On Lab Exercise

**Objective:** Build a production-ready, auto-scaling web application with monitoring, backups, and cost optimization.

### Architecture

```
Internet → ALB → Auto Scaling Group (2-10 t3.medium instances)
                ↓
       CloudWatch Monitoring + Alarms
                ↓
       SNS Notifications
                ↓
    AWS Backup (Daily snapshots)
```

### Exercise Steps

1. **Create Custom AMI**
   - Launch base instance
   - Install and configure web application
   - Harden security settings
   - Create AMI with proper naming and tags

2. **Configure Auto Scaling**
   - Create Launch Template with user data
   - Create Auto Scaling Group (min: 2, max: 10, desired: 3)
   - Configure target tracking scaling (CPU @ 50%)
   - Set up lifecycle hooks for graceful shutdown

3. **Deploy Load Balancer**
   - Create Application Load Balancer
   - Configure target group with health checks
   - Set up listener rules

4. **Implement Monitoring**
   - Enable detailed monitoring
   - Install CloudWatch agent for custom metrics
   - Create dashboard with key metrics
   - Set up alarms for CPU, memory, disk, status checks

5. **Configure Backups**
   - Set up AWS Backup plan
   - Tag instances for automated backup
   - Test backup restoration

6. **Cost Optimization**
   - Analyze instance utilization
   - Generate rightsizing recommendations
   - Implement instance scheduling for non-prod

7. **Test and Validate**
   - Run load test to trigger scaling
   - Verify monitoring and alarms
   - Test graceful shutdown
   - Validate backup restoration

### Expected Outcomes

- Fully functional auto-scaling application
- Comprehensive monitoring and alerting
- Automated backup strategy
- Cost optimization plan

### Cleanup

- Delete Auto Scaling Group
- Delete Load Balancer
- Delete Launch Template
- Deregister AMI

---

## ❓ Review Questions

<details>
<summary><strong>1. Which instance family is best for applications requiring high memory-to-CPU ratio?</strong></summary>

a) C5 (Compute Optimized) b) M5 (General Purpose) c) **R5 (Memory Optimized)** d) T3 (Burstable)

**Answer: C** — R5 instances are memory-optimized with high memory-to-CPU ratios, ideal for in-memory databases and analytics.
</details>

<details>
<summary><strong>2. What is the primary difference between On-Demand and Spot instances?</strong></summary>

a) Spot instances are faster b) **Spot instances can be interrupted with 2-minute notice** c) On-Demand instances are regional d) Spot instances have guaranteed capacity

**Answer: B** — Spot instances use spare capacity and can be interrupted with 2-minute warning when AWS needs the capacity back.
</details>

<details>
<summary><strong>3. Which pricing model offers the most flexibility?</strong></summary>

a) Reserved Instances b) Savings Plans c) Dedicated Hosts d) **On-Demand**

**Answer: D** — On-Demand has no commitment and highest flexibility, though it's the most expensive.
</details>

<details>
<summary><strong>4. What happens to instance store data when an instance is stopped?</strong></summary>

a) Data persists b) **Data is lost** c) Data is moved to EBS d) Data is archived to S3

**Answer: B** — Instance store data is ephemeral and lost when instance is stopped, terminated, or if underlying hardware fails.
</details>

<details>
<summary><strong>5. Which placement group type provides the lowest network latency?</strong></summary>

a) Spread b) Partition c) **Cluster** d) Default

**Answer: C** — Cluster placement groups place instances close together in a single AZ for lowest latency and highest throughput.
</details>

<details>
<summary><strong>6. What is the benefit of using IMDSv2 over IMDSv1?</strong></summary>

a) Faster metadata retrieval b) More metadata available c) **Protection against SSRF attacks** d) No difference

**Answer: C** — IMDSv2 requires session tokens, providing defense-in-depth protection against SSRF attacks.
</details>

<details>
<summary><strong>7. How often does EC2 user data run by default?</strong></summary>

a) Every boot b) **Only on first launch** c) When instance is stopped/started d) Never automatically

**Answer: B** — User data runs only once on first launch by default (can be configured to run on every boot with cloud-init).
</details>

<details>
<summary><strong>8. Which Auto Scaling policy type is best for predictable traffic patterns?</strong></summary>

a) Target tracking b) Step scaling c) **Scheduled scaling** d) Simple scaling

**Answer: C** — Scheduled scaling is ideal for known, predictable traffic patterns (e.g., scale up every morning).
</details>

<details>
<summary><strong>9. What is the maximum spot instance discount compared to On-Demand?</strong></summary>

a) 50% b) 70% c) **90%** d) 95%

**Answer: C** — Spot instances can provide up to 90% discount compared to On-Demand pricing.
</details>

<details>
<summary><strong>10. Which service provides automated patching for EC2 fleets?</strong></summary>

a) AWS Backup b) **AWS Systems Manager Patch Manager** c) CloudWatch d) AWS Config

**Answer: B** — AWS Systems Manager Patch Manager provides automated patching with maintenance windows and compliance tracking.
</details>

<details>
<summary><strong>11. What is the benefit of using Savings Plans over Reserved Instances?</strong></summary>

a) Higher discount b) **More flexibility across instance families** c) No commitment required d) Free cancellation

**Answer: B** — Compute Savings Plans provide flexibility across instance families, sizes, regions, and even Lambda/Fargate.
</details>

<details>
<summary><strong>12. Which metric is NOT available by default in CloudWatch for EC2?</strong></summary>

a) CPU Utilization b) Network In/Out c) **Memory Utilization** d) Disk Read/Write Ops

**Answer: C** — Memory utilization requires CloudWatch agent installation as it's not visible to the hypervisor.
</details>

<details>
<summary><strong>13. What is the purpose of an EC2 launch template?</strong></summary>

a) Create AMIs b) **Define instance configuration for launching** c) Monitor instances d) Backup instances

**Answer: B** — Launch templates define instance configuration (AMI, instance type, security groups, etc.) for consistent launches.
</details>

<details>
<summary><strong>14. Which statement about EBS-backed AMIs is TRUE?</strong></summary>

a) Cannot be stopped b) Root volume is ephemeral c) **Can be stopped without data loss** d) Slower boot times than instance-store

**Answer: C** — EBS-backed instances can be stopped and started without losing data from EBS volumes.
</details>

<details>
<summary><strong>15. What is the recommended way to access EC2 instances without SSH keys?</strong></summary>

a) EC2 Instance Connect b) **AWS Systems Manager Session Manager** c) VNC d) Remote Desktop

**Answer: B** — Systems Manager Session Manager provides secure, auditable access without managing SSH keys or bastion hosts.
</details>

---

<p align="center"><sub>Compiled from personal EC2 study notes · AWS Solutions Architect prep</sub></p>
