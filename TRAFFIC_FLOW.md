# AWS Multi-AZ Traffic Flow Diagram

## 📊 Request/Response Flow

```
                         🌍 USER (Browser)
                                |
                                | HTTP Request
                                ↓
                          ═══ Internet ═══
                                |
                                ↓
                       ┌───────────────────┐
                       │  Internet Gateway │
                       │      (IGW)        │
                       └───────────────────┘
                                |
                                ↓
                    ┌──────────────────────────┐
                    │  Application Load        │
                    │  Balancer (web-alb)      │
                    │  Internet-Facing         │
                    │  Port: 80 (HTTP)         │
                    └──────────────────────────┘
                                |
                                ↓
                    ┌──────────────────────────┐
                    │  Target Group (web-tg)   │
                    │  Health Check: HTTP /    │
                    │  Interval: 30s           │
                    └──────────────────────────┘
                                |
                ┌───────────────┴───────────────┐
                |                               |
                ↓                               ↓
        ┌───────────────┐             ┌───────────────┐
        │ EC2 Instance  │             │ EC2 Instance  │
        │ t2.micro      │             │ t2.micro      │
        │ Apache :80    │             │ Apache :80    │
        │ AZ: eu-west-2a│             │ AZ: eu-west-2b│
        │ 10.0.1.x      │             │ 10.0.2.x      │
        └───────────────┘             └───────────────┘
                |                               |
                └───────────────┬───────────────┘
                                |
                                ↓ HTTP Response
                    ┌──────────────────────────┐
                    │  Application Load        │
                    │  Balancer (web-alb)      │
                    └──────────────────────────┘
                                |
                                ↓
                       ┌───────────────────┐
                       │  Internet Gateway │
                       └───────────────────┘
                                |
                                ↓
                          ═══ Internet ═══
                                |
                                ↓
                         🌍 USER (Browser)
```

---

## 🔄 Detailed Traffic Flow Steps

### Inbound Request (User → Instance)

1. **User Browser**
   - User enters ALB DNS: `http://web-alb-xxxxxxxxx.eu-west-2.elb.amazonaws.com`
   - Browser sends HTTP GET request

2. **Internet**
   - Request travels through public internet
   - DNS resolves ALB DNS to ALB IP addresses

3. **Internet Gateway (IGW)**
   - Entry point to VPC
   - Routes traffic from internet to VPC resources
   - Performs NAT for public IP addresses

4. **Application Load Balancer (ALB)**
   - Receives request on port 80
   - Checks Target Group for healthy instances
   - Selects instance using round-robin algorithm
   - Forwards request to selected instance

5. **Target Group**
   - Maintains list of registered instances
   - Tracks health status of each instance
   - Only routes to "healthy" instances
   - Health check: HTTP GET to `/` every 30 seconds

6. **EC2 Instance (Selected)**
   - Receives HTTP request on port 80
   - Apache web server processes request
   - Generates HTML response with instance metadata
   - Sends response back

### Outbound Response (Instance → User)

7. **EC2 Instance**
   - Apache sends HTTP 200 response
   - Response includes HTML with Instance ID, Hostname, AZ

8. **Application Load Balancer**
   - Receives response from instance
   - Forwards response to original requester
   - Maintains connection state

9. **Internet Gateway**
   - Routes response from VPC to internet
   - Performs NAT translation

10. **Internet**
    - Response travels back through public internet

11. **User Browser**
    - Receives HTML response
    - Renders web page
    - Displays instance information

---

## 🔀 Load Balancing Behavior

### First Request
```
User → ALB → Instance A (eu-west-2a)
Response: Instance ID: i-abc123, AZ: eu-west-2a
```

### Second Request (Refresh)
```
User → ALB → Instance B (eu-west-2b)
Response: Instance ID: i-def456, AZ: eu-west-2b
```

### Third Request (Refresh)
```
User → ALB → Instance A (eu-west-2a)
Response: Instance ID: i-abc123, AZ: eu-west-2a
```

**Pattern**: Round-robin distribution across healthy instances

---

## 🏥 Health Check Flow

```
ALB → Target Group → EC2 Instance
     (Every 30 seconds)
     
Request: HTTP GET http://instance-ip/
Expected: HTTP 200 OK

If 5 consecutive successes → Healthy ✅
If 2 consecutive failures → Unhealthy ❌
```

### Healthy Instance
```
ALB → GET / → Instance → HTTP 200 OK → ALB
Status: Healthy ✅
Action: Continue routing traffic
```

### Unhealthy Instance
```
ALB → GET / → Instance → Timeout/Error → ALB
Status: Unhealthy ❌
Action: Stop routing traffic, ASG replaces instance
```

---

## 🛡️ Security Layer Flow

### Security Group Rules Applied

**Inbound (to EC2 Instances)**:
```
Internet (0.0.0.0/0) → Port 80 (HTTP) → EC2 Instance ✅
Your IP → Port 22 (SSH) → EC2 Instance ✅
All other traffic → BLOCKED ❌
```

**Outbound (from EC2 Instances)**:
```
EC2 Instance → All Ports → All Destinations ✅
(Allows instances to download updates, access AWS services)
```

---

## 🔄 Auto Scaling Flow

