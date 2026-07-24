# AWS Systems Manager

> Unified operational management for AWS and on-premises infrastructure — secure access, centralized configuration, fleet command execution, and automated patching.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Systems Manager Architecture](#systems-manager-architecture)
3. [Session Manager](#session-manager)
4. [Parameter Store](#parameter-store)
5. [Run Command](#run-command)
6. [Patch Manager](#patch-manager)
7. [Cost Optimization](#cost-optimization)
8. [Tips & Best Practices](#tips--best-practices)
9. [Pitfalls & Remedies](#pitfalls--remedies)
10. [Summary](#summary)
11. [Hands-On Lab Exercise](#hands-on-lab-exercise)
12. [Review Questions](#review-questions)

---

## Introduction

Managing thousands of EC2 instances, applying security patches across fleets, maintaining configuration consistency, troubleshooting servers without SSH keys, and tracking infrastructure changes manually is operationally impossible at scale. Traditional IT management — logging into servers individually, maintaining spreadsheets of server inventory, manual patch deployments taking weeks, SSH key distribution creating security risks — cannot support modern cloud infrastructure where servers are ephemeral, fleets scale dynamically, and security vulnerabilities require immediate remediation.

**AWS Systems Manager** provides unified operational management through automated patching, secure shell access without SSH keys, centralized parameter storage, configuration management, and operational insights that transform infrastructure management from reactive firefighting to proactive automation.

### The Cost of Manual Management

The operational cost of manual server management extends beyond labor hours:

- Average time to patch critical vulnerabilities takes **38 days manually**, exposing organizations to exploits
- Server sprawl creates inconsistent configurations leading to outages
- SSH key management becomes a security liability with shared keys and orphaned access
- Troubleshooting requires VPN access and jump hosts, complicating incident response

Systems Manager eliminates these challenges through:

| Component | Purpose |
|---|---|
| **Session Manager** | Secure browser-based shell access without SSH keys |
| **Patch Manager** | Automated operating system and application patching |
| **Parameter Store** | Encrypted configuration and secrets management |
| **Run Command** | Executing commands across fleets instantly |
| **State Manager** | Ensuring configuration compliance continuously |

### Ecosystem Integration

Systems Manager integrates with:

- **CloudWatch** — operational dashboards
- **CloudTrail** — audit logging
- **Config** — compliance checking
- **IAM** — access control
- **KMS** — encryption

Parameter Store stores database credentials rotated by Secrets Manager, Patch Manager updates EC2 instances monitored by CloudWatch, Session Manager provides access logged by CloudTrail, and Automation documents orchestrate responses to Security Hub findings.

This chapter covers: Systems Manager architecture, SSM Agent, Session Manager secure access, Parameter Store hierarchies, Secrets Manager integration, Run Command fleet management, Patch Manager baselines and maintenance windows, State Manager associations, Automation documents, OpsCenter incident management, and Change Calendar approval workflows.

---

## Systems Manager Architecture

### Core Components

**Purpose:** Unified operations management for AWS and on-premises infrastructure.

**Key Capabilities:**

1. **Operations Management** — View operational data
2. **Application Management** — Manage applications and configurations
3. **Change Management** — Automate changes safely
4. **Node Management** — Manage EC2 and on-premises servers
5. **Shared Resources** — Documents and parameters

### Systems Manager Agent (SSM Agent)

**Purpose:** Software agent running on managed instances.

**Functions:**
- Receives commands from Systems Manager
- Executes automation documents
- Reports inventory and status
- Sends logs to CloudWatch

**Supported Platforms:**
- Amazon Linux, Ubuntu, RHEL, SUSE (pre-installed)
- Windows Server
- macOS
- On-premises servers (hybrid activation)

**Communication:**
```
Instance → SSM Agent → Systems Manager Service
```
- Outbound HTTPS only (no inbound ports)
- No SSH/RDP keys needed
- Uses IAM instance profile for authentication

### Managed Instance Requirements

1. SSM Agent installed and running
2. IAM instance profile with `AmazonSSMManagedInstanceCore`
3. Network connectivity to Systems Manager endpoints
4. Operating system supported

### Systems Manager Endpoints

| Endpoint | Purpose |
|---|---|
| `ssm.region.amazonaws.com` | Main service |
| `ssmmessages.region.amazonaws.com` | Session Manager |
| `ec2messages.region.amazonaws.com` | Run Command |

**VPC Endpoints (Private Subnets):**
- Create VPC endpoints for Systems Manager
- No NAT Gateway required
- Reduces data transfer costs

### Architecture Diagram

```
Managed Instances (EC2, On-Premises)
    ↓ (SSM Agent)
Systems Manager Service
    ├── Session Manager (secure shell)
    ├── Run Command (execute commands)
    ├── Patch Manager (automated patching)
    ├── State Manager (configuration compliance)
    ├── Automation (orchestration)
    ├── Parameter Store (configuration data)
    └── OpsCenter (incident management)
    ↓
Integration Points:
    ├── CloudWatch (logs, metrics, dashboards)
    ├── CloudTrail (audit trail)
    ├── Config (compliance)
    ├── EventBridge (event-driven automation)
    └── SNS (notifications)
```

---

## Session Manager

### Secure Shell Access Without SSH Keys

**Purpose:** Browser-based shell access to managed instances — no SSH keys, bastion hosts, or open inbound ports required.

### Benefits vs Traditional SSH

| Traditional SSH | Session Manager |
|---|---|
| ✗ SSH keys to manage and distribute | ✓ No SSH keys required |
| ✗ Bastion hosts to maintain | ✓ No bastion hosts needed |
| ✗ Inbound port 22 open (security risk) | ✓ No inbound ports open |
| ✗ VPN required for remote access | ✓ Browser-based access (no VPN) |
| ✗ Limited audit trail | ✓ Complete CloudTrail audit trail |
| ✗ Key sprawl and orphaned access | ✓ IAM-based access control + session recording to S3 |

### Access Methods

**1. AWS Console**
- Navigate to Systems Manager → Session Manager → choose instance → Start session

**2. AWS CLI**
```bash
aws ssm start-session \
    --target i-1234567890abcdef0
```

**3. SSH Replacement (with SSH client)**
```bash
ssh -i /path/to/key ec2-user@i-1234567890abcdef0
# Tunneled through Systems Manager
# No SSH keys actually used
```

### Session Features

**Interactive Shell**
- Bash/PowerShell based on OS
- Full command execution, tab completion, command history

**Port Forwarding**
- Forward local port to instance port
- Access RDS, ElastiCache, etc. without a bastion host

Example — access RDS through EC2:
```bash
aws ssm start-session \
    --target i-1234567890abcdef0 \
    --document-name AWS-StartPortForwardingSession \
    --parameters "portNumber=3306,localPortNumber=9999"

# Connect to RDS
mysql -h 127.0.0.1 -P 9999 -u admin -p
```

### Logging and Auditing

**CloudTrail Logging** — every session start/end logged (user, instance, start time, duration).

**Session Recording** — record entire session to S3 for review and compliance.

```json
{
  "s3BucketName": "session-logs-bucket",
  "s3KeyPrefix": "session-recordings/",
  "s3EncryptionEnabled": true,
  "cloudWatchLogGroupName": "/aws/ssm/session-logs",
  "cloudWatchEncryptionEnabled": true,
  "kmsKeyId": "alias/session-encryption-key"
}
```

### IAM Policy for Session Manager

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ssm:StartSession"],
      "Resource": ["arn:aws:ec2:*:*:instance/i-*"],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        },
        "StringLike": {
          "ssm:resourceTag/Environment": "Production"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:TerminateSession", "ssm:ResumeSession"],
      "Resource": "arn:aws:ssm:*:*:session/${aws:username}-*"
    }
  ]
}
```

**Access Control:**
- ✓ Tag-based access (`Environment=Production`)
- ✓ Instance-level permissions
- ✓ Region restrictions
- ✓ User can only terminate own sessions

### Use Cases

1. **Emergency Access** — server unresponsive, no SSH key available, start a browser session immediately
2. **Compliance** — no SSH keys to audit; all sessions recorded with a complete audit trail
3. **Troubleshooting** — quick access without VPN or bastion setup; port forwarding for database access
4. **Multi-User Access** — IAM-based permissions, no shared credentials, individual accountability

---

## Parameter Store

### Centralized Configuration and Secrets Management

**Purpose:** Store configuration data and secrets with hierarchical organization, KMS encryption, version history, and a free tier.

### Parameter Types

| Type | Description | Example |
|---|---|---|
| **String** | Plain text values / configuration settings | Database endpoint |
| **StringList** | Comma-separated values | Allowed IP addresses |
| **SecureString** | Encrypted with KMS, auto-decrypted on retrieval | Database password |

### Parameter Tiers

| Feature | Standard (Free) | Advanced ($0.05/parameter/month) |
|---|---|---|
| Max parameters | 10,000 per account | 100,000 |
| Max value size | 4 KB | 8 KB |
| Parameter policies | No | Yes (expiration, notifications) |
| Throughput | Standard | Higher |

### Parameter Store vs Secrets Manager

| Feature | Parameter Store | Secrets Manager |
|---|---|---|
| Cost (standard) | Free | $0.40/secret/mo |
| Rotation | Manual | Automatic ✓ |
| RDS integration | No | Native ✓ |
| Cross-account | Limited | Yes ✓ |
| Versioning | Basic | Full ✓ |
| Max size | 4–8 KB | 64 KB |
| Use case | Configuration | Secrets/rotation |

### Hierarchical Organization

```
/application/
├── /production/
│   ├── /database/
│   │   ├── endpoint
│   │   ├── username
│   │   └── password (SecureString)
│   ├── /api/
│   │   ├── base-url
│   │   └── api-key (SecureString)
│   └── /feature-flags/
│       ├── enable-new-feature
│       └── rate-limit
├── /staging/
│   ├── /database/
│   │   └── ...
│   └── /api/
│       └── ...
└── /development/
    └── ...
```

**Benefits:**
- ✓ Organized by environment
- ✓ Easy to retrieve all parameters for a path
- ✓ Permissions by path hierarchy
- ✓ Clear naming convention

### Creating Parameters

```bash
# String parameter
aws ssm put-parameter \
    --name "/myapp/production/database/endpoint" \
    --value "mydb.cluster-abc.us-east-1.rds.amazonaws.com" \
    --type "String" \
    --description "Production database endpoint"

# SecureString parameter (encrypted)
aws ssm put-parameter \
    --name "/myapp/production/database/password" \
    --value "MySecurePassword123!" \
    --type "SecureString" \
    --key-id "alias/parameter-store-key" \
    --description "Production database password"
```

### Retrieving Parameters

```bash
# Get single parameter
aws ssm get-parameter \
    --name "/myapp/production/database/endpoint"

# Get parameter with decryption
aws ssm get-parameter \
    --name "/myapp/production/database/password" \
    --with-decryption

# Get all parameters by path
aws ssm get-parameters-by-path \
    --path "/myapp/production/database" \
    --recursive \
    --with-decryption
```

### Application Integration

```python
import boto3
import time

ssm = boto3.client('ssm')

# Get parameter
response = ssm.get_parameter(
    Name='/myapp/production/database/endpoint'
)
db_endpoint = response['Parameter']['Value']

# Get encrypted parameter
response = ssm.get_parameter(
    Name='/myapp/production/database/password',
    WithDecryption=True
)
db_password = response['Parameter']['Value']

# Cache parameters (reduce API calls)
class ParameterCache:
    def __init__(self, ttl=300):  # 5-minute TTL
        self.cache = {}
        self.ttl = ttl

    def get_parameter(self, name, decrypt=False):
        # Check cache
        if name in self.cache:
            value, timestamp = self.cache[name]
            if time.time() - timestamp < self.ttl:
                return value

        # Cache miss - retrieve from SSM
        response = ssm.get_parameter(
            Name=name,
            WithDecryption=decrypt
        )
        value = response['Parameter']['Value']

        # Update cache
        self.cache[name] = (value, time.time())
        return value

# Usage
cache = ParameterCache(ttl=300)
db_endpoint = cache.get_parameter('/myapp/production/database/endpoint')
```

### Parameter Policies (Advanced Tier)

```json
// Expiration notification
{
  "Type": "Expiration",
  "Version": "1.0",
  "Attributes": {
    "Timestamp": "2025-12-31T23:59:59.000Z"
  }
}
```

```json
// Notification before expiration
{
  "Type": "ExpirationNotification",
  "Version": "1.0",
  "Attributes": {
    "Before": "30",
    "Unit": "Days"
  }
}
```

### Use Cases

1. **Application Configuration** — database endpoints, API URLs, feature flags, environment-specific settings
2. **Secrets (Non-Rotating)** — third-party API keys, license keys, static credentials
3. **Infrastructure Automation** — CloudFormation parameters, Lambda environment variables, ECS task definitions
4. **Sharing Across Services** — consistent configuration across Lambda functions and EC2 instances

---

## Run Command

### Fleet Command Execution

**Purpose:** Execute commands on managed instances at scale — no SSH required, centralized execution and logging.

### Capabilities

**Execute Commands:**
- Shell scripts (Linux/macOS)
- PowerShell scripts (Windows)
- AWS-provided documents
- Custom documents

**Target Selection:**
- Instance IDs, tags, resource groups, or all instances

**Execution Control:**
- Concurrency control (percent or absolute)
- Error threshold (stop if too many failures)
- Rate control (prevent overwhelming targets)

### Common Use Cases

1. **Install/Update Software** — CloudWatch agent, application versions, security agents
2. **Configuration Changes** — modify config files, restart services, change permissions
3. **Data Collection** — gather logs, check system status, inventory software
4. **Security Operations** — malware scans, security patches, vulnerability checks

### AWS-Provided Documents

| Document | Purpose |
|---|---|
| `AWS-RunShellScript` | Execute bash commands (Linux) |
| `AWS-RunPowerShellScript` | Execute PowerShell commands (Windows) |
| `AWS-ConfigureAWSPackage` | Install/update AWS packages (CloudWatch agent, Inspector agent) |
| `AWS-RunPatchBaseline` | Apply patches from Patch Manager baseline |

```bash
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --targets "Key=tag:Environment,Values=Production" \
    --parameters "commands=['df -h','uptime','who']" \
    --comment "Check disk space and uptime"
```

### Custom Documents

YAML format defining commands to execute. Example — install CloudWatch Agent:

```yaml
---
schemaVersion: '2.2'
description: Install CloudWatch Agent
mainSteps:
- action: aws:runShellScript
  name: InstallCloudWatchAgent
  inputs:
    runCommand:
    - wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    - rpm -U ./amazon-cloudwatch-agent.rpm
    - /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/cloudwatchagent/config
```

### Execution Example

```python
import boto3
import time

ssm = boto3.client('ssm')

# Send command
response = ssm.send_command(
    DocumentName='AWS-RunShellScript',
    Targets=[{'Key': 'tag:Environment', 'Values': ['Production']}],
    Parameters={
        'commands': [
            'sudo yum update -y',
            'sudo systemctl restart nginx'
        ]
    },
    MaxConcurrency='50%',   # Run on 50% at a time
    MaxErrors='10%',        # Stop if >10% fail
    TimeoutSeconds=600,
    Comment='Update and restart nginx'
)

command_id = response['Command']['CommandId']

# Check execution status
while True:
    result = ssm.list_command_invocations(CommandId=command_id)
    statuses = [inv['Status'] for inv in result['CommandInvocations']]

    if all(status in ['Success', 'Failed', 'Cancelled'] for status in statuses):
        break
    time.sleep(5)

# Get output
for invocation in result['CommandInvocations']:
    instance_id = invocation['InstanceId']
    status = invocation['Status']
    print(f"{instance_id}: {status}")

    if status == 'Failed':
        output = ssm.get_command_invocation(
            CommandId=command_id,
            InstanceId=instance_id
        )
        print(f"  Error: {output['StandardErrorContent']}")
```

### Output Logging

- **CloudWatch Logs** — all command output sent to CloudWatch, searchable with Logs Insights, configurable retention
- **S3 Storage** — command output stored for long-term archival and compliance

### Rate Control

**Concurrency:**
- Absolute: `"10"` (10 instances simultaneously)
- Percentage: `"25%"` (25% of targets)

**Error Threshold:**
- Absolute: `"5"` (stop after 5 failures)
- Percentage: `"10%"` (stop if >10% fail)

Example — rolling update:
```
MaxConcurrency: "1"   # One instance at a time
MaxErrors: "0"        # Stop on any failure
Result: Safe, sequential updates
```

### Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:ListCommands",
        "ssm:ListCommandInvocations"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:GetCommandInvocation"],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ssm:resourceTag/Environment": "Production"
        }
      }
    }
  ]
}
```

---

## Patch Manager

### Automated OS and Application Patching

**Purpose:** Automate patching of operating systems and applications, with compliance reporting and scheduled maintenance windows.

### Key Concepts

1. **Patch Baseline** — rules for automatic patch approval, severity levels, auto-approval delay (test before production), rejected patches list
2. **Maintenance Window** — scheduled time for patching, prevents patching during business hours, concurrency/error controls, SNS notifications
3. **Patch Groups** — tag-based grouping (`Patch Group` tag), different baselines per group (Production, Development, Testing)

### Patch Baseline Configuration

**Default Baselines (AWS-Provided):**
- `AWS-DefaultPatchBaseline` (all OS updates)
- `AWS-WindowsDefaultPatchBaseline`
- `AWS-AmazonLinux2DefaultPatchBaseline`
- `AWS-UbuntuDefaultPatchBaseline`

**Custom Baseline Example:**

```json
{
  "Name": "Production-CriticalOnly-Baseline",
  "Description": "Critical and security patches only",
  "OperatingSystem": "AMAZON_LINUX_2",
  "ApprovalRules": {
    "PatchRules": [
      {
        "PatchFilterGroup": {
          "PatchFilters": [
            { "Key": "CLASSIFICATION", "Values": ["Security", "Bugfix"] },
            { "Key": "SEVERITY", "Values": ["Critical", "Important"] }
          ]
        },
        "ComplianceLevel": "CRITICAL",
        "ApproveAfterDays": 7,
        "EnableNonSecurity": false
      }
    ]
  },
  "RejectedPatches": ["CVE-2024-12345"]
}
```

**Creating Baseline:**

```python
ssm.create_patch_baseline(
    Name='Production-CriticalOnly-Baseline',
    Description='Critical and security patches only',
    OperatingSystem='AMAZON_LINUX_2',
    ApprovalRules={
        'PatchRules': [
            {
                'PatchFilterGroup': {
                    'PatchFilters': [
                        {'Key': 'CLASSIFICATION', 'Values': ['Security', 'Bugfix']},
                        {'Key': 'SEVERITY', 'Values': ['Critical', 'Important']}
                    ]
                },
                'ApproveAfterDays': 7,
                'EnableNonSecurity': False
            }
        ]
    }
)
```

### Patch Groups

```python
# Tag production instances
ec2.create_tags(
    Resources=['i-1234567890abcdef0'],
    Tags=[
        {'Key': 'Patch Group', 'Value': 'Production'},
        {'Key': 'Environment', 'Value': 'Production'}
    ]
)

# Associate baseline with patch group
ssm.register_patch_baseline_for_patch_group(
    BaselineId='pb-abc123',
    PatchGroup='Production'
)
```

### Maintenance Window

```python
# Create scheduled patching window
ssm.create_maintenance_window(
    Name='Production-Patching-Window',
    Description='Weekly patching for production servers',
    Schedule='cron(0 2 ? * SUN *)',   # Sunday 2 AM UTC
    Duration=4,                        # 4 hours
    Cutoff=1,                          # Stop new tasks 1 hour before end
    AllowUnassociatedTargets=False
)

# Register targets
ssm.register_target_with_maintenance_window(
    WindowId='mw-abc123',
    ResourceType='INSTANCE',
    Targets=[{'Key': 'tag:Patch Group', 'Values': ['Production']}]
)

# Register patch task
ssm.register_task_with_maintenance_window(
    WindowId='mw-abc123',
    TaskType='RUN_COMMAND',
    TaskArn='AWS-RunPatchBaseline',
    ServiceRoleArn='arn:aws:iam::account:role/SSMMaintenanceWindowRole',
    Priority=1,
    MaxConcurrency='50%',
    MaxErrors='25%',
    Targets=[{'Key': 'WindowTargetIds', 'Values': ['target-id']}],
    TaskInvocationParameters={
        'RunCommand': {
            'Parameters': {'Operation': ['Install']},
            'TimeoutSeconds': 3600,
            'NotificationConfig': {
                'NotificationArn': 'arn:aws:sns:region:account:patching-alerts',
                'NotificationEvents': ['All'],
                'NotificationType': 'Command'
            },
            'CloudWatchOutputConfig': {
                'CloudWatchLogGroupName': '/aws/ssm/maintenance-windows',
                'CloudWatchOutputEnabled': True
            }
        }
    }
)
```

### Patching Workflow

1. Maintenance window opens (Sunday 2 AM)
2. Systems Manager identifies targets (Patch Group: Production)
3. Retrieves patch baseline for group
4. Scans instances for missing patches
5. Downloads and installs approved patches
6. Reboots if required (configurable)
7. Reports compliance status
8. Sends SNS notifications

### Compliance Reporting

```python
# Get patch compliance summary
response = ssm.describe_instance_patch_states_for_patch_group(
    PatchGroup='Production'
)

for instance in response['InstancePatchStates']:
    instance_id = instance['InstanceId']

    print(f"\nInstance: {instance_id}")
    print(f"  Installed: {instance.get('InstalledCount', 0)}")
    print(f"  Missing: {instance.get('MissingCount', 0)}")
    print(f"  Failed: {instance.get('FailedCount', 0)}")
    print(f"  Last Scan: {instance.get('OperationEndTime')}")

    if instance.get('MissingCount', 0) > 0:
        print(f"  ⚠ {instance['MissingCount']} patches missing")
```

### Patch Deployment Strategy

| Environment | Baseline | Auto-approval | Schedule | Reboot |
|---|---|---|---|---|
| **Development** | All patches (aggressive) | Immediate | Daily | Anytime |
| **Staging** | Same as production | 3 days after development | Tuesday/Thursday | After testing |
| **Production** | Critical + Important only | 7 days after staging | Sunday 2–6 AM | Only if necessary, rollback plan documented |

---

## Cost Optimization

### Systems Manager Pricing

**Free Tier:**
- Systems Manager core features: Free
- Session Manager: Free
- Run Command: Free
- State Manager: Free
- Patch Manager: Free
- Parameter Store (Standard): Free (10,000 parameters)

**Paid Features:**

| Feature | Cost |
|---|---|
| Parameter Store (Advanced) | $0.05 per parameter/month |
| On-premises instance management | $5 per instance/month |
| Session Manager session recording | S3 storage costs |
| Automation executions | $0.002 per step (after free tier) |

### Typical Costs

**Small Fleet (100 EC2 instances):**

| Item | Cost |
|---|---|
| Parameter Store (Standard) | Free |
| Session Manager | Free |
| Run Command | Free |
| S3 logs | $2–5/month |
| **Total** | **$2–5/month** |

**Large Fleet (1,000 EC2 instances + 100 on-premises):**

| Item | Cost |
|---|---|
| On-premises (100 × $5) | $500/month |
| Parameter Store Advanced (500 × $0.05) | $25/month |
| S3 logs | $50/month |
| **Total** | **$575/month** |

### Cost Optimization Strategies

**1. Use Standard Parameter Store**
> Problem: Advanced tier for all parameters → 10,000 × $0.05 = **$500/month**
> Solution: Standard for most, Advanced only for policies → Free + (100 × $0.05) = **$5/month**
> **Savings: $495/month (99%)**

**2. Session Manager vs Bastion Hosts**
> Bastion costs: t3.micro ($7.50) + Elastic IP ($3.60) + data transfer ($10) = **$21/month per region**
> Session Manager: Free
> **Savings: $21/month per region**

**3. Automate Patch Management**
> Manual: 20 hrs/month × $100/hr = **$2,000/month**
> Systems Manager automated: Free
> **Savings: $2,000/month (100%)**

**4. Run Command vs Lambda**
> Lambda: 100,000 invocations × $0.20 = **$20/month**
> Run Command: Free
> **Savings: $20/month**

**5. Parameter Store vs Secrets Manager**
> Secrets Manager (non-rotating): 100 × $0.40 = **$40/month**
> Parameter Store: Free
> **Savings: $40/month**

### Total Monthly Savings Example

| Optimization | Savings |
|---|---|
| Parameter Store optimization | $495 |
| No bastion hosts (3 regions) | $63 |
| Automated patching | $2,000 |
| Run Command vs Lambda | $20 |
| Parameter Store vs Secrets Manager | $40 |
| **Total** | **$2,618/month** |

**Annual savings: $31,416**

### ROI

- Systems Manager implementation: ~$10,000 (initial setup)
- Annual savings: $31,416
- **ROI: 214% first year**

---

## Tips & Best Practices

### Session Manager

| # | Tip | Why |
|---|---|---|
| 1 | Enable session recording for compliance | Record to S3 with KMS encryption for a complete audit trail |
| 2 | Use IAM policies for access control | Tag-based access enforces least privilege |
| 3 | Set idle session timeout | Auto-terminate idle sessions after 20 minutes |
| 4 | Use port forwarding for database access | Eliminates bastion hosts entirely |
| 5 | Integrate with CloudWatch Logs | Real-time monitoring and alerting on suspicious commands |

### Parameter Store

| # | Tip | Why |
|---|---|---|
| 6 | Use hierarchical naming convention | `/application/environment/component/parameter` — easy retrieval per environment |
| 7 | Use SecureString for all sensitive data | KMS encryption with automatic decryption |
| 8 | Cache parameters in applications | 5-minute TTL cuts API calls ~99% |
| 9 | Version parameters for rollback | Roll back to previous values if an update fails |
| 10 | Tag parameters for organization | Enables cost tracking and access control by tag |

### Patch Management

| # | Tip | Why |
|---|---|---|
| 11 | Use different baselines per environment | Aggressive in dev, critical-only in production |
| 12 | Test patches in development first | 7-day approval delay prevents patch-related outages |
| 13 | Schedule maintenance windows during low traffic | Sunday 2–6 AM minimizes user impact |
| 14 | Use concurrency controls | Patch 50% of fleet at a time to maintain availability |
| 15 | Monitor patch compliance continuously | Daily checks speed up remediation of vulnerabilities |

---

## Pitfalls & Remedies

### Pitfall 1: SSM Agent Not Running or Outdated

**Problem:** Instances not appearing in Systems Manager console, commands failing, Session Manager unavailable.

**Why It Happens:**
- SSM Agent not installed on custom AMIs
- Agent stopped or crashed
- Outdated agent version with bugs
- Incorrect IAM instance profile
- Network connectivity issues (no internet or VPC endpoints)

**Impact:**
- Cannot manage instances remotely
- Manual SSH access required (defeats the purpose)
- Patch compliance unknown
- Automation fails
- Security gap in fleet management

**Example:**
- Scenario: 100 new EC2 instances launched from a custom AMI
- Issue: None appear in Systems Manager after 30 minutes
- Investigation: SSM Agent not included in the custom AMI
- Result: Cannot manage instances, must SSH to each manually
- Impact: Delayed patching, inconsistent configuration, manual work

**Remedy:**
1. Verify SSM Agent installation
2. Check IAM instance profile
3. Update SSM Agent
4. Automate agent installation in AMIs

**Prevention:**
- Include SSM Agent in all custom AMIs
- Use AWS-provided AMIs (agent pre-installed)
- Automate agent updates quarterly
- Monitor agent health with CloudWatch metrics
- Create EventBridge rule alerting on stopped agents
- Include SSM verification in the instance launch process

---

## Summary

AWS Systems Manager provides unified operational management for AWS and on-premises infrastructure through secure shell access without SSH keys (Session Manager), centralized configuration storage (Parameter Store), fleet command execution (Run Command), automated patching (Patch Manager), configuration compliance (State Manager), workflow orchestration (Automation), and operational incident management (OpsCenter). These capabilities eliminate traditional IT management challenges — SSH key distribution, manual server access, inconsistent configurations, delayed patching — transforming operations from manual, error-prone processes to automated, governed workflows.

### Key Takeaways

- **Use Session Manager Instead of SSH** — browser-based access without SSH keys, bastion hosts, or open inbound ports; complete CloudTrail audit trail; IAM-based permissions
- **Organize Parameters Hierarchically** — `/application/environment/component/parameter` structure enables easy retrieval, tag-based permissions, clear ownership
- **Automate Patching with Maintenance Windows** — weekly scheduled patching reduces vulnerability window from 38 days to 7 days; concurrency controls maintain availability
- **Test in Development, Deploy to Production** — 7-day approval delay allows testing patches before production; different baselines per environment
- **Implement Change Calendar** — `DEFAULT_CLOSED` calendar blocks changes except approved windows; prevents accidental production changes during business hours
- **Cache Parameters Aggressively** — 5-minute TTL reduces Parameter Store API calls 99%; improves application performance and reduces costs
- **Use Run Command for Fleet Management** — execute commands across thousands of instances simultaneously; concurrency and error controls prevent overwhelming targets

Systems Manager integrates throughout AWS — Parameter Store stores database credentials, Session Manager provides emergency access, Patch Manager updates instances monitored by CloudWatch, Run Command executes remediation from Security Hub findings, and Automation orchestrates multi-step operational workflows. Together these capabilities enable managing fleets of thousands of instances with minimal manual effort, complete audit trails, and automated compliance.

---

## Hands-On Lab Exercise

**Objective:** Build a complete fleet management system with secure access, automated patching, and parameter-based configuration.

**Scenario:** Web application fleet requiring secure access, weekly patching, and environment-specific configuration.

**Prerequisites:**
- AWS account with 5+ EC2 instances
- IAM permissions for Systems Manager

### Steps

**1. Configure Session Manager** *(30 minutes)*
- Create IAM role with SSM permissions
- Attach role to EC2 instances
- Verify SSM Agent running
- Configure session logging (S3 + CloudWatch)
- Start browser-based session
- Test port forwarding to RDS

**2. Organize Application Configuration** *(25 minutes)*
- Create parameter hierarchy (`/myapp/prod/...`)
- Store database endpoint, API keys (SecureString)
- Create feature flags
- Implement parameter caching in application
- Test parameter retrieval

**3. Configure Automated Patching** *(45 minutes)*
- Create patch baseline (critical + important only)
- Tag instances with Patch Group
- Create maintenance window (Sunday 2 AM PST)
- Register patching task with concurrency controls
- Run manual patch scan
- Review compliance report

**4. Fleet Command Execution** *(20 minutes)*
- Use Run Command to update all instances
- Monitor execution progress
- Review command output in CloudWatch
- Handle failed executions

**5. Implement Change Calendar** *(15 minutes)*
- Create `DEFAULT_CLOSED` calendar
- Define approved maintenance windows
- Associate with maintenance window
- Test calendar blocking outside windows

### Expected Outcomes

- Secure shell access without SSH keys or bastion hosts
- Centralized application configuration
- Automated weekly patching with 95%+ compliance
- Ability to execute commands across fleet instantly
- Governed change management process
- **Total cost: <$10/month** (Parameter Store + logs)

---

## Review Questions

<details>
<summary><strong>1. What is required for an instance to be managed by Systems Manager?</strong></summary>

a) Public IP address
b) SSH key configured
**c) SSM Agent installed and IAM role attached ✓**
d) CloudWatch agent installed

**Answer: C** — SSM Agent + IAM instance profile with `AmazonSSMManagedInstanceCore` policy required.
</details>

<details>
<summary><strong>2. What does Session Manager eliminate the need for?</strong></summary>

a) IAM roles
**b) SSH keys and bastion hosts ✓**
c) Security groups
d) VPC

