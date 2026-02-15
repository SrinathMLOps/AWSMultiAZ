# AWS Multi-AZ Resource Cleanup Guide

## ⚠️ Important: Delete in This Exact Order

Deleting resources in the wrong order will cause dependency errors. Follow this sequence carefully.

---

## 🗑️ Step-by-Step Deletion Process

### Step 1: Delete Auto Scaling Group ⏱️ 2-3 minutes

**Why First?** ASG will automatically terminate all EC2 instances it manages.

1. Go to **EC2 Dashboard**
2. In left sidebar, click **"Auto Scaling Groups"** (under Auto Scaling section)
3. Select **`web-asg`** (checkbox)
4. Click **"Actions"** dropdown
5. Select **"Delete"**
6. Type **`delete`** in the confirmation box
7. Click **"Delete"**

**What Happens**:
- ASG begins terminating all instances
- Instances will show "Terminating" state
- Takes 1-2 minutes to complete

**Verify**:
- Go to **EC2 → Instances**
- All `web-instance` instances should show "Terminated"
- Wait until all instances are fully terminated before proceeding

---

### Step 2: Delete Load Balancer ⏱️ 3-5 minutes

**Why Second?** ALB must be deleted before Target Group.

1. Go to **EC2 Dashboard**
2. In left sidebar, click **"Load Balancers"** (under Load Balancing section)
3. Select **`web-alb`** (checkbox)
4. Click **"Actions"** dropdown
5. Select **"Delete load balancer"**
6. Type **`confirm`** in the confirmation box
7. Click **"Delete"**

**What Happens**:
- ALB enters "deleting" state
- Takes 2-3 minutes to fully delete
- DNS name will stop resolving

**Verify**:
- Refresh the Load Balancers page
- `web-alb` should disappear from the list
- Wait until completely gone before proceeding

**⚠️ Important**: This is the slowest step. Be patient!

---

### Step 3: Delete Target Group ⏱️ 30 seconds

**Why Third?** Target Group can only be deleted after ALB is gone.

1. Go to **EC2 Dashboard**
2. In left sidebar, click **"Target Groups"** (under Load Balancing section)
3. Select **`web-tg`** (checkbox)
4. Click **"Actions"** dropdown
5. Select **"Delete"**
6. Click **"Yes, delete"** in the confirmation dialog

**What Happens**:
- Target Group is immediately deleted
- All health check configurations removed

**Verify**:
- Target Group disappears from the list

---

### Step 4: Delete Launch Template ⏱️ 10 seconds

**Why Fourth?** No longer needed after ASG is deleted.

1. Go to **EC2 Dashboard**
2. In left sidebar, click **"Launch Templates"** (under Instances section)
3. Select **`web-app-template`** (checkbox)
4. Click **"Actions"** dropdown
5. Select **"Delete template"**
6. Click **"Delete"** in the confirmation dialog

**What Happens**:
- Launch template and all versions deleted
- User data script removed

**Verify**:
- Launch template disappears from the list

---

### Step 5: Delete Security Group ⏱️ 30 seconds

**Why Fifth?** Must wait for all instances to be terminated first.

1. Go to **EC2 Dashboard**
2. In left sidebar, click **"Security Groups"** (under Network & Security section)
3. Find **`web-sg`**
4. Select **`web-sg`** (checkbox)
5. Click **"Actions"** dropdown
6. Select **"Delete security groups"**
7. Click **"Delete"** in the confirmation dialog

**Possible Error**:
```
"Cannot delete security group because it is in use"
```

**Solution**:
- Wait 1-2 more minutes for instances to fully terminate
- Refresh the page
- Try again

**Verify**:
- Security group disappears from the list

---

### Step 6: Delete VPC (Cascades Everything) ⏱️ 1-2 minutes

**Why Last?** VPC deletion will automatically delete all associated resources.

1. Go to **VPC Dashboard**
2. In left sidebar, click **"Your VPCs"**
3. Select **`poc-multiaz-vpc`** (checkbox)
4. Click **"Actions"** dropdown
5. Select **"Delete VPC"**
6. Type **`delete`** in the confirmation box
7. Click **"Delete"**

