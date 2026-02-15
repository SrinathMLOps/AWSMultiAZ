# AWS Multi-AZ Resources - Pause/Stop Guide

## 💡 Stop Resources Without Deleting

This guide shows how to temporarily stop resources to avoid charges while keeping your configuration intact for future use.

---

## ⚠️ Important: What You Can and Cannot Stop

### ✅ Can Be Stopped (No Charges When Stopped)
- **EC2 Instances** - Stop paying for compute
- **Auto Scaling Group** - Set capacity to 0

### ❌ Cannot Be Stopped (Always Charges)
- **Application Load Balancer** - ~$20/month (always charges)
- **VPC, Subnets, Route Tables** - Free (no charges)
- **Security Groups** - Free (no charges)
- **Target Group** - Free (no charges)
- **Launch Template** - Free (no charges)

### 💰 Cost Breakdown When "Paused"
- ALB: ~$20/month (still charges!)
- EC2 Instances: $0 (stopped)
- Data Transfer: $0 (no traffic)
- **Total**: ~$20/month

---

## 🛑 Option 1: Stop EC2 Instances Only (Partial Savings)

**Saves**: ~$16/month (EC2 costs)  
**Still Costs**: ~$20/month (ALB)  
**Total Savings**: ~44% reduction

### Steps:

1. **Go to EC2 Dashboard**
2. Click **"Instances"** in left sidebar
3. Select all **`web-instance`** instances (checkboxes)
4. Click **"Instance state"** dropdown
5. Select **"Stop instance"**
6. Click **"Stop"** in confirmation dialog

**What Happens**:
- Instances enter "Stopping" state
- After 1-2 minutes, show "Stopped" state
- ALB will show all targets as "Unhealthy"
- Website will be down (502 Bad Gateway)
- You keep all configurations

**To Restart**:
1. Select stopped instances
2. Instance state → **"Start instance"**
3. Wait 2-3 minutes for instances to start
4. Wait 2-3 more minutes for health checks to pass
5. Website will be back online

---

## 🛑 Option 2: Set Auto Scaling Group to Zero (Better Approach)

**Saves**: ~$16/month (EC2 costs)  
**Still Costs**: ~$20/month (ALB)  
**Total Savings**: ~44% reduction

### Steps:

1. **Go to EC2 Dashboard**
2. Click **"Auto Scaling Groups"** in left sidebar
3. Select **`web-asg`** (checkbox)
4. Click **"Edit"** button (or Actions → Edit)
5. Change these values:
   - **Desired capacity**: `0`
   - **Minimum capacity**: `0`
   - **Maximum capacity**: `0` (or keep at 4)
6. Click **"Update"**

**What Happens**:
- ASG automatically terminates all instances
- Takes 2-3 minutes
- ALB shows no targets
- Website will be down (503 Service Unavailable)
- All configurations preserved

**To Restart**:
1. Edit ASG again
2. Change values back:
   - **Desired capacity**: `2`
   - **Minimum capacity**: `2`
   - **Maximum capacity**: `4`
3. Click **"Update"**
4. ASG launches 2 new instances
5. Wait 5-7 minutes for instances to become healthy
6. Website will be back online

---

## 💰 Option 3: Delete ALB Only (Maximum Savings)

**Saves**: ~$36/month (EC2 + ALB)  
**Still Costs**: $0  
**Total Savings**: 100% reduction

**Trade-off**: You'll need to recreate the ALB when you restart

### Steps:

1. **Set ASG capacity to 0** (see Option 2)
2. **Wait for instances to terminate** (2-3 minutes)
3. **Delete Load Balancer**:
   - EC2 → Load Balancers
   - Select `web-alb`
   - Actions → Delete
   - Type `confirm` → Delete
4. **Keep everything else**:
   - Target Group (free)
   - Launch Template (free)
   - ASG (free when capacity is 0)
   - VPC, Subnets, Security Groups (all free)

**To Restart**:
1. Recreate ALB (follow deployment guide Step 7)
2. Attach to existing Target Group
3. Set ASG capacity back to 2
4. Wait 5-7 minutes
5. Website back online with new ALB DNS

---

## 📊 Cost Comparison

| Option | Monthly Cost | Savings | Restart Time | Complexity |
|--------|-------------|---------|--------------|------------|
| **Keep Running** | ~$45 | 0% | N/A | N/A |
| **Stop EC2 Only** | ~$20 | 44% | 5 minutes | Easy |
| **ASG to Zero** | ~$20 | 44% | 7 minutes | Easy |
| **Delete ALB** | $0 | 100% | 15 minutes | Medium |
| **Delete Everything** | $0 | 100% | 30+ minutes | Hard |

---

## 🎯 Recommended Approach

### For Short-Term Pause (1-7 days)
**Use Option 2: Set ASG to Zero**

**Why?**
- Easy to restart (just change capacity)
- Preserves all configurations
- Quick restart (5-7 minutes)
- Saves EC2 costs (~$16/month)

**Cost**: ~$20/month for ALB

### For Long-Term Pause (1+ weeks)
**Use Option 3: Delete ALB**

**Why?**
- Zero costs
- Easy to recreate ALB
- All other configs preserved
- Worth the extra setup time

**Cost**: $0/month

### For Permanent Removal
**Use Full Cleanup Guide**

**Why?**
- Complete removal
- No residual costs
- Clean AWS account

**Cost**: $0/month

---

## 🔄 Quick Pause/Resume Commands

### Pause (Set ASG to Zero)
```bash
# Using AWS Console:
EC2 → Auto Scaling Groups → web-asg → Edit
Set: Desired=0, Min=0, Max=0 → Update

# Using AWS CLI:
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --desired-capacity 0 \
  --min-size 0 \
  --max-size 0 \
  --region eu-west-2
```