**Answer: B** — Session Manager provides secure access without SSH keys, bastions, or open inbound ports.
</details>

<details>
<summary><strong>3. What is the maximum size for Standard Parameter Store parameters?</strong></summary>

a) 1 KB
**b) 4 KB ✓**
c) 8 KB
d) 64 KB

**Answer: B** — Standard tier: 4 KB max; Advanced tier: 8 KB max.
</details>

<details>
<summary><strong>4. What type should be used for storing passwords in Parameter Store?</strong></summary>

a) String
b) StringList
**c) SecureString ✓**
d) Binary

**Answer: C** — SecureString encrypts values with KMS; automatic decryption on retrieval.
</details>

<details>
<summary><strong>5. What is ApproveAfterDays in patch baselines?</strong></summary>

a) Days until patch expires
**b) Delay before auto-approving patches ✓**
c) Days to install after approval
d) Patch testing duration

**Answer: B** — `ApproveAfterDays` delays auto-approval, allowing testing in development first.
</details>

<details>
<summary><strong>6. What is the purpose of the maintenance window Cutoff parameter?</strong></summary>

a) Maximum duration
**b) Stop new tasks before window ends ✓**
c) Number of instances
d) Patch count limit

**Answer: B** — Cutoff (1 hour typical) stops new tasks before the window ends, ensuring completion.
</details>

