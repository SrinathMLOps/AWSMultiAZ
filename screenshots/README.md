# Screenshots Guide

This directory contains screenshots demonstrating the Multi-AZ High Availability architecture in action.

## Required Screenshots

### 1. alb-working.png
**What to capture**: Browser showing the web page served by ALB

**Steps**:
1. Open browser
2. Navigate to ALB DNS: `http://web-alb-xxxxxxxxx.eu-west-2.elb.amazonaws.com`
3. Take screenshot showing:
   - URL bar with ALB DNS
   - Web page content with Instance ID, Hostname, and AZ
   - Browser timestamp/date

**What it proves**: ALB is successfully serving traffic

---

### 2. two-az-refresh.png
**What to capture**: Side-by-side comparison showing different instances

**Steps**:
1. Open ALB URL in browser
2. Take screenshot #1 (shows Instance A in AZ-A)
3. Refresh page
4. Take screenshot #2 (shows Instance B in AZ-B)
5. Combine both screenshots side-by-side using image editor

**What it proves**: Load balancing across multiple AZs

**Alternative**: Create a collage showing 4-6 refreshes with different instance IDs

---

### 3. stop-instance-still-works.png
**What to capture**: AWS Console showing stopped instance + browser still loading

**Steps**:
1. Open AWS Console → EC2 → Instances
2. Select one running instance
3. Instance State → Stop Instance
4. Take screenshot showing:
   - EC2 console with instance in "stopping" or "stopped" state
   - Browser window in background still showing the web page
   - Timestamp visible

**What it proves**: High availability - service continues despite instance failure

**Tip**: Use split-screen or picture-in-picture to show both windows

---

### 4. asg-replaces-instance.png
**What to capture**: ASG Activity History showing replacement

**Steps**:
1. Wait 2-3 minutes after stopping instance
2. Go to EC2 → Auto Scaling Groups → web-asg
3. Click "Activity" tab
4. Take screenshot showing:
   - Activity history with "Terminating EC2 instance" entry
   - Activity history with "Launching a new EC2 instance" entry
   - Timestamps showing automatic replacement
   - Status: "Successful"

**What it proves**: Self-healing capability of ASG

---

## Additional Recommended Screenshots

### 5. target-group-health.png
**What to capture**: Target Group showing healthy instances

**Steps**:
1. EC2 → Target Groups → web-tg
2. Click "Targets" tab
3. Take screenshot showing:
   - Both instances with "healthy" status
   - Health check configuration
   - AZ distribution

---

### 6. cloudwatch-dashboard.png
**What to capture**: CloudWatch dashboard with metrics

**Steps**:
1. CloudWatch → Dashboards → web-app-monitoring
2. Take screenshot showing:
   - CPU utilization graph
   - Request count
   - Healthy host count
   - Response time

---

### 7. alb-configuration.png
**What to capture**: ALB configuration details

**Steps**:
1. EC2 → Load Balancers → web-alb
2. Take screenshot showing:
   - DNS name
   - State: Active
   - Availability Zones: 2
   - Scheme: internet-facing

---

### 8. asg-configuration.png
**What to capture**: ASG configuration

**Steps**:
1. EC2 → Auto Scaling Groups → web-asg
2. Take screenshot showing:
   - Desired capacity: 2
   - Min: 2, Max: 4
   - Instances: 2 running
   - Health check type: ELB

---

### 9. scaling-policy.png
**What to capture**: Auto scaling policy configuration

**Steps**:
1. ASG → Automatic scaling tab
2. Take screenshot showing:
   - Policy name
   - Metric: CPU utilization
   - Target value: 60%
   - Policy type: Target tracking

---

### 10. cloudwatch-alarms.png
**What to capture**: CloudWatch alarms configured

**Steps**:
1. CloudWatch → Alarms
2. Take screenshot showing:
   - Unhealthy host alarm
   - 5XX error alarm
   - Status: OK (green)

---

## Screenshot Best Practices

### Quality
- Use high resolution (1920x1080 or higher)
- Ensure text is readable
- Avoid compression artifacts
- Use PNG format for clarity

### Content
- Blur/redact sensitive information:
  - AWS Account ID
  - Personal email addresses
  - IP addresses (optional)
  - Access keys or credentials
- Keep AWS region visible (eu-west-2)
- Include timestamps when relevant

### Organization
- Name files descriptively
- Use consistent naming convention
- Add captions in README if needed
- Consider creating a collage for portfolio

### Tools
- **Windows**: Snipping Tool, Snip & Sketch, ShareX
- **Mac**: Command+Shift+4
- **Linux**: Flameshot, GNOME Screenshot
- **Browser**: Full page screenshot extensions

### Editing
- Use tools like:
  - GIMP (free)
  - Paint.NET (Windows)
  - Preview (Mac)
  - Photopea (web-based)
- Add arrows or highlights to emphasize key points
- Create side-by-side comparisons
- Add text annotations if helpful

## Creating a Portfolio Collage

Combine screenshots into a single portfolio image:

1. **Layout**: 2x2 or 3x2 grid
2. **Include**:
   - ALB serving page
   - Different instances on refresh
   - Instance stopped + site working
   - ASG replacement activity
3. **Add**:
   - Title: "AWS Multi-AZ High Availability POC"
   - Brief captions for each screenshot
   - Your name/contact
4. **Export**: High-quality PNG or PDF

## Verification Checklist

Before considering screenshots complete:

- [ ] ALB DNS visible and working
- [ ] Multiple instance IDs shown across refreshes
- [ ] Both AZs (eu-west-2a and eu-west-2b) visible
- [ ] Instance failure captured
- [ ] Service continuity demonstrated
- [ ] ASG replacement activity shown
- [ ] Target Group health status visible
- [ ] CloudWatch metrics displayed
- [ ] All sensitive data redacted
- [ ] Images are high quality and readable

## Usage in Portfolio

### GitHub README
```markdown
## Demo Screenshots

![Load Balancing](screenshots/two-az-refresh.png)
*Load balancing across multiple Availability Zones*

![High Availability](screenshots/stop-instance-still-works.png)
*Service continues despite instance failure*
```

### LinkedIn Post
- Use the collage as main image
- Reference individual screenshots in article
- Link to GitHub repo for full details

### Resume/CV
- Include architecture diagram
- Reference project with link to repo
- Mention key technologies: AWS, ALB, ASG, Multi-AZ

---

**Note**: Take screenshots as you complete each step of the deployment. It's easier to capture in real-time than to recreate later!