**What Gets Deleted Automatically**:
- ✅ All subnets (public-a, public-b, public-c)
- ✅ Internet Gateway (automatically detached and deleted)
- ✅ Route tables (except main route table)
- ✅ Network ACLs (except default)
- ✅ VPC itself

**Verify**:
- VPC disappears from the list
- Check subnets - all should be gone
- Check Internet Gateways - should be gone

---

## ✅ Verification Checklist

After completing all steps, verify everything is deleted:

### EC2 Resources
- [ ] Go to **EC2 → Instances** - No `web-instance` instances (or all show "Terminated")
- [ ] Go to **EC2 → Auto Scaling Groups** - `web-asg` is gone
- [ ] Go to **EC2 → Load Balancers** - `web-alb` is gone
- [ ] Go to **EC2 → Target Groups** - `web-tg` is gone
- [ ] Go to **EC2 → Launch Templates** - `web-app-template` is gone
- [ ] Go to **EC2 → Security Groups** - `web-sg` is gone

### VPC Resources
- [ ] Go to **VPC → Your VPCs** - `poc-multiaz-vpc` is gone
- [ ] Go to **VPC → Subnets** - No subnets from your VPC
- [ ] Go to **VPC → Internet Gateways** - Your IGW is gone
- [ ] Go to **VPC → Route Tables** - Your route tables are gone

---

## 🚨 Common Issues & Solutions

### Issue 1: "Cannot delete Auto Scaling Group"
**Error**: "Auto Scaling Group has instances"

**Solution**:
```
1. Edit ASG
2. Set Desired Capacity to 0
3. Set Minimum Capacity to 0
4. Wait for instances to terminate
5. Try deleting ASG again
```

---

### Issue 2: "Cannot delete Load Balancer"
**Error**: "Load Balancer is still in use"

**Solution**:
```
1. Check if ASG is still attached
2. Delete ASG first
3. Wait 2-3 minutes
4. Try deleting ALB again
```

---

### Issue 3: "Cannot delete Target Group"
**Error**: "Target Group is associated with a load balancer"

**Solution**:
```
1. Ensure ALB is fully deleted (not just "deleting")
2. Wait 3-5 minutes
3. Refresh the page
4. Try deleting Target Group again
```

---

### Issue 4: "Cannot delete Security Group"
**Error**: "Security group is in use"

**Solution**:
```
1. Go to EC2 → Instances
2. Verify ALL instances are "Terminated" (not just "Terminating")
3. Wait 2-3 minutes
4. Try deleting Security Group again
```

**Alternative**:
```
1. Click on the Security Group
2. Check "Inbound rules" and "Outbound rules"
3. Look for any resources still using it
4. Delete those resources first
```

---

### Issue 5: "Cannot delete VPC"
**Error**: "VPC has dependencies"

**Solution**:
```
1. Check for remaining resources:
   - EC2 Instances
   - Load Balancers
   - NAT Gateways
   - VPC Endpoints
   - Elastic IPs

2. Delete any remaining resources

3. Try deleting VPC again
```

---

## ⏱️ Total Cleanup Time

**Estimated Time**: 10-15 minutes

**Breakdown**:
- Step 1 (ASG): 2-3 minutes
- Step 2 (ALB): 3-5 minutes ⏰ Longest step
- Step 3 (Target Group): 30 seconds
- Step 4 (Launch Template): 10 seconds
- Step 5 (Security Group): 30 seconds
- Step 6 (VPC): 1-2 minutes

**Pro Tip**: Start the deletion process, then take a coffee break! ☕

---

## 💰 Cost Savings After Cleanup

Once all resources are deleted, you will stop incurring charges for:

- ✅ Application Load Balancer (~$20/month)
- ✅ EC2 Instances (~$16/month for 2x t2.micro)
- ✅ Data Transfer (~$5-10/month)
- ✅ CloudWatch (minimal, ~$3/month)

**Total Savings**: ~$45-50/month

---

## 🔄 Quick Cleanup Script (Alternative)

If you're comfortable with AWS CLI, you can use these commands:

```bash
# Set your region
export AWS_REGION=eu-west-2

# Step 1: Delete Auto Scaling Group
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --force-delete \
  --region $AWS_REGION

# Wait for instances to terminate
echo "Waiting for instances to terminate..."
sleep 120

# Step 2: Delete Load Balancer
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names web-alb \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text \
  --region $AWS_REGION)

aws elbv2 delete-load-balancer \
  --load-balancer-arn $ALB_ARN \
  --region $AWS_REGION

# Wait for ALB to delete
echo "Waiting for ALB to delete..."
sleep 180

# Step 3: Delete Target Group
TG_ARN=$(aws elbv2 describe-target-groups \
  --names web-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text \
  --region $AWS_REGION)

aws elbv2 delete-target-group \
  --target-group-arn $TG_ARN \
  --region $AWS_REGION

# Step 4: Delete Launch Template
aws ec2 delete-launch-template \
  --launch-template-name web-app-template \
  --region $AWS_REGION

# Step 5: Delete Security Group
SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=web-sg" \
  --query 'SecurityGroups[0].GroupId' \
  --output text \
  --region $AWS_REGION)

aws ec2 delete-security-group \
  --group-id $SG_ID \
  --region $AWS_REGION

# Step 6: Delete VPC
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=poc-multiaz-vpc" \
  --query 'Vpcs[0].VpcId' \
  --output text \
  --region $AWS_REGION)

aws ec2 delete-vpc \
  --vpc-id $VPC_ID \
  --region $AWS_REGION

echo "Cleanup complete!"
```

**Note**: This script requires AWS CLI installed and configured.

---

## 📋 Cleanup Checklist (Print This!)

```
□ Step 1: Delete Auto Scaling Group (web-asg)
  □ Wait for instances to terminate
  
□ Step 2: Delete Load Balancer (web-alb)
  □ Wait 3-5 minutes for deletion
  
□ Step 3: Delete Target Group (web-tg)

□ Step 4: Delete Launch Template (web-app-template)

□ Step 5: Delete Security Group (web-sg)
  □ If error, wait for instances to fully terminate
  
□ Step 6: Delete VPC (poc-multiaz-vpc)
  □ Automatically deletes subnets, IGW, route tables

□ Verification: Check all resources are gone
  □ EC2 Instances
  □ Auto Scaling Groups
  □ Load Balancers
  □ Target Groups
  □ Launch Templates
  □ Security Groups
  □ VPC and subnets
  □ Internet Gateway

□ Final Check: No unexpected charges on AWS bill
```

---

## 🎯 Best Practices

### Before Deleting
1. **Take screenshots** of your working setup (for portfolio)
2. **Document configurations** (already done in this repo!)
3. **Export CloudWatch metrics** if needed
4. **Save any logs** you want to keep

### During Deletion
1. **Follow the order** exactly as listed
2. **Wait for each step** to complete before moving to next
3. **Don't skip verification** steps
4. **Be patient** with ALB deletion (slowest step)

### After Deletion
1. **Verify all resources** are gone
2. **Check AWS billing** dashboard after 24 hours
3. **Confirm no unexpected charges**
4. **Keep documentation** for future reference

---

## 🔐 Security Note

After cleanup, ensure:
- [ ] No orphaned Elastic IPs (they cost money!)
- [ ] No unused EBS volumes
- [ ] No forgotten snapshots
- [ ] No CloudWatch alarms still active

---

## 📞 Need Help?

If you encounter issues:

1. **Check AWS Service Health Dashboard**
   - https://status.aws.amazon.com/

2. **Review AWS Documentation**
   - [Deleting Auto Scaling Groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-process-shutdown.html)
   - [Deleting Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-delete.html)
   - [Deleting VPCs](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#VPC_Deleting)

3. **AWS Support**
   - If you have AWS Support plan, open a ticket

---

## ✅ Cleanup Complete!

Once all resources are deleted:
- ✅ No more AWS charges for this project
- ✅ Clean AWS account
- ✅ Ready to rebuild if needed
- ✅ Documentation saved in this repository

**You can always rebuild this architecture using the deployment guide!**

---

**Project**: AWS Multi-AZ High Availability POC  
**Cleanup Time**: 10-15 minutes  
**Cost After Cleanup**: $0/month ✅