<details>
<summary><strong>7. What does DEFAULT_CLOSED change calendar mean?</strong></summary>

a) Calendar is disabled
**b) Changes blocked except specified windows ✓**
c) Changes always allowed
d) Manual approval required

**Answer: B** — `DEFAULT_CLOSED` blocks changes by default; only allows during explicitly defined windows.
</details>

<details>
<summary><strong>8. What is MaxConcurrency in Run Command?</strong></summary>

a) Maximum instances total
**b) Instances executing simultaneously ✓**
c) Maximum retries
d) Command timeout

**Answer: B** — `MaxConcurrency` controls how many instances execute the command simultaneously (absolute or percentage).
</details>

<details>
<summary><strong>9. What is included in Systems Manager at no cost?</strong></summary>

a) Advanced Parameter Store only
b) On-premises instance management
**c) Session Manager and Run Command ✓**
d) Third-party integrations

**Answer: C** — Core Systems Manager features (Session Manager, Run Command, State Manager, Patch Manager) are free.
</details>

<details>
<summary><strong>10. What does OpsCenter aggregate?</strong></summary>

a) Only CloudWatch alarms
**b) Issues from multiple AWS services ✓**
c) Only manual incidents
d) Parameter Store changes

**Answer: B** — OpsCenter aggregates operational issues from CloudWatch, EventBridge, Config, and manual creation.
</details>

---

*Source: AWS Systems Manager study notes, compiled July 20, 2026.*
