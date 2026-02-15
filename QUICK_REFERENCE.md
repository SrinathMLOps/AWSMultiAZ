# Quick Reference Guide - AWS Multi-AZ Setup

## 🚀 Quick Deploy Checklist

- [ ] Set region to eu-west-2 (London)
- [ ] Create VPC (10.0.0.0/16)
- [ ] Create 2+ public subnets in different AZs
- [ ] Enable auto-assign public IP on subnets
- [ ] Create Internet Gateway and attach to VPC
- [ ] Configure route table (0.0.0.0/0 → IGW)
- [ ] Create security group (HTTP:80, SSH:22)
- [ ] Create launch template with user data
- [ ] Create target group (HTTP:80, path: /)
- [ ] Create ALB (internet-facing, 2+ AZs)
- [ ] Create ASG (min:2, desired:2, max:4)
- [ ] Attach ASG to target group
- [ ] Test ALB DNS URL
- [ ] Verify load balancing (refresh multiple times)
- [ ] Test high availability (stop instance)

---

## 📋 Resource Names Used

| Resource | Name | Value |
|----------|------|-------|
| VPC | poc-multiaz-vpc | 10.0.0.0/16 |
| Subnet 1 | public-a | 10.0.1.0/24 (eu-west-2a) |
| Subnet 2 | public-b | 10.0.2.0/24 (eu-west-2b) |
| Security Group | web-sg | HTTP:80, SSH:22 |
| Launch Template | web-app-template | Amazon Linux 2023, t2.micro |
| Target Group | web-tg | HTTP:80 |
| Load Balancer | web-alb | Internet-facing |
| Auto Scaling Group | web-asg | 2-4 instances |

---

## 🔧 Working User Data Script

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AZ=$(ec2-metadata --availability-zone | cut -d " " -f 2)
HOSTNAME=$(hostname)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Multi-AZ POC</title></head>
<body style="font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px;">
<h1 style="color: #232f3e;">Multi-AZ High Availability POC</h1>
<div style="background: #f0f0f0; padding: 20px; border-left: 4px solid #ff9900;">
<p><strong>Instance ID:</strong> $INSTANCE_ID</p>
<p><strong>Hostname:</strong> $HOSTNAME</p>
<p><strong>Availability Zone:</strong> $AZ</p>
</div>
<p>Refresh to see load balancing!</p>
</body>
</html>
EOF
```

---

## ⚠️ Common Issues & Fixes

### Issue: Instances Unhealthy
**Fix**: Check security group has HTTP:80 inbound rule from 0.0.0.0/0

### Issue: 502 Bad Gateway
**Fix**: Instances not healthy. Wait 5 minutes or check Apache is running

### Issue: Can't Connect to Instance
**Fix**: Use system logs instead: Actions → Monitor → Get system log

### Issue: User Data Not Running
**Fix**: Check system log for cloud-init errors. Simplify script.

### Issue: Instances Not in Target Group
**Fix**: Edit ASG → Attach to existing load balancer target group

---

## 🧪 Testing Commands

### Test Load Balancing
```bash
# In browser, refresh multiple times
http://web-alb-xxxxxxxxx.eu-west-2.elb.amazonaws.com

# Or use curl
for i in {1..10}; do curl http://your-alb-dns; echo ""; done
```

### Check Instance Health (from within instance)
```bash
sudo systemctl status httpd
curl localhost
ec2-metadata --all
```

### View Logs
```bash
# Cloud-init log
sudo cat /var/log/cloud-init-output.log

# Apache logs
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```

---

## 🗑️ Cleanup Order

1. Delete Auto Scaling Group
2. Wait for instances to terminate
3. Delete Load Balancer
4. Delete Target Group
5. Delete Launch Template
6. Delete Security Group
7. Delete VPC (cascades everything else)

---

## 💰 Cost Estimate

- ALB: ~$20/month
- EC2 (2x t2.micro): ~$16/month
- Data transfer: ~$5-10/month
- **Total**: ~$45-50/month

---

## 📊 Key Metrics

- **Availability Zones**: 2 (eu-west-2a, eu-west-2b)
- **Instances**: 2-4 (auto-scaling)
- **Health Check Interval**: 30 seconds
- **Health Check Timeout**: 5 seconds
- **Grace Period**: 300 seconds
- **Target CPU**: 60% (for scaling)

---

## 🔗 Quick Links

- [AWS Console](https://console.aws.amazon.com/)
- [EC2 Dashboard](https://eu-west-2.console.aws.amazon.com/ec2/)
- [VPC Dashboard](https://eu-west-2.console.aws.amazon.com/vpc/)
- [CloudWatch](https://eu-west-2.console.aws.amazon.com/cloudwatch/)

---

## 📝 Notes

- Always use **eu-west-2** (London) region
- Minimum **2 AZs** required for ALB
- Enable **auto-assign public IP** on subnets
- Use **ELB health checks** in ASG (not just EC2)
- **Grace period** prevents premature termination
- **User data** runs only on first boot

---

## ✅ Success Criteria

- [ ] ALB DNS loads web page
- [ ] Refresh shows different instance IDs
- [ ] Both AZs (2a and 2b) appear
- [ ] Stopping instance doesn't break service
- [ ] ASG launches replacement instance
- [ ] All targets show "healthy" status

---

**Last Updated**: February 15, 2026
**Status**: ✅ Deployed and Tested
