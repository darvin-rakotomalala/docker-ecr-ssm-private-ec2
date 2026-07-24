# AWS IAM Note

> Identity and Access Management (IAM) — the cornerstone of AWS security architecture.

---

## Table of Contents

- [Introduction](#introduction)
- [IAM Fundamentals](#iam-fundamentals)
- [IAM Identities](#iam-identities)
  - [Types of Roles](#types-of-roles)
- [Trust Policies](#trust-policies)
- [IAM Policies](#iam-policies)
  - [Policy Structure](#policy-structure)
  - [Policy Elements](#policy-elements)
- [Service Control Policies (SCPs)](#service-control-policies-scps)
- [IAM Best Practices for Policy Design](#iam-best-practices-for-policy-design)
- [Multi-Factor Authentication (MFA)](#multi-factor-authentication-mfa)
- [Cross-Account Access](#cross-account-access)
- [IAM Access Analyzer](#iam-access-analyzer)
- [IAM Policies for AWS Services](#iam-policies-for-aws-services)
- [IAM Limits and Quotas](#iam-limits-and-quotas)
- [Production-Level Knowledge](#production-level-knowledge)
  - [Enterprise IAM Architecture Patterns](#enterprise-iam-architecture-patterns)
  - [Comprehensive Audit and Compliance](#comprehensive-audit-and-compliance)
- [Tips & Best Practices](#tips--best-practices)
  - [Security Best Practices](#security-best-practices)
  - [Policy Design Tips](#policy-design-tips)
  - [Operational Tips](#operational-tips)
  - [Monitoring and Auditing Tips](#monitoring-and-auditing-tips)
- [Pitfalls & Remedies](#pitfalls--remedies)
- [Summary](#summary)
  - [Key Takeaways](#key-takeaways)

---

## Introduction

Every interaction with AWS — whether launching an EC2 instance, reading from an S3 bucket, or updating a database — requires:

- **Authentication** — proving who you are
- **Authorization** — verifying what you're allowed to do

IAM provides the framework for both, enabling you to control access to AWS resources with precision and flexibility.

---

## IAM Fundamentals

> IAM is a **global service** that operates across all AWS Regions. Resources created in IAM — users, groups, roles, and policies — are automatically available worldwide.

### Key IAM Principles

| # | Principle | Description |
|---|-----------|-------------|
| 1 | **Least Privilege** | Grant only the permissions required to perform a task |
| 2 | **Defense in Depth** | Layer multiple security controls (MFA, network policies, encryption) |
| 3 | **Separation of Duties** | Distribute permissions across multiple identities to prevent abuse |
| 4 | **Regular Auditing** | Continuously review and refine access permissions |

---

## IAM Identities

| Identity | Description |
|----------|-------------|
| 🧑 **IAM Users** | Represents a person or application that needs to interact with AWS. Each user has unique credentials (password, access keys) and can be granted specific permissions. |
| 👥 **IAM Groups** | Collections of users that share common permissions. Attach policies to groups instead of individual users for easier management. |
| 🎭 **IAM Roles** | Identities that can be assumed by trusted entities (users, applications, services). Unlike users, roles don't have permanent credentials — they provide temporary security credentials when assumed. |

### Types of Roles

1. **Service Roles** — Allow AWS services to perform actions on your behalf.
2. **Cross-Account Roles** — Enable access between AWS accounts (common in multi-account organizations).
3. **Federated User Roles** — Allow users authenticated by external identity providers to access AWS.
4. **Service-Linked Roles** — Predefined roles created automatically by AWS services.

---

## Trust Policies

Every role has a **trust policy** (also called *assume role policy*) that defines who can assume the role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

## IAM Policies

Policies are JSON documents that define permissions. They answer the question:

> "What actions can be performed on which resources under what conditions?"

### Policy Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ListAllBuckets",
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```

### Policy Elements

| Element | Description |
|---------|-------------|
| **Version** | Policy language version (always use `"2012-10-17"`) |
| **Statement** | Array of individual permission statements |
| **Sid** | *(Optional)* Statement identifier for documentation |
| **Effect** | Either `"Allow"` or `"Deny"` |
| **Principal** | *(Resource-based policies only)* Who the statement applies to |
| **Action** | List of actions (e.g., `s3:GetObject`, `ec2:RunInstances`) |
| **Resource** | ARNs of resources the statement applies to |
| **Condition** | *(Optional)* Circumstances under which the statement applies |

---

## Service Control Policies (SCPs)

Part of **AWS Organizations**, SCPs set the *maximum* permissions for accounts in an organization. They don't grant permissions — they only limit them.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "ec2:Region": ["us-east-1", "us-west-2"]
        }
      }
    }
  ]
}
```

> This SCP prevents launching EC2 instances outside `us-east-1` and `us-west-2`.

---

## IAM Best Practices for Policy Design

- **Use of Policy Variables** — Policy variables enable dynamic policies that adapt to the current context
- **Condition Keys** — Conditions add context-based access control
- **Identity Federation** — Enables users to access AWS using credentials from external identity providers, eliminating the need to create IAM users for everyone

---

## Multi-Factor Authentication (MFA)

MFA adds an extra layer of security by requiring two forms of authentication:

1. Something you **know** (password)
2. Something you **have** (MFA device)

> ⚠️ **MFA for Root Account:** Always enable MFA on the root account — it's non-negotiable for security.

---

## Cross-Account Access

Organizations frequently need to grant access across AWS accounts. Cross-account access enables this without sharing credentials.

**Pattern 1: Role Assumption (Recommended)**

```
Account A (123456789012) → Assume Role → Account B (987654321098)
```

**Pattern 2: Resource-Based Policies** — For services that support resource-based policies (S3, SQS, SNS, Lambda)

### Difference

| Method | Characteristics |
|--------|------------------|
| **Role assumption** | Temporary credentials, scales to any service |
| **Resource-based** | Direct access without assuming role, limited to specific services |

---

## IAM Access Analyzer

AWS IAM Access Analyzer helps identify resources shared with external entities and validates policies.

### Features

1. **External Access Analysis** — Identifies resources accessible from outside your AWS account or organization
2. **Policy Validation** — Checks policies against best practices and identifies errors before deployment
3. **Policy Generation** — Analyzes CloudTrail logs to generate least-privilege policies based on actual usage

### Findings

- Public S3 buckets
- IAM roles assumable by external accounts
- KMS keys with external key policies
- Lambda functions with cross-account permissions

---

## IAM Policies for AWS Services

**Service Roles** — Most AWS services require a role to operate:

- Lambda needs a role to write logs to CloudWatch
- EC2 instances need a role to access S3
- ECS tasks need a role to pull images from ECR

**Service-Linked Roles** — Some services automatically create and manage roles:

- Auto Scaling → `AWSServiceRoleForAutoScaling`
- ElastiCache → `AWSServiceRoleForElastiCache`
- Cannot be modified, only deleted when the service no longer needs them

**Resource-Based Policies on Services** — Some services support resource-based policies:

- S3 bucket policies
- SNS topic policies
- SQS queue policies
- Lambda function policies
- ECR repository policies

---

## IAM Limits and Quotas

| Resource | Default Limit | Notes |
|----------|---------------|-------|
| Users per account | 5,000 | Use federation for larger organizations |
| Groups per account | 300 | Users can be in up to 10 groups |
| Roles per account | 1,000 | Soft limit, can be increased |
| Policies per user/group/role | 10 managed policies | Plus inline policies |
| Policy size | 2,048 characters (inline), 6,144 (managed) | Compress policies if hitting limit |
| MFA devices per user | 8 | Multiple devices for redundancy |

---

## Production-Level Knowledge

### Enterprise IAM Architecture Patterns

Production environments require sophisticated IAM architectures that balance security, usability, and operational efficiency.

**Pattern 1: Multi-Account Organization with IAM Identity Center**

For enterprises with multiple AWS accounts:

```
Management Account (Organizations)
├── IAM Identity Center
│   ├── Identity Source (Azure AD/Okta)
│   ├── Permission Sets
│   └── Account Assignments
├── Security Account (Audit/Logging)
├── Shared Services Account (Networking)
├── Development Accounts (by team)
└── Production Accounts (by application)
```

**Benefits:**

- Centralized identity management
- Consistent permissions across accounts
- Automatic account provisioning
- Single sign-on experience

**Pattern 2: Service-Specific IAM Roles with Least Privilege**

### Comprehensive Audit and Compliance

- CloudTrail Integration
- IAM Access Analyzer Setup
- Automated Compliance Checks

---

## Tips & Best Practices

### Security Best Practices

- **Tip 1:** Never Use Root Account for Day-to-Day Operations
- **Tip 2:** Implement MFA Delete for S3 Buckets
- **Tip 3:** Use IAM Roles Everywhere Possible

  Roles provide temporary credentials and eliminate the risk of exposed long-term access keys:
  - EC2 instances → Instance profiles
  - Lambda functions → Execution roles
  - ECS tasks → Task roles
  - CI/CD pipelines → OIDC federation with roles

- **Tip 4:** Rotate Credentials Regularly
- **Tip 5:** Use AWS Secrets Manager for Credentials

### Policy Design Tips

- **Tip 6:** Start with AWS Managed Policies, Refine with Custom

  AWS managed policies are a good starting point:
  | Policy | Description |
  |--------|--------------|
  | `ReadOnlyAccess` | View everything |
  | `PowerUserAccess` | Everything except IAM management |
  | `ViewOnlyAccess` | Similar to ReadOnly but more restrictive |

  Then create custom policies to tighten or extend permissions.

- **Tip 7:** Use Policy Conditions for Defense in Depth — Always add conditions where applicable
- **Tip 8:** Use `NotAction` Carefully
- **Tip 9:** Leverage Policy Validators — Use IAM Access Analyzer policy validation
- **Tip 10:** Document Your Policies

### Operational Tips

- **Tip 11:** Use AWS Organizations for Multi-Account Management
- **Tip 12:** Implement Policy Versioning
- **Tip 13:** Use CloudWatch Logs Insights for IAM Auditing
- **Tip 14:** Set Up Budget Alerts for IAM Operations
- **Tip 15:** Implement Just-in-Time (JIT) Access

### Monitoring and Auditing Tips

- **Tip 16:** Enable IAM Access Advisor — Track service-level permissions usage
- **Tip 17:** Set Up Real-Time Security Alerts
  - Create EventBridge rule for IAM changes
  - Target SNS for alerts
- **Tip 18:** Implement Separation of Duties — No single person should have complete control
  | Responsibility | Owner |
  |-----------------|-------|
  | User Management | Security Team |
  | Policy Creation | DevOps Team |
  | Permission Assignment | Team Leads |
  | Audit Access | Compliance Team |
- **Tip 19:** Use AWS Config for IAM Compliance
- **Tip 20:** Create an IAM Hygiene Dashboard

---

## Pitfalls & Remedies

### Pitfall 1: Overly Permissive Policies with Wildcard Resources

**Problem:** Policies using `"Resource": "*"` with broad actions, granting unintended access across all resources in the account.

**Why It Happens:**
- Quick prototyping without refinement
- Lack of understanding of resource-specific ARNs
- Copy-pasting examples without modification
- Pressure to "just make it work"

**Impact:**
- Privilege escalation opportunities
- Lateral movement for attackers
- Compliance violations (least privilege principle)
- Difficulty tracking who has access to what

**Prevention:**
- Always start with deny-all, then explicitly allow what's needed
- Use IAM policy simulator to test before deploying
- Implement policy review process
- Set up automated scanning for overly permissive policies
- Use AWS Config rules to detect violations

### Pitfall 2: Hardcoded Credentials in Code or Configuration Files

**Problem:** Access keys embedded directly in application code, configuration files, or worse — committed to version control.

**Why It Happens:**
- Convenience during development
- Lack of awareness of better alternatives
- Legacy applications not refactored
- Insufficient security training

**Impact:**
- Exposed credentials if repository is public
- Credentials leaked in CI/CD logs
- Difficult to rotate without code changes
- Compliance failures
- Potential for massive breaches

**Prevention:**
- Never commit credentials to version control
- Use IAM roles wherever possible
- Store secrets in AWS Secrets Manager or Parameter Store
- Implement automated scanning in CI/CD pipeline
- Educate team on secure credential management
- Use AWS Config rules to detect IAM user access keys
- Rotate credentials regularly using automated tools

### Pitfall 3: Root Account Usage for Daily Operations

**Problem:** Using the root account (the account created when you first sign up for AWS) for routine tasks instead of creating IAM users or using federated access.

**Why It Happens:**
- Convenience — it's the first account created
- Lack of understanding about IAM best practices
- Small teams without proper governance
- "It's just a test account" mentality that persists into production

**Impact:**
- No audit trail of who performed actions
- Cannot restrict root account permissions
- Single point of compromise for entire account
- Compliance violations
- Cannot enforce MFA policies on root access
- Risk of accidental destructive actions

**Prevention:**
- Lock root credentials in secure vault (password manager)
- Enable MFA on root account
- Set up CloudWatch alarms for root usage
- Educate team about root account risks
- Use AWS Organizations SCP to restrict root usage
- Conduct regular reviews of root account activity

### Pitfall 4: Insufficient Cross-Account Access Controls

**Problem:** Cross-account roles configured without proper conditions, allowing unintended access or making accounts vulnerable to confused deputy attacks.

**Why It Happens:**
- Copying trust policies without understanding conditions
- Not using external IDs
- Overly permissive IP restrictions
- Lack of understanding of cross-account security models

**Impact:**
- Unauthorized cross-account access
- Confused deputy vulnerability
- Lateral movement between accounts
- Compliance violations
- Difficulty tracking access patterns

**Prevention:**
- Always use `ExternalId` for third-party access
- Specify exact principal ARNs (not `:root`)
- Add IP restrictions when possible
- Implement time-based access with conditions
- Use IAM Access Analyzer to detect external access
- Monitor `AssumeRole` calls in CloudTrail
- Document all cross-account relationships

### Pitfall 5: Not Using Service Control Policies (SCPs) in Organizations

**Problem:** Managing permissions solely through IAM policies in individual accounts without leveraging AWS Organizations SCPs for centralized control.

**Why It Happens:**
- Not using AWS Organizations
- Lack of understanding of SCP capabilities
- Fear of breaking existing access patterns
- Decentralized AWS account management

**Impact:**
- Inconsistent security postures across accounts
- Inability to enforce organization-wide policies
- Risk of rogue accounts with excessive permissions
- Compliance challenges at scale
- No guardrails for new accounts

**Recommended SCP Hierarchy:**

```
Root (FullAWSAccess)
├── Production OU
│   ├── RequireEncryption SCP
│   ├── DenyRootUsage SCP
│   ├── RegionRestriction SCP
│   └── RequireMFA SCP
├── Development OU
│   ├── RequireEncryption SCP
│   ├── DenyRootUsage SCP
│   └── RegionRestriction SCP
└── Sandbox OU
    └── DenyProductionAccess SCP
```

**Prevention:**
- Enable AWS Organizations for all multi-account setups
- Start with permissive SCPs and gradually tighten
- Test SCPs in sandbox accounts first
- Document the purpose of each SCP
- Review and update SCPs quarterly
- Monitor CloudTrail for SCP-denied actions
- Use SCPs as guardrails, not primary access control

### Pitfall 6: Neglecting IAM Policy Size Limits

**Problem:** Creating overly complex policies that exceed AWS size limits, causing deployment failures or forcing workarounds that compromise security.

**Why It Happens:**
- Adding permissions incrementally without refactoring
- Not understanding size limits
- Trying to implement ABAC with excessive conditions
- Copying large policy examples without optimization

**Impact:**
- Policy creation failures
- Deployment pipeline breakages
- Forced use of inline policies (harder to manage)
- Workarounds that reduce security
- Maintenance nightmares

**Policy Size Limits:**

| Policy Type | Size Limit |
|-------------|-----------|
| Managed policy | 6,144 characters |
| Inline policy (user) | 2,048 characters |
| Inline policy (role/group) | 10,240 characters |
| Resource-based policy | Varies by service |

**Prevention:**
- Design policies for scalability from the start
- Use wildcards and variables effectively
- Split large policies into logical modules
- Leverage ABAC for scalable access control
- Regular policy reviews and refactoring
- Monitor policy sizes in CI/CD pipeline

### Pitfall 7: Improper Handling of Temporary Security Credentials

**Problem:** Treating temporary credentials (from STS) like permanent access keys, leading to expiration issues, hardcoded temporary tokens, or failed renewals.

**Why It Happens:**
- Lack of understanding of STS credential lifecycle
- Poor error handling for expired credentials
- Not implementing automatic refresh mechanisms
- Storing temporary credentials permanently

**Impact:**
- Application outages when credentials expire
- Race conditions during credential refresh
- Security risks if temporary credentials are exposed
- Difficult debugging of intermittent failures

**Prevention:**
- Use IAM roles wherever possible (EC2, Lambda, ECS)
- Implement automatic credential refresh
- Handle expiration errors gracefully
- Never store temporary credentials permanently
- Monitor CloudTrail for `ExpiredToken` errors
- Use AWS SDK credential providers
- Set appropriate session durations

---

## Summary

IAM is the foundation of AWS security, controlling who can access which resources under what conditions. Mastering IAM requires understanding its components (users, groups, roles, policies), implementing least privilege access, and following security best practices throughout the credential lifecycle.

### Key Takeaways

- **IAM is global** — Resources created in IAM are available across all AWS Regions, simplifying management but requiring careful planning
- **Roles over users** — Prefer IAM roles with temporary credentials over IAM users with long-term access keys to reduce security risks
- **Least privilege is non-negotiable** — Grant only the minimum permissions required for each task, using fine-grained policies with specific resources and conditions
- **Defense in depth** — Layer multiple security controls including MFA, IP restrictions, permission boundaries, and SCPs for comprehensive protection
- **Cross-account access requires care** — Use external IDs, specific principals, and conditions to prevent confused deputy vulnerabilities
- **Federation scales better** — For organizations with many users, implement SAML or OIDC federation instead of creating individual IAM users
- **Audit continuously** — Use CloudTrail, IAM Access Analyzer, and automated compliance checks to detect and remediate security issues

> Understanding IAM deeply enables you to build secure, scalable, and compliant AWS architectures. The patterns and practices covered here form the security foundation for all subsequent AWS services and solutions.
