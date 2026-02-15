# AWS Multi-AZ Highly Available Web App (ALB + ASG)

A production-ready demonstration of AWS high availability architecture using Application Load Balancer and Auto Scaling Groups across multiple Availability Zones in the London region.

![Multi-AZ Demo](MultiAZ.gif)

## 🎯 What This Demonstrates

- **Load Balancing**: Single URL serves traffic distributed across multiple instances
- **High Availability**: Service continues even when instances fail
- **Self-Healing**: Auto Scaling Group automatically replaces failed instances
- **Multi-AZ Resilience**: Infrastructure spans multiple Availability Zones

## ✅ Project Status

**Deployed**: February 15, 2026  
**Region**: EU-West-2 (London)  
**Status**: Successfully Deployed and Tested

## 🏗️ Architecture

![Architecture Diagram](diagrams/architecture.png)

### Components

- **Region**: EU-West-2 (London)
- **VPC**: Custom VPC with 10.0.0.0/16 CIDR
- **Subnets**: 2 public subnets across 2 AZs (eu-west-2a, eu-west-2b)
- **Application Load Balancer**: Internet-facing, distributes traffic
- **Auto Scaling Group**: Maintains 2-4 instances across AZs
- **Target Group**: Health checks and routing
- **CloudWatch**: Monitoring and alarms

## 🚀 Quick Start

### Prerequisites

- AWS Account
- Access to EU-West-2 (London) region
- Basic understanding of VPC, EC2, and Load Balancers

### Deployment Steps

Follow the detailed guide in [blog/deployment-guide.md](blog/deployment-guide.md)

**Quick Summary:**
1. Set region to EU-West-2 (London)
2. Create VPC and subnets
3. Configure Internet Gateway and routing
4. Set up Security Groups
5. Create Launch Template with user data
6. Configure Target Group
7. Deploy Application Load Balancer
8. Create Auto Scaling Group
9. Test and validate

## 🧪 Testing & Validation

### Test 1: Load Balancing
```bash
# Access ALB DNS
curl http://your-alb-dns-name.eu-west-2.elb.amazonaws.com

# Refresh multiple times - you'll see different instance IDs
```

### Test 2: High Availability
1. Stop one EC2 instance manually
2. Refresh the ALB URL - service continues
3. ASG detects unhealthy instance and launches replacement

### Test 3: Auto Scaling
1. Generate CPU load on instances
2. Watch ASG scale out when CPU > 60%
3. Observe scale-in when load decreases

## 📊 Monitoring

### CloudWatch Alarms
- ALB 5XX errors
- Unhealthy host count in Target Group
- ASG CPU utilization

### Dashboard Metrics
- Request count
- Healthy host count
- CPU utilization
- Response time

## 💰 Cost Estimate

**Approximate monthly cost (London region):**
- ALB: ~$20/month
- EC2 t2.micro (2 instances): ~$16/month
- Data transfer: Variable
- **Total**: ~$40-50/month

**Free Tier Eligible**: First 12 months may have reduced costs

## 🔒 Security Best Practices

- Security Groups restrict traffic to HTTP/HTTPS only
- SSH access limited to specific IP (optional)
- Private subnets recommended for production databases
- Enable VPC Flow Logs for audit
- Use AWS Systems Manager Session Manager instead of SSH

## 📸 Screenshots

See [screenshots/](screenshots/) folder for:
- ALB working across multiple instances
- Different AZ responses on refresh
- Instance failure with continued service
- ASG auto-replacement

## 🎓 Learning Outcomes

- Understanding AWS high availability patterns
- Hands-on experience with ALB and ASG
- Multi-AZ architecture design
- Infrastructure resilience testing
- CloudWatch monitoring setup

## 🔄 Cleanup

To avoid ongoing charges:
1. Delete Auto Scaling Group
2. Delete Load Balancer
3. Delete Target Group
4. Terminate EC2 instances
5. Delete Launch Template
6. Delete VPC (will cascade delete subnets, IGW, route tables)

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [High Availability Best Practices](https://docs.aws.amazon.com/whitepapers/latest/real-time-communication-on-aws/high-availability-and-scalability-on-aws.html)
- [Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/)

## 📝 License

This project is for educational and portfolio purposes.

## 👤 Author

Your Name - [Your LinkedIn] - [Your Email]

---

**Portfolio Project** | Built with AWS | London Region (EU-West-2)
