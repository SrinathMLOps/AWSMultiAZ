# Complete Deployment Guide: AWS Multi-AZ Highly Available Web App

## Part A: Console Deployment (Step-by-Step)

### Step 0: Set Region

1. Log into AWS Console
2. Top-right corner → Select **Europe (London) eu-west-2**
3. Verify region is set correctly before proceeding

### Step 1: Create VPC

1. Navigate to **VPC** service
2. Click **Create VPC**
3. Configuration:
   - Name: `poc-multiaz-vpc`
   - IPv4 CIDR: `10.0.0.0/16`
   - IPv6: No IPv6 CIDR block
   - Tenancy: Default
4. Click **Create VPC**

### Step 2: Create Public Subnets (2 AZs)

#### Subnet A (AZ-A)
1. VPC → **Subnets** → **Create Subnet**
2. Configuration:
   - VPC: Select `poc-multiaz-vpc`
   - Name: `public-a`
   - Availability Zone: `eu-west-2a`
   - IPv4 CIDR: `10.0.1.0/24`
3. Click **Create Subnet**

#### Subnet B (AZ-B)
1. Click **Create Subnet** again
2. Configuration:
   - VPC: Select `poc-multiaz-vpc`
   - Name: `public-b`
   - Availability Zone: `eu-west-2b`
   - IPv4 CIDR: `10.0.2.0/24`
3. Click **Create Subnet**

#### Enable Auto-Assign Public IP
1. Select `public-a` subnet
2. **Actions** → **Edit subnet settings**
3. Check **Enable auto-assign public IPv4 address**
4. Save
5. Repeat for `public-b` subnet

### Step 3: Internet Gateway + Route Table

#### Create Internet Gateway
1. VPC → **Internet Gateways** → **Create Internet Gateway**
2. Name: `poc-igw`
3. Click **Create**
4. Select the IGW → **Actions** → **Attach to VPC**
5. Select `poc-multiaz-vpc` → **Attach**

#### Configure Route Table
1. VPC → **Route Tables** → **Create Route Table**
2. Name: `public-rt`
3. VPC: `poc-multiaz-vpc`
4. Click **Create**
5. Select `public-rt` → **Routes** tab → **Edit routes**
6. **Add route**:
   - Destination: `0.0.0.0/0`
   - Target: Internet Gateway → select `poc-igw`
7. Save changes
8. **Subnet associations** tab → **Edit subnet associations**
9. Select both `public-a` and `public-b`
10. Save associations

### Step 4: Security Group

1. EC2 → **Security Groups** → **Create Security Group**
2. Configuration:
   - Name: `web-sg`
   - Description: `Allow HTTP traffic for web servers`
   - VPC: `poc-multiaz-vpc`
3. **Inbound rules**:
   - Rule 1:
     - Type: HTTP
     - Port: 80
     - Source: `0.0.0.0/0` (Anywhere IPv4)
   - Rule 2 (Optional):
     - Type: SSH
     - Port: 22
     - Source: My IP
4. **Outbound rules**: Leave default (all traffic)
5. Click **Create Security Group**

### Step 5: Launch Template

1. EC2 → **Launch Templates** → **Create Launch Template**
2. Configuration:
   - Name: `web-app-template`
   - Description: `Template for multi-AZ web servers`
3. **Application and OS Images**:
   - AMI: Amazon Linux 2023 (or Amazon Linux 2)
4. **Instance type**: `t2.micro`
5. **Key pair**: Select existing or create new (optional)
6. **Network settings**:
   - Don't include in launch template (we'll set in ASG)
7. **Security groups**: Select `web-sg`
8. **Advanced details** → **User data** (paste this):

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

# Get instance metadata
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
HOST=$(hostname)

