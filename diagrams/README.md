# Architecture Diagrams

This folder contains visual diagrams for the AWS Multi-AZ High Availability project.

---

## 📊 Available Diagrams

### 1. Complete Architecture Diagram ⭐ NEW
**File**: `complete-architecture-diagram.html`

Comprehensive view showing traffic flow, infrastructure control, and VPC layout all in one diagram.

**Includes**:
- User to Internet Gateway flow
- VPC boundary with CIDR
- Application Load Balancer
- Target Group with health checks
- Multi-AZ subnets (eu-west-2a, eu-west-2b)
- EC2 instances in each AZ
- Auto Scaling Group
- Launch Template
- CloudWatch monitoring
- Route Table configuration
- Complete component legend

### 2. Traffic Flow Diagram
**File**: `traffic-flow-diagram.html`

Shows the complete request/response flow from user to EC2 instances and back.

**Includes**:
- User browser
- Internet layer
- Internet Gateway
- Application Load Balancer
- Target Group
- EC2 Instances (Multi-AZ)
- Response path

### 3. Infrastructure Control Layer Diagram
**File**: `infrastructure-control-diagram.html`

Shows the automation and control plane that manages the infrastructure.

**Includes**:
- Launch Template
- Auto Scaling Group
- EC2 Instances
- Health Checks
- CloudWatch Monitoring
- Scaling Actions

---

## 🎨 How to View Diagrams

### Option 1: Open in Browser (Easiest)
1. Double-click the HTML file
2. It will open in your default browser
3. View the interactive, colorful diagram

### Option 2: Save as Image
1. Open the HTML file in browser
2. Right-click on the page
3. Select "Save as PDF" or "Print to PDF"
4. Or use browser screenshot tools (F12 → Ctrl+Shift+P → "Capture full size screenshot")

### Option 3: Use Online Tools
1. Open the HTML file in browser
2. Use browser extensions like:
   - **Awesome Screenshot**
   - **Nimbus Screenshot**
   - **GoFullPage**
3. Save as PNG or JPG

---

## 📸 Creating PNG/JPG Images

### Method 1: Browser Screenshot (Windows)
```
1. Open HTML file in Chrome/Edge
2. Press F12 (Developer Tools)
3. Press Ctrl+Shift+P
4. Type "screenshot"
5. Select "Capture full size screenshot"
6. Image saves to Downloads folder
```

### Method 2: Browser Screenshot (Mac)
```
1. Open HTML file in Chrome/Safari
2. Press Cmd+Option+I (Developer Tools)
3. Press Cmd+Shift+P
4. Type "screenshot"
5. Select "Capture full size screenshot"
6. Image saves to Downloads folder
```

### Method 3: Print to PDF
```
1. Open HTML file in browser
2. Press Ctrl+P (Windows) or Cmd+P (Mac)
3. Select "Save as PDF"
4. Save the PDF
5. Convert PDF to PNG using online tools if needed
```

### Method 4: Snipping Tool (Windows)
```
1. Open HTML file in browser
2. Press Windows+Shift+S
3. Select area to capture
4. Image copies to clipboard
5. Paste into Paint/PowerPoint and save
```

### Method 5: Screenshot (Mac)
```
1. Open HTML file in browser
2. Press Cmd+Shift+4
3. Drag to select area
4. Image saves to Desktop
```

---

## 🎨 Diagram Features

### Visual Design
- ✅ Gradient backgrounds
- ✅ Color-coded components
- ✅ Icons for each layer
- ✅ Clear flow arrows
- ✅ Labels and descriptions
- ✅ Professional styling

### Components Color Coding

**Traffic Flow Diagram**:
- 🌍 User: Pink gradient
- ☁️ Internet: Blue gradient
- 🚪 IGW: Green gradient
- ⚖️ ALB: Orange gradient
- 🎯 Target Group: Purple gradient
- 🖥️ EC2: Light gradient

**Infrastructure Control Diagram**:
- 📋 Launch Template: Pink gradient
- 📊 ASG: Orange gradient
- 🖥️ EC2: Light gradient
- 🏥 Health Checks: Green gradient
- 📈 CloudWatch: Blue gradient

---

## 📁 Recommended File Names

When saving as images, use these names:

```
traffic-flow-diagram.png
infrastructure-control-diagram.png
```

Or for portfolio:
```
aws-multiaz-traffic-flow.png
aws-multiaz-infrastructure-control.png
```

---

## 🔄 Updating Diagrams

To modify the diagrams:

1. Open the HTML file in a text editor
2. Edit the HTML/CSS as needed
3. Save the file
4. Refresh in browser to see changes
5. Take new screenshot

---

## 📊 Using in Documentation

### In README.md
```markdown
![Traffic Flow](diagrams/traffic-flow-diagram.png)
![Infrastructure Control](diagrams/infrastructure-control-diagram.png)
```

### In Presentations
1. Save diagrams as PNG
2. Insert into PowerPoint/Google Slides
3. Use in portfolio presentations

### In Blog Posts
1. Save diagrams as PNG/JPG
2. Upload to blog platform
3. Reference in articles

---

## 🎯 Best Practices

### For GitHub
- Save as PNG (better quality than JPG)
- Keep file size under 1MB
- Use descriptive filenames
- Add alt text in markdown

### For Portfolio
- Use high resolution (1920x1080 or higher)
- Save as PNG for transparency
- Consider adding your name/branding
- Include in project showcase

### For LinkedIn
- Save as PNG or JPG
- Optimize file size (under 5MB)
- Add descriptive caption
- Tag relevant skills

---

## 🛠️ Tools for Diagram Creation

If you want to create custom diagrams:

### Online Tools
- **draw.io** (https://app.diagrams.net/) - Free, AWS icons
- **Lucidchart** (https://www.lucidchart.com/) - Professional diagrams
- **CloudCraft** (https://www.cloudcraft.co/) - 3D AWS diagrams
- **Diagrams.net** - Open source

### Desktop Tools
- **Microsoft Visio** - Professional diagramming
- **OmniGraffle** (Mac) - Vector graphics
- **Inkscape** - Free vector graphics

### AWS Tools
- **AWS Architecture Icons** - Official icon set
- Download: https://aws.amazon.com/architecture/icons/

---

## 📚 Additional Resources

### AWS Architecture Best Practices
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
- [AWS Reference Architectures](https://aws.amazon.com/architecture/reference-architecture-diagrams/)

### Diagram Examples
- [AWS Architecture Diagrams](https://aws.amazon.com/architecture/reference-architecture-diagrams/)
- [AWS Solutions Library](https://aws.amazon.com/solutions/)

---

## ✅ Checklist

Before using diagrams in portfolio:

- [ ] Open HTML files in browser to verify they display correctly
- [ ] Take high-quality screenshots (PNG format)
- [ ] Save with descriptive filenames
- [ ] Add to GitHub repository
- [ ] Reference in README.md
- [ ] Include in portfolio presentations
- [ ] Add to LinkedIn posts
- [ ] Use in blog articles

---

**Project**: AWS Multi-AZ High Availability POC  
**Diagrams**: Interactive HTML with visual styling  
**Format**: HTML (viewable in any browser)  
**Export**: PNG, JPG, PDF
