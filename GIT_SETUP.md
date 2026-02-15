# Git Repository Setup Instructions

## Initial Setup

### 1. Initialize Git Repository

```bash
git init
```

### 2. Add All Files

```bash
git add .
```

### 3. Create Initial Commit

```bash
git commit -m "Initial commit: AWS Multi-AZ High Availability POC with complete documentation"
```

### 4. Rename Branch to Main

```bash
git branch -M main
```

### 5. Add Remote Repository

```bash
git remote add origin https://github.com/SrinathMLOps/AWSMultiAZ.git
```

### 6. Push to GitHub

```bash
git push -u origin main
```

---

## Files Included in Repository

```
AWSMultiAZ/
├── README.md                      # Main project overview with demo GIF
├── DEPLOYMENT_NOTES.md            # Complete deployment documentation
├── QUICK_REFERENCE.md             # Quick reference guide
├── GIT_SETUP.md                   # This file - Git setup instructions
├── .gitignore                     # Git ignore file
├── MultiAz.gif                    # Demo GIF showing load balancing
├── blog/
│   ├── deployment-guide.md        # Step-by-step deployment guide
│   └── post.md                    # Portfolio blog post
├── diagrams/
│   └── architecture.md            # Architecture diagram guide
└── screenshots/
    └── README.md                  # Screenshot capture guide
```

---

## Verify Git Configuration

```bash
# Check remote
git remote -v

# Check branch
git branch

# Check status
git status
```

---

## Update Repository (Future Changes)

```bash
# Check what changed
git status

# Add specific files
git add filename.md

# Or add all changes
git add .

# Commit with message
git commit -m "Description of changes"

# Push to GitHub
git push origin main
```

---

## Common Git Commands

```bash
# View commit history
git log --oneline

# View changes
git diff

# Undo changes (before commit)
git checkout -- filename.md

# Create new branch
git checkout -b feature-branch

# Switch branches
git checkout main

# Merge branch
git merge feature-branch

# Pull latest changes
git pull origin main
```

---

## GitHub Repository Setup

1. Go to https://github.com/SrinathMLOps/AWSMultiAZ
2. Repository should now contain all files
3. README.md will display on main page with GIF
4. Add topics/tags: `aws`, `high-availability`, `load-balancer`, `auto-scaling`, `multi-az`
5. Add description: "AWS Multi-AZ High Availability Web App with ALB and ASG"

---

## Repository Features to Enable

- [ ] Add repository description
- [ ] Add topics/tags
- [ ] Enable Issues (for tracking)
- [ ] Enable Discussions (optional)
- [ ] Add LICENSE file (MIT recommended)
- [ ] Enable GitHub Pages (optional - for blog)
- [ ] Add repository social preview image (use MultiAz.gif)

---

## Sharing Your Project

### LinkedIn Post Template
```
🚀 Just deployed a highly available web application on AWS!

✅ Multi-AZ architecture across London region
✅ Application Load Balancer for traffic distribution
✅ Auto Scaling Group for self-healing
✅ Tested high availability and load balancing

Check out the full project: https://github.com/SrinathMLOps/AWSMultiAZ

#AWS #CloudComputing #DevOps #HighAvailability #Infrastructure
```

### Portfolio Description
```
AWS Multi-AZ High Availability Architecture

Designed and deployed a production-ready, highly available web application 
using AWS services including VPC, ALB, ASG, and EC2 across multiple 
Availability Zones. Demonstrated load balancing, self-healing, and 
fault tolerance capabilities.

Technologies: AWS, VPC, ALB, ASG, EC2, CloudWatch
Region: EU-West-2 (London)
```

---

## Next Steps

1. ✅ Push code to GitHub
2. Add MultiAz.gif to repository
3. Update repository settings
4. Add topics and description
5. Share on LinkedIn
6. Add to portfolio website
7. Consider writing detailed blog post

---

**Repository URL**: https://github.com/SrinathMLOps/AWSMultiAZ
**Author**: Srinath
**Date**: February 15, 2026