### Resume (Set ASG Back to 2)
```bash
# Using AWS Console:
EC2 → Auto Scaling Groups → web-asg → Edit
Set: Desired=2, Min=2, Max=4 → Update

# Using AWS CLI:
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --desired-capacity 2 \
  --min-size 2 \
  --max-size 4 \
  --region eu-west-2
```

---

## ⏱️ Restart Time Estimates

### From ASG Zero to Running
```
1. Edit ASG capacity (30 seconds)
2. ASG launches instances (1-2 minutes)
3. User data script runs (1-2 minutes)
4. Health checks pass (2-3 minutes)
───────────────────────────────────
Total: 5-7 minutes
```

### From Stopped Instances to Running
```
1. Start instances (30 seconds)
2. Instances boot up (1-2 minutes)
3. Apache starts (30 seconds)
4. Health checks pass (2-3 minutes)
───────────────────────────────────
Total: 4-6 minutes
```

### From Deleted ALB to Running
```
1. Recreate ALB (5 minutes)
2. Configure listener (1 minute)
3. Attach Target Group (1 minute)
4. Set ASG capacity (30 seconds)
5. Instances launch and become healthy (5-7 minutes)
───────────────────────────────────
Total: 12-15 minutes
```

---

## 🚨 Important Notes

### About Stopped EC2 Instances
- ✅ No compute charges
- ✅ Configuration preserved
- ✅ Same instance IDs
- ⚠️ **EBS volumes still charge** (~$1/month per instance)
- ⚠️ Public IP may change when restarted
- ⚠️ Elastic IPs cost money when instance is stopped

### About ALB
- ❌ Cannot be "stopped" or "paused"
- ❌ Always charges ~$20/month when it exists
- ✅ Only way to avoid charges: Delete it
- ✅ Easy to recreate with same configuration

### About Auto Scaling Group
- ✅ Free when capacity is 0
- ✅ Preserves all configuration
- ✅ Preserves scaling policies
- ✅ Easy to restart

---

## 📋 Pause Checklist

**Before Pausing**:
- [ ] Take screenshots of working setup
- [ ] Note down ALB DNS name
- [ ] Document any custom configurations
- [ ] Export CloudWatch metrics if needed

**To Pause (Recommended)**:
- [ ] Set ASG desired capacity to 0
- [ ] Set ASG minimum capacity to 0
- [ ] Wait for instances to terminate
- [ ] Verify no instances running
- [ ] (Optional) Delete ALB for full savings

**To Resume**:
- [ ] (If deleted) Recreate ALB
- [ ] Set ASG desired capacity to 2
- [ ] Set ASG minimum capacity to 2
- [ ] Wait 5-7 minutes
- [ ] Test ALB DNS
- [ ] Verify instances healthy

---

## 💡 Pro Tips

### Tip 1: Use CloudFormation or Terraform
If you plan to pause/resume frequently, consider using Infrastructure as Code:
- Store configuration in code
- Delete everything when not in use
- Recreate in minutes with one command
- Zero cost when not running

### Tip 2: Schedule with Lambda
Create a Lambda function to:
- Stop resources at night (e.g., 6 PM)
- Start resources in morning (e.g., 8 AM)
- Save money during off-hours
- Automate the process

### Tip 3: Use AWS Budgets
Set up billing alerts:
- Alert when cost > $10/month
- Alert when cost > $30/month
- Get notified before surprise bills

### Tip 4: Tag Resources
Add tags for easy identification:
- Project: MultiAZ-POC
- Environment: Demo
- Owner: Your-Name
- Purpose: Portfolio

---

## 🔍 Verify Costs After Pausing

### Check AWS Cost Explorer
1. Go to **AWS Billing Dashboard**
2. Click **"Cost Explorer"**
3. View costs by service
4. Verify EC2 costs dropped to $0
5. Verify ALB costs (if kept) are ~$20/month

### Check Current Month Charges
1. Go to **AWS Billing Dashboard**
2. Click **"Bills"**
3. Expand **"Charges by service"**
4. Look for:
   - EC2: Should be minimal or $0
   - Elastic Load Balancing: ~$20 if ALB kept
   - VPC: $0 (free)

---

## ⚠️ What NOT to Do

### ❌ Don't Just Stop Instances Manually
- ASG will restart them automatically
- You'll still get charged
- Use ASG capacity instead

### ❌ Don't Leave Elastic IPs Unattached
- Elastic IPs cost money when not attached
- We're not using Elastic IPs in this setup
- But good to know for future

### ❌ Don't Forget About ALB
- It's the biggest cost (~$20/month)
- Cannot be stopped, only deleted
- Remember to delete if you want zero cost

### ❌ Don't Delete Target Group
- It's free
- Preserves health check configuration
- Easy to reattach to new ALB

---

## 📞 Need Help?

If you encounter issues:

1. **Check ASG Activity**
   - EC2 → Auto Scaling Groups → web-asg → Activity tab
   - Look for errors

2. **Check Instance State**
   - EC2 → Instances
   - Verify instances are stopped/terminated

3. **Check Billing**
   - Billing Dashboard → Bills
   - Verify charges are as expected

---

## ✅ Summary

**Best Option for Most Users**:
1. Set ASG capacity to 0
2. Keep ALB if resuming within a week
3. Delete ALB if pausing longer than a week

**Cost When Paused**:
- With ALB: ~$20/month
- Without ALB: $0/month

**Resume Time**:
- With ALB: 5-7 minutes
- Without ALB: 12-15 minutes

---

**Project**: AWS Multi-AZ High Availability POC  
**Pause Method**: Set ASG Capacity to Zero  
**Cost When Paused**: ~$20/month (ALB only) or $0 (if ALB deleted)  
**Resume Time**: 5-15 minutes
