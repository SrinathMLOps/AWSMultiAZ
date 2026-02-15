# Building a Highly Available Web Application on AWS: A Multi-AZ Architecture Journey

## Introduction

High availability isn't just a buzzword—it's a critical requirement for modern web applications. In this project, I built a production-ready, highly available web application using AWS services across multiple Availability Zones in the London region. This post walks through the architecture, implementation, and key learnings.

## The Challenge

Design and implement a web application that:
- Remains available even when individual servers fail
- Automatically distributes traffic across multiple servers
- Self-heals by replacing failed instances
- Scales based on demand
- Operates across multiple data centers (Availability Zones)

## The Solution: Multi-AZ Architecture with ALB and ASG

### Architecture Overview

The solution leverages several AWS services working together:

1. **VPC (Virtual Private Cloud)**: Isolated network environment
2. **Multi-AZ Subnets**: Infrastructure spread across two Availability Zones
3. **Application Load Balancer (ALB)**: Distributes incoming traffic
4. **Auto Scaling Group (ASG)**: Maintains desired instance count and handles scaling
5. **EC2 Instances**: Web servers running Apache
6. **CloudWatch**: Monitoring and alerting

### Why This Architecture?

**High Availability**: By deploying across multiple AZs, the application survives data center failures. If eu-west-2a goes down, eu-west-2b continues serving traffic.

**Load Distribution**: The ALB intelligently routes requests to healthy instances, preventing any single server from being overwhelmed.

**Self-Healing**: The ASG continuously monitors instance health. When an instance fails, it automatically launches a replacement.

**Scalability**: Dynamic scaling policies adjust capacity based on CPU utilization, handling traffic spikes gracefully.

## Implementation Deep Dive

### 1. Network Foundation

Started with a custom VPC (10.0.0.0/16) providing complete control over the network environment. Created two public subnets in different AZs:
- `public-a` in eu-west-2a (10.0.1.0/24)
- `public-b` in eu-west-2b (10.0.2.0/24)

The Internet Gateway and route table configuration ensures instances can communicate with the internet while maintaining security through Security Groups.

### 2. Compute Layer

The Launch Template defines the instance configuration, including a user data script that:
- Installs and configures Apache web server
- Retrieves instance metadata (ID, hostname, AZ)
- Generates a custom HTML page displaying this information

This makes it easy to verify load balancing—each refresh potentially shows a different instance.

### 3. Load Balancing and Health Checks

The Application Load Balancer operates at Layer 7 (HTTP/HTTPS), providing:
- Path-based routing capabilities
- SSL/TLS termination
- WebSocket support
- Advanced request routing

The Target Group performs health checks every 30 seconds, marking instances unhealthy after two consecutive failures. This ensures traffic only routes to healthy instances.

### 4. Auto Scaling Configuration

The ASG maintains 2-4 instances with:
- Minimum: 2 (ensures redundancy)
- Desired: 2 (normal operation)
- Maximum: 4 (handles traffic spikes)

Scaling policies trigger based on CPU utilization:
- Scale out when CPU > 60% for 5 minutes
- Scale in when CPU < 20%

### 5. Monitoring and Observability

CloudWatch provides comprehensive monitoring:
- **Alarms**: Alert on unhealthy hosts and 5XX errors
- **Dashboard**: Real-time view of CPU, request count, and response times
- **Logs**: Application and system logs for troubleshooting

## Testing and Validation

### Test 1: Load Balancing Verification
Accessing the ALB DNS and refreshing shows different instance IDs and AZs, confirming traffic distribution.

### Test 2: High Availability
Stopping one EC2 instance while continuously refreshing the page demonstrates zero downtime. The ALB immediately stops routing to the failed instance.

### Test 3: Self-Healing
Within 2-3 minutes of stopping an instance, the ASG detects the failure and launches a replacement. The new instance passes health checks and begins receiving traffic.

### Test 4: Auto Scaling
Generating CPU load triggers the scale-out policy, launching additional instances. When load decreases, the ASG scales back down.

## Key Learnings

### 1. Health Checks Are Critical
Properly configured health checks ensure the ALB only routes to healthy instances. The grace period (300 seconds) prevents premature termination during instance startup.

### 2. Multi-AZ Is Non-Negotiable
Deploying across multiple AZs provides resilience against data center failures. AWS AZs are physically separate, with independent power and networking.

### 3. Security Groups as Firewalls
Security Groups provide stateful firewall rules. The web-sg allows HTTP from anywhere but restricts SSH to specific IPs, following the principle of least privilege.

### 4. User Data for Bootstrap
User data scripts automate instance configuration, ensuring consistency and reducing manual setup. This is crucial for auto-scaling scenarios.

### 5. Monitoring Drives Operations
Without CloudWatch alarms and dashboards, you're flying blind. Proactive monitoring enables quick response to issues.

## Production Considerations

While this POC demonstrates core concepts, production deployments should include:

### Security Enhancements
- **HTTPS**: Use ACM certificates with ALB listeners
- **WAF**: AWS Web Application Firewall for protection against common exploits
- **Private Subnets**: Move application servers to private subnets, use NAT Gateway
- **Secrets Management**: AWS Secrets Manager for sensitive data
- **IAM Roles**: Least privilege access for instances

### Reliability Improvements
- **Multi-Region**: Deploy across multiple AWS regions for disaster recovery
- **Database Layer**: RDS with Multi-AZ for data persistence
- **Caching**: ElastiCache or CloudFront for performance
- **Backup Strategy**: Automated snapshots and cross-region replication

### Operational Excellence
- **Infrastructure as Code**: Terraform or CloudFormation for reproducible deployments
- **CI/CD Pipeline**: Automated testing and deployment
- **Logging**: Centralized logging with CloudWatch Logs or ELK stack
- **Cost Optimization**: Right-sizing instances, Reserved Instances, Savings Plans

## Cost Analysis

**Monthly estimate for this architecture (London region):**
- Application Load Balancer: ~$20
- EC2 t2.micro instances (2): ~$16
- Data transfer: ~$5-10
- CloudWatch: ~$3
- **Total**: ~$45-50/month

**Cost optimization strategies:**
- Use t3.micro for better price/performance
- Implement auto-scaling to reduce idle capacity
- Use Spot Instances for non-critical workloads
- Set up billing alerts

## Conclusion

This project demonstrates fundamental AWS high availability patterns that apply to real-world applications. The combination of Multi-AZ deployment, load balancing, auto-scaling, and monitoring creates a resilient architecture that handles failures gracefully.

The skills developed here—VPC design, load balancer configuration, auto-scaling setup, and CloudWatch monitoring—are directly applicable to production environments.

## What's Next?

Potential enhancements:
1. Add HTTPS with ACM certificates
2. Implement blue/green deployments
3. Add RDS database with read replicas
4. Set up CloudFront CDN
5. Implement container-based deployment with ECS/EKS
6. Add CI/CD pipeline with CodePipeline

## Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Elastic Load Balancing Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)
- [Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-best-practices.html)
- [VPC Design Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-design-best-practices.html)

---

**Tags**: AWS, High Availability, Load Balancing, Auto Scaling, DevOps, Cloud Architecture

**GitHub Repository**: [Link to your repo]

**Live Demo**: [If applicable]

---

*This project was built as part of my cloud engineering portfolio. Feel free to reach out with questions or suggestions!*