# Create custom HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Multi-AZ POC</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #232f3e;
            border-bottom: 3px solid #ff9900;
            padding-bottom: 10px;
        }
        .info {
            margin: 20px 0;
            padding: 15px;
            background: #f0f0f0;
            border-left: 4px solid #ff9900;
        }
        .label {
            font-weight: bold;
            color: #232f3e;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Multi-AZ High Availability POC</h1>
        <div class="info">
            <p><span class="label">Instance ID:</span> $ID</p>
            <p><span class="label">Hostname:</span> $HOST</p>
            <p><span class="label">Availability Zone:</span> $AZ</p>
        </div>
        <p>Refresh this page to see load balancing in action!</p>
    </div>
</body>
</html>
EOF
```

9. Click **Create Launch Template**

### Step 6: Target Group

1. EC2 → **Target Groups** → **Create Target Group**
2. Configuration:
   - Target type: **Instances**
   - Name: `web-tg`
   - Protocol: HTTP
   - Port: 80
   - VPC: `poc-multiaz-vpc`
3. **Health checks**:
   - Protocol: HTTP
   - Path: `/`
   - Healthy threshold: 2
   - Unhealthy threshold: 2
   - Timeout: 5 seconds
   - Interval: 30 seconds
4. Click **Next**
5. Don't register targets yet (ASG will do this)
6. Click **Create Target Group**

### Step 7: Application Load Balancer

1. EC2 → **Load Balancers** → **Create Load Balancer**
2. Select **Application Load Balancer**
3. Configuration:
   - Name: `web-alb`
   - Scheme: **Internet-facing**
   - IP address type: IPv4
4. **Network mapping**:
   - VPC: `poc-multiaz-vpc`
   - Mappings: Select both `eu-west-2a` and `eu-west-2b`
   - Subnets: `public-a` and `public-b`
5. **Security groups**: Select `web-sg`
6. **Listeners and routing**:
   - Protocol: HTTP
   - Port: 80
   - Default action: Forward to `web-tg`
7. Click **Create Load Balancer**
8. **Copy the DNS name** (you'll need this for testing)

### Step 8: Auto Scaling Group

1. EC2 → **Auto Scaling Groups** → **Create Auto Scaling Group**
2. **Step 1: Choose launch template**:
   - Name: `web-asg`
   - Launch template: `web-app-template`
   - Click **Next**
3. **Step 2: Choose instance launch options**:
   - VPC: `poc-multiaz-vpc`
   - Subnets: Select both `public-a` and `public-b`
   - Click **Next**
4. **Step 3: Configure advanced options**:
   - Load balancing: **Attach to an existing load balancer**
   - Choose from your load balancer target groups: `web-tg`
   - Health checks: Enable **ELB health checks**
   - Grace period: 300 seconds
   - Click **Next**
5. **Step 4: Configure group size and scaling**:
   - Desired capacity: `2`
   - Minimum capacity: `2`
   - Maximum capacity: `4`
   - Click **Next**
6. **Step 5: Add notifications** (optional): Skip
7. **Step 6: Add tags** (optional):
   - Key: `Name`, Value: `web-instance`
8. Click **Next** → **Create Auto Scaling Group**

### Step 9: Test Your POC

#### Test 1: Load Balancing
1. Wait 3-5 minutes for instances to launch and pass health checks
2. Open ALB DNS in browser: `http://web-alb-xxxxxxxxx.eu-west-2.elb.amazonaws.com`
3. Refresh multiple times
4. **Expected**: Different Instance IDs and AZs appear

#### Test 2: High Availability
1. EC2 → **Instances**
2. Select one running instance
3. **Instance state** → **Stop instance**
4. Refresh ALB URL
5. **Expected**: Site still loads (from other instance)

#### Test 3: Self-Healing
1. Wait 2-3 minutes
2. Check ASG activity history
3. **Expected**: New instance launches automatically
4. Check Target Group health
5. **Expected**: New instance becomes healthy

## Part B: Production Enhancements

### Add-on 1: Auto Scaling Policies

1. ASG → **Automatic scaling** tab → **Create dynamic scaling policy**
2. **Scale Out Policy**:
   - Policy type: Target tracking scaling
   - Metric: Average CPU utilization
   - Target value: 60
   - Instances need: 300 seconds warm up
3. Click **Create**

### Add-on 2: CloudWatch Monitoring

#### Create Alarms
1. CloudWatch → **Alarms** → **Create alarm**

**Alarm 1: Unhealthy Hosts**
- Metric: ALB → Per AppELB Metrics → UnHealthyHostCount
- Condition: Greater than 0
- Period: 1 minute
- Action: SNS notification (optional)

**Alarm 2: 5XX Errors**
- Metric: ALB → Per AppELB Metrics → HTTPCode_Target_5XX_Count
- Condition: Greater than 10
- Period: 5 minutes

#### Create Dashboard
1. CloudWatch → **Dashboards** → **Create dashboard**
2. Name: `web-app-monitoring`
3. Add widgets:
   - Line graph: CPU utilization (EC2)
   - Number: Healthy host count (Target Group)
   - Line graph: Request count (ALB)
   - Line graph: Target response time (ALB)

## Testing Checklist

- [ ] ALB DNS resolves and shows web page
- [ ] Refresh shows different instance IDs
- [ ] Both AZs (eu-west-2a and eu-west-2b) appear
- [ ] Stopping one instance doesn't break service
- [ ] ASG launches replacement instance
- [ ] Target Group shows healthy instances
- [ ] CloudWatch alarms are configured
- [ ] Dashboard displays metrics

## Troubleshooting

### Issue: ALB returns 503 error
- Check Target Group health status
- Verify security group allows HTTP on port 80
- Check instance user data executed correctly
- Wait for health check grace period

### Issue: Instances not launching
- Verify subnets have auto-assign public IP enabled
- Check IAM permissions
- Verify launch template configuration
- Check ASG activity history for errors

### Issue: Can't access ALB DNS
- Verify ALB is in "active" state
- Check security group allows inbound HTTP
- Verify internet gateway is attached
- Check route table has 0.0.0.0/0 route

## Cleanup Instructions

**Important**: Follow this order to avoid dependency errors

1. Delete Auto Scaling Group (will terminate instances)
2. Delete Load Balancer
3. Delete Target Group
4. Delete Launch Template
5. Delete Security Group
6. Detach and delete Internet Gateway
7. Delete Route Table
8. Delete Subnets
9. Delete VPC

## Cost Optimization Tips

- Use t2.micro or t3.micro for testing
- Delete resources when not in use
- Set up billing alerts
- Use AWS Free Tier where applicable
- Consider Reserved Instances for production

---

**Next Steps**: Take screenshots and document your results in the portfolio!
