# AWS Multi-AZ Infrastructure Control Layer

## 🎛️ Infrastructure Control & Management

This document describes the control plane and automation layer that manages the EC2 instances and ensures high availability.

---

## 📊 Infrastructure Control Flow Diagram

```
                    ┌────────────────────────┐
                    │   Launch Template      │
                    │  (web-app-template)    │
                    │  ─────────────────     │
                    │  • AMI: AL2023         │
                    │  • Type: t2.micro      │
                    │  • Security: web-sg    │
                    │  • User Data Script    │
                    └────────────────────────┘
                                |
                                | Defines instance configuration
                                ↓
                    ┌────────────────────────┐
                    │  Auto Scaling Group    │
                    │      (web-asg)         │
                    │  ─────────────────     │
                    │  Min: 2                │
                    │  Desired: 2            │
                    │  Max: 4                │
                    │  Multi-AZ: Enabled     │
                    └────────────────────────┘
                                |
                ┌───────────────┴───────────────┐
                |                               |
                ↓                               ↓
        ┌───────────────┐             ┌───────────────┐
        │ EC2 Instance  │             │ EC2 Instance  │
        │ (AZ: 2a)      │             │ (AZ: 2b)      │
        │ 10.0.1.x      │             │ 10.0.2.x      │
        │ Apache :80    │             │ Apache :80    │
        └───────────────┘             └───────────────┘
                |                               |
                └───────────────┬───────────────┘
                                |
                                ↓
                    ┌────────────────────────┐
                    │  Target Group Health   │
                    │       Checks           │
                    │  ─────────────────     │
                    │  • Protocol: HTTP      │
                    │  • Path: /             │
                    │  • Interval: 30s       │
                    │  • Timeout: 5s         │
                    └────────────────────────┘
                                |
                                | Reports health status
                                ↓
                    ┌────────────────────────┐
                    │     CloudWatch         │
                    │  ─────────────────     │
                    │  • CPU Metrics         │
                    │  • Health Alarms       │
                    │  • Scaling Policies    │
                    │  • Dashboard           │
                    └────────────────────────┘
                                |
                                | Triggers scaling actions
                                ↓
                    ┌────────────────────────┐
                    │  Auto Scaling Group    │
                    │  (Scale Out/In)        │
                    └────────────────────────┘
```

---

## 🔧 Component Details

### 1. Launch Template (web-app-template)

**Purpose**: Blueprint for EC2 instance creation

**Configuration**:
```yaml
Name: web-app-template
AMI: Amazon Linux 2023 (ami-xxxxxxxxx)
Instance Type: t2.micro
Security Group: web-sg
Key Pair: Optional (for SSH access)
Network: Configured by ASG
IAM Role: None (can be added for AWS service access)
```

**User Data Script**:
```bash
#!/bin/bash
# System updates
yum update -y

# Install Apache
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AZ=$(ec2-metadata --availability-zone | cut -d " " -f 2)
HOSTNAME=$(hostname)

# Create custom web page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Multi-AZ POC</title></head>
<body>
<h1>Multi-AZ High Availability POC</h1>
<p><strong>Instance ID:</strong> $INSTANCE_ID</p>
<p><strong>Hostname:</strong> $HOSTNAME</p>
<p><strong>Availability Zone:</strong> $AZ</p>
<p>Refresh to see load balancing!</p>
</body>
</html>
EOF
```

**What It Does**:
- Defines standard configuration for all instances
- Ensures consistency across all launched instances
- Automates instance setup via user data
- Can be versioned for updates

---

### 2. Auto Scaling Group (web-asg)

**Purpose**: Maintains desired number of instances and handles scaling

**Configuration**:
```yaml
Name: web-asg
Launch Template: web-app-template (latest version)
VPC: poc-multiaz-vpc
Subnets: 
  - public-a (eu-west-2a)
  - public-b (eu-west-2b)
  - public-c (eu-west-2c) [optional]

Capacity:
  Minimum: 2
  Desired: 2
  Maximum: 4

Health Checks:
  - EC2 Status Checks
  - ELB Health Checks
  Grace Period: 300 seconds

Load Balancing:
  Target Group: web-tg
  
Tags:
  Name: web-instance
  Environment: POC
```

**Responsibilities**:
1. **Instance Management**
   - Launches instances based on desired capacity
   - Distributes instances across multiple AZs
   - Terminates unhealthy instances
   - Replaces failed instances automatically

2. **Scaling Operations**
   - Scale out: Add instances when demand increases
   - Scale in: Remove instances when demand decreases
   - Respects min/max capacity limits

3. **Health Monitoring**
   - Monitors EC2 status checks
   - Monitors ELB health checks
   - Terminates and replaces unhealthy instances

4. **Multi-AZ Distribution**
   - Balances instances across selected AZs
   - Maintains availability during AZ failures

---

### 3. EC2 Instances