### Scale Out (Add Instance)
```
1. CPU > 60% detected
2. CloudWatch triggers alarm
3. ASG launches new instance
4. Instance starts, runs user data
5. Apache installs and starts
6. Instance registers with Target Group
7. Health checks begin
8. After 5 successful checks → Healthy
9. ALB starts routing traffic
```

### Scale In (Remove Instance)
```
1. CPU < 20% detected
2. CloudWatch triggers alarm
3. ASG selects instance to terminate
4. ALB stops routing new requests
5. Existing connections drain (300s)
6. Instance terminates
7. Target Group removes instance
```

---

## 💥 Failure Scenarios

### Scenario 1: Single Instance Failure

```
Before:
User → ALB → [Instance A ✅] [Instance B ✅]

Instance A Fails:
User → ALB → [Instance A ❌] [Instance B ✅]
ALB detects failure, routes all traffic to Instance B

After 2-3 minutes:
User → ALB → [Instance A ❌] [Instance B ✅] [Instance C 🆕]
ASG launches replacement Instance C
```

**Result**: Zero downtime, service continues

### Scenario 2: Availability Zone Failure

```
Before:
User → ALB → [AZ-2a: Instance A ✅] [AZ-2b: Instance B ✅]

AZ-2a Fails:
User → ALB → [AZ-2a: Instance A ❌] [AZ-2b: Instance B ✅]
All traffic routes to AZ-2b

ASG attempts to launch in AZ-2a:
If AZ-2a unavailable, launches in AZ-2b or AZ-2c
```

**Result**: Service continues with reduced capacity

---

## 📊 Traffic Distribution

### Normal Operation (2 Instances)
```
100 Requests:
├─ Instance A (eu-west-2a): ~50 requests (50%)
└─ Instance B (eu-west-2b): ~50 requests (50%)
```

### Scaled Out (4 Instances)
```
100 Requests:
├─ Instance A (eu-west-2a): ~25 requests (25%)
├─ Instance B (eu-west-2b): ~25 requests (25%)
├─ Instance C (eu-west-2a): ~25 requests (25%)
└─ Instance D (eu-west-2b): ~25 requests (25%)
```

### One Instance Unhealthy (3 Healthy)
```
100 Requests:
├─ Instance A (eu-west-2a): ~33 requests (33%)
├─ Instance B (eu-west-2b): ~33 requests (33%)
├─ Instance C (eu-west-2a): ~33 requests (33%)
└─ Instance D (unhealthy): 0 requests (0%)
```

---

## 🌐 Network Path Details

### VPC Network Layout
```
VPC: 10.0.0.0/16
│
├─ Subnet A (eu-west-2a): 10.0.1.0/24
│  └─ Instance A: 10.0.1.x
│
├─ Subnet B (eu-west-2b): 10.0.2.0/24
│  └─ Instance B: 10.0.2.x
│
└─ Subnet C (eu-west-2c): 10.0.3.0/24
   └─ Instance C: 10.0.3.x (if created)
```

### Routing Table
```
Destination         Target              Purpose
10.0.0.0/16        local               VPC internal traffic
0.0.0.0/0          igw-xxxxxxxx        Internet traffic
```

---

## ⏱️ Timing Breakdown

### Typical Request
```
User Request → ALB: ~10-20ms
ALB → Instance: ~1-5ms
Instance Processing: ~5-10ms
Instance → ALB: ~1-5ms
ALB → User: ~10-20ms
───────────────────────────
Total: ~30-60ms
```

### Health Check Cycle
```
Interval: 30 seconds
Timeout: 5 seconds
Healthy threshold: 5 consecutive successes (2.5 minutes)
Unhealthy threshold: 2 consecutive failures (1 minute)
```

### Instance Replacement
```
Detection: 1 minute (2 failed health checks)
Termination: Immediate
Launch new instance: 1-2 minutes
User data execution: 1-2 minutes
Health checks pass: 2.5 minutes
───────────────────────────
Total: ~5-7 minutes
```

---

## 🔍 Monitoring Points

### CloudWatch Metrics Collected

**ALB Metrics**:
- RequestCount
- TargetResponseTime
- HTTPCode_Target_2XX_Count
- HTTPCode_Target_5XX_Count
- HealthyHostCount
- UnHealthyHostCount

**EC2 Metrics**:
- CPUUtilization
- NetworkIn
- NetworkOut
- StatusCheckFailed

**Target Group Metrics**:
- HealthyHostCount
- UnHealthyHostCount
- RequestCountPerTarget

---

## 📝 Traffic Flow Summary

1. ✅ User requests ALB DNS
2. ✅ DNS resolves to ALB IPs
3. ✅ Request enters VPC via IGW
4. ✅ ALB receives request
5. ✅ ALB checks Target Group for healthy instances
6. ✅ ALB selects instance (round-robin)
7. ✅ Request forwarded to instance
8. ✅ Apache processes request
9. ✅ Response sent back through ALB
10. ✅ Response exits VPC via IGW
11. ✅ User receives response

**Key Features**:
- Load balancing across multiple instances
- Health checks ensure only healthy instances receive traffic
- Multi-AZ deployment for high availability
- Auto Scaling for capacity management
- Security Groups for traffic control

---

**Project**: AWS Multi-AZ High Availability POC  
**Region**: EU-West-2 (London)  
**Status**: Deployed and Tested ✅
