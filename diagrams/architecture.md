# Architecture Diagram

## ASCII Diagram

```
                                    Internet
                                       |
                                       |
                    ┌──────────────────┴──────────────────┐
                    │                                     │
                    │    Application Load Balancer       │
                    │         (Internet-facing)          │
                    │      web-alb.eu-west-2.elb...     │
                    └──────────────────┬──────────────────┘
                                       |
                    ┌──────────────────┴──────────────────┐
                    │         Target Group (web-tg)       │
                    │      Health Checks: HTTP:80 /       │
                    └──────────────────┬──────────────────┘
                                       |
                ┌──────────────────────┴──────────────────────┐
                |                                             |
                |          Auto Scaling Group (web-asg)       |
                |          Min: 2, Desired: 2, Max: 4         |
                |                                             |
                └──────────────────┬──────────────────────────┘
                                   |
        ┌──────────────────────────┴──────────────────────────┐
        |                                                      |
        |                                                      |
┌───────▼────────┐                                  ┌─────────▼────────┐
│  AZ: eu-west-2a│                                  │  AZ: eu-west-2b  │
│                │                                  │                  │
│  ┌──────────┐  │                                  │  ┌──────────┐    │
│  │ Subnet   │  │                                  │  │ Subnet   │    │
│  │ public-a │  │                                  │  │ public-b │    │
│  │10.0.1.0/24  │                                  │  │10.0.2.0/24    │
│  │          │  │                                  │  │          │    │
│  │ ┌──────┐ │  │                                  │  │ ┌──────┐ │    │
│  │ │ EC2  │ │  │                                  │  │ │ EC2  │ │    │
│  │ │t2.micro │ │                                  │  │ │t2.micro │   │
│  │ │Apache│ │  │                                  │  │ │Apache│ │    │
│  │ │:80   │ │  │                                  │  │ │:80   │ │    │
│  │ └──────┘ │  │                                  │  │ └──────┘ │    │
│  └──────────┘  │                                  │  └──────────┘    │
│                │                                  │                  │
└────────────────┘                                  └──────────────────┘
        |                                                      |
        └──────────────────────┬───────────────────────────────┘
                               |
                    ┌──────────▼──────────┐
                    │  Internet Gateway   │
                    │      (poc-igw)      │
                    └─────────────────────┘
                               |
                    ┌──────────▼──────────┐
                    │    Route Table      │
                    │    (public-rt)      │
                    │  0.0.0.0/0 → IGW   │
                    └─────────────────────┘

                    ┌─────────────────────┐
                    │   Security Group    │
                    │      (web-sg)       │
                    │  Inbound: HTTP:80   │
                    │  Source: 0.0.0.0/0  │
                    └─────────────────────┘

                    ┌─────────────────────┐
                    │    CloudWatch       │
                    │  - Alarms           │
                    │  - Dashboard        │
                    │  - Metrics          │
                    └─────────────────────┘
```

## Component Details

### VPC Layer
- **VPC CIDR**: 10.0.0.0/16
- **Region**: eu-west-2 (London)
- **Subnets**: 2 public subnets across 2 AZs

### Compute Layer
- **Launch Template**: Defines EC2 configuration
- **Instance Type**: t2.micro (free tier eligible)
- **AMI**: Amazon Linux 2023
- **User Data**: Installs Apache, creates custom HTML

### Load Balancing Layer
- **ALB**: Internet-facing, HTTP:80
- **Target Group**: Health checks every 30s
- **Routing**: Round-robin across healthy targets

### Auto Scaling Layer
- **Capacity**: 2-4 instances
- **Health Checks**: EC2 + ELB
- **Scaling Policy**: CPU-based (60% threshold)

### Security Layer
- **Security Group**: Allows HTTP from anywhere
- **Network ACLs**: Default (allow all)
- **IAM**: Instance profile (if needed)

### Monitoring Layer
- **CloudWatch Alarms**: Unhealthy hosts, 5XX errors
- **Metrics**: CPU, RequestCount, HealthyHostCount
- **Dashboard**: Real-time visualization

## Traffic Flow

1. User requests `http://web-alb-xxx.eu-west-2.elb.amazonaws.com`
2. DNS resolves to ALB IP addresses
3. ALB receives request on port 80
4. ALB checks Target Group for healthy instances
5. ALB forwards request to healthy instance (round-robin)
6. EC2 instance processes request via Apache
7. Response returns through ALB to user
8. CloudWatch records metrics

## Failure Scenarios

### Scenario 1: Single Instance Failure
1. Instance becomes unhealthy (fails health checks)
2. ALB stops routing traffic to failed instance
3. Traffic continues to healthy instance(s)
4. ASG detects unhealthy instance
5. ASG terminates failed instance
6. ASG launches replacement instance
7. New instance passes health checks
8. ALB resumes routing to new instance

### Scenario 2: Availability Zone Failure
1. All instances in one AZ become unreachable
2. ALB routes all traffic to remaining AZ
3. ASG attempts to launch replacements in failed AZ
4. If AZ remains down, instances launch in healthy AZ
5. Service continues with reduced capacity

### Scenario 3: High Traffic Spike
1. CPU utilization exceeds 60% threshold
2. CloudWatch alarm triggers
3. ASG scaling policy activates
4. New instances launch (up to max capacity)
5. New instances pass health checks
6. ALB distributes load across all instances
7. CPU utilization normalizes

## Diagram Creation Instructions

To create a visual diagram, use one of these tools:

### Option 1: draw.io (diagrams.net)
1. Go to https://app.diagrams.net/
2. Use AWS architecture icons
3. Export as PNG: `architecture.png`

### Option 2: Lucidchart
1. Use AWS architecture template
2. Drag and drop AWS service icons
3. Export as PNG

### Option 3: CloudCraft
1. Go to https://www.cloudcraft.co/
2. Use AWS components
3. Export as PNG

### Option 4: AWS Architecture Icons
1. Download from: https://aws.amazon.com/architecture/icons/
2. Use PowerPoint or similar tool
3. Export as PNG

### Recommended Layout
- Top: Internet/Users
- Second layer: ALB
- Third layer: Target Group
- Fourth layer: ASG
- Bottom layer: Two columns for two AZs
- Side: CloudWatch, Security Groups

Save the final diagram as `architecture.png` in this directory.