**Current State**:
```
Instance A:
  ID: i-xxxxxxxxx
  AZ: eu-west-2a
  Private IP: 10.0.1.x
  Public IP: Auto-assigned
  Status: Running
  Health: Healthy

Instance B:
  ID: i-yyyyyyyyy
  AZ: eu-west-2b
  Private IP: 10.0.2.x
  Public IP: Auto-assigned
  Status: Running
  Health: Healthy

Instance C (if scaled):
  ID: i-zzzzzzzzz
  AZ: eu-west-2a or 2b
  Private IP: 10.0.x.x
  Public IP: Auto-assigned
  Status: Running
  Health: Healthy
```

**Lifecycle**:
```
1. Pending → Instance launching
2. Running → Instance operational
3. Healthy → Passed health checks, receiving traffic
4. Unhealthy → Failed health checks, no traffic
5. Terminating → Being shut down
6. Terminated → Shut down complete
```

---

### 4. Target Group Health Checks

**Purpose**: Verify instances are responding correctly

**Configuration**:
```yaml
Protocol: HTTP
Port: 80
Path: /
Interval: 30 seconds
Timeout: 5 seconds
Healthy Threshold: 5 consecutive successes
Unhealthy Threshold: 2 consecutive failures
Success Codes: 200
```

**Health Check Process**:
```
Every 30 seconds:
  ALB → HTTP GET http://instance-ip/ → Instance
  
If Response = HTTP 200 OK:
  Success count++
  If success count >= 5: Mark Healthy ✅
  
If Response = Timeout/Error:
  Failure count++
  If failure count >= 2: Mark Unhealthy ❌
```

**Actions on Unhealthy**:
1. ALB stops routing traffic to instance
2. ASG detects unhealthy instance
3. ASG terminates unhealthy instance
4. ASG launches replacement instance
5. New instance passes health checks
6. ALB resumes routing traffic

---

### 5. CloudWatch Monitoring

**Purpose**: Collect metrics, trigger alarms, enable scaling

**Metrics Collected**:

**EC2 Metrics**:
```
- CPUUtilization (%)
- NetworkIn (bytes)
- NetworkOut (bytes)
- StatusCheckFailed (count)
- StatusCheckFailed_Instance (count)
- StatusCheckFailed_System (count)
```

**ALB Metrics**:
```
- RequestCount (count)
- TargetResponseTime (seconds)
- HTTPCode_Target_2XX_Count (count)
- HTTPCode_Target_5XX_Count (count)
- HealthyHostCount (count)
- UnHealthyHostCount (count)
```

**Target Group Metrics**:
```
- HealthyHostCount (count)
- UnHealthyHostCount (count)
- RequestCountPerTarget (count)
```

**Alarms Configured**:

1. **Unhealthy Host Alarm**
   ```yaml
   Metric: UnHealthyHostCount
   Threshold: > 0
   Period: 1 minute
   Action: SNS notification (optional)
   ```

2. **High CPU Alarm**
   ```yaml
   Metric: CPUUtilization
   Threshold: > 60%
   Period: 5 minutes
   Action: Trigger scale-out
   ```

3. **Low CPU Alarm**
   ```yaml
   Metric: CPUUtilization
   Threshold: < 20%
   Period: 5 minutes
   Action: Trigger scale-in
   ```

4. **5XX Error Alarm**
   ```yaml
   Metric: HTTPCode_Target_5XX_Count
   Threshold: > 10
   Period: 5 minutes
   Action: SNS notification
   ```

---

## 🔄 Scaling Policies

### Target Tracking Scaling Policy

**Configuration**:
```yaml
Policy Name: Target Tracking Policy
Metric: Average CPU Utilization
Target Value: 60%
Cooldown: 300 seconds
```

**How It Works**:

**Scale Out (Add Instances)**:
```
1. Average CPU across all instances > 60%
2. CloudWatch triggers alarm
3. ASG calculates needed capacity
4. ASG launches new instance(s)
5. Instances start, run user data
6. Instances pass health checks
7. ALB routes traffic to new instances
8. CPU utilization normalizes
```

**Scale In (Remove Instances)**:
```
1. Average CPU across all instances < 20%
2. CloudWatch triggers alarm
3. ASG calculates excess capacity
4. ASG selects instance(s) to terminate
5. ALB drains connections (300s)
6. ASG terminates instance(s)
7. Capacity reduced to minimum needed
```

**Scaling Limits**:
- Minimum: 2 instances (always maintained)
- Maximum: 4 instances (cost control)
- Cooldown: 300 seconds (prevents rapid scaling)

---

## 🔄 Auto-Healing Process

### Scenario: Instance Becomes Unhealthy

```
Step 1: Detection (1 minute)
  ├─ Health check fails at T+0s
  ├─ Health check fails at T+30s
  └─ Instance marked unhealthy

Step 2: Traffic Diversion (Immediate)
  └─ ALB stops routing new requests to unhealthy instance

Step 3: Termination Decision (2-3 minutes)
  ├─ ASG detects unhealthy instance
  ├─ ASG initiates termination
  └─ Instance state: Terminating

Step 4: Replacement Launch (1-2 minutes)
  ├─ ASG launches new instance
  ├─ Instance state: Pending → Running
  └─ User data script executes

Step 5: Health Check Grace Period (5 minutes)
  ├─ Wait for Apache to start
  ├─ Wait for health checks to pass
  └─ Instance marked healthy

Step 6: Traffic Restoration (Immediate)
  └─ ALB routes traffic to new healthy instance

Total Time: ~5-7 minutes
Downtime: 0 seconds (other instances handle traffic)
```

---

## 📊 Capacity Management

### Normal Operation (2 Instances)
```
┌─────────────────────────────────────┐
│ Capacity: 2/2 (100%)                │
│ CPU: 30-40% average                 │
│ Status: All healthy                 │
│ Action: None                        │
└─────────────────────────────────────┘
```

### High Load (Scale Out to 4)
```
┌─────────────────────────────────────┐
│ Capacity: 4/4 (100%)                │
│ CPU: 50-60% average                 │
│ Status: All healthy                 │
│ Action: Scaled out                  │
└─────────────────────────────────────┘
```

### Instance Failure (Temporary 1 Instance)
```
┌─────────────────────────────────────┐
│ Capacity: 1/2 (50%)                 │
│ CPU: 60-80% average                 │
│ Status: 1 healthy, 1 replacing      │
│ Action: Launching replacement       │
└─────────────────────────────────────┘
```

### Low Load (Scale In to 2)
```
┌─────────────────────────────────────┐
│ Capacity: 2/2 (100%)                │
│ CPU: 10-20% average                 │
│ Status: All healthy                 │
│ Action: Scaled in                   │
└─────────────────────────────────────┘
```

---

## 🎯 Control Plane Interactions

### ASG ↔ EC2
```
ASG → EC2: Launch instance
ASG → EC2: Terminate instance
ASG ← EC2: Instance status updates
ASG ← EC2: Health check results
```

### ASG ↔ Target Group
```
ASG → TG: Register instance
ASG → TG: Deregister instance
ASG ← TG: Health status
ASG ← TG: Connection draining status
```

### ASG ↔ CloudWatch
```
ASG → CW: Send metrics
ASG ← CW: Scaling alarms
ASG ← CW: Health alarms
ASG → CW: Scaling activities
```

### CloudWatch ↔ Instances
```
CW ← EC2: CPU metrics
CW ← EC2: Network metrics
CW ← EC2: Status checks
CW → EC2: (No direct control)
```

---

## 🔐 IAM Roles & Permissions

### ASG Service Role (Automatic)
```
Permissions:
- ec2:RunInstances
- ec2:TerminateInstances
- ec2:DescribeInstances
- elasticloadbalancing:RegisterTargets
- elasticloadbalancing:DeregisterTargets
```

### Instance Profile (Optional - Not Currently Used)
```
Can be added for:
- S3 access
- CloudWatch Logs
- Systems Manager
- Secrets Manager
```

---

## 📈 Monitoring Dashboard

### Key Metrics to Watch

**Capacity Metrics**:
- Desired Capacity: 2
- Current Capacity: 2
- Healthy Instances: 2
- Unhealthy Instances: 0

**Performance Metrics**:
- Average CPU: 30-40%
- Request Count: Variable
- Response Time: <100ms
- Error Rate: <0.1%

**Scaling Metrics**:
- Scale Out Events: 0
- Scale In Events: 0
- Failed Launches: 0
- Terminated Instances: 0

---

## 🛠️ Management Operations

### View ASG Activity
```bash
AWS Console:
EC2 → Auto Scaling Groups → web-asg → Activity tab

Shows:
- Instance launches
- Instance terminations
- Scaling activities
- Health check replacements
```

### View Instance Health
```bash
AWS Console:
EC2 → Auto Scaling Groups → web-asg → Instance management tab

Shows:
- Instance IDs
- Availability Zones
- Health Status
- Lifecycle State
```

### View Scaling History
```bash
AWS Console:
EC2 → Auto Scaling Groups → web-asg → Automatic scaling tab

Shows:
- Scaling policies
- Scaling activities
- CloudWatch alarms
```

---

## 🔄 Update Procedures

### Update Launch Template
```
1. Create new launch template version
2. Update ASG to use new version
3. Terminate old instances (ASG replaces with new)
4. Verify new instances healthy
```

### Update Capacity
```
1. Edit ASG configuration
2. Change desired/min/max capacity
3. ASG automatically adjusts
4. Monitor scaling activity
```

### Update Scaling Policy
```
1. Edit scaling policy
2. Change target value or metric
3. Policy takes effect immediately
4. Monitor CloudWatch alarms
```

---

## 📊 Infrastructure Control Summary

**Automation Level**: Fully Automated
- ✅ Instance launches
- ✅ Instance terminations
- ✅ Health monitoring
- ✅ Auto-healing
- ✅ Auto-scaling
- ✅ Multi-AZ distribution

**Manual Interventions Required**: None
- System self-manages capacity
- System self-heals failures
- System self-scales with load

**Monitoring Required**: Recommended
- CloudWatch dashboards
- Alarm notifications
- Activity logs

---

**Project**: AWS Multi-AZ High Availability POC  
**Region**: EU-West-2 (London)  
**Control Plane**: Fully Automated ✅
