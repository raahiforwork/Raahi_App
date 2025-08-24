# Raahi - University Carpooling App
## Product Requirements Document (PRD)

---

## 1. Executive Summary

**Product Name:** Raahi  
**Target Audience:** University Students  
**Platform:** Mobile (Flutter - iOS & Android)  
**Core Value Proposition:** Safe, verified university student carpooling with location-based matching and reward system

---

## 2. Technical Architecture & Tech Stack

### 2.1 Frontend (Mobile App)
- **Framework:** Flutter 3.x
- **State Management:** Riverpod / BLoC
- **Navigation:** GoRouter
- **UI Components:** Custom Design System + Material 3
- **Maps Integration:** Google Maps SDK
- **Real-time Communication:** Socket.IO Client
- **Local Storage:** Hive / SharedPreferences
- **Image Handling:** cached_network_image, image_picker

### 2.2 Backend Infrastructure
- **Primary Backend:** Node.js with Express.js / Nest.js
- **Alternative:** Firebase (for rapid deployment)
- **Database:** 
  - Primary: PostgreSQL (user data, transactions)
  - Cache: Redis (real-time locations, sessions)
  - Document Store: MongoDB (chat messages, logs)
- **Real-time Engine:** Socket.IO
- **File Storage:** AWS S3 / Google Cloud Storage
- **CDN:** CloudFlare

### 2.3 Authentication & Security
- **Authentication:** Firebase Auth + Custom JWT
- **University Verification:** Email domain verification + Student ID verification
- **Biometric:** Local biometric authentication
- **Security Features:**
  - Rate limiting
  - API encryption (AES-256)
  - Input validation & sanitization
  - SQL injection prevention

### 2.4 Location & Mapping Services
- **Maps:** Google Maps API
- **Geolocation:** HTML5 Geolocation + GPS
- **Geocoding:** Google Geocoding API
- **Route Optimization:** Google Directions API
- **Geofencing:** Custom implementation with PostGIS

### 2.5 Payment & Rewards
- **Payment Gateway:** Razorpay / Stripe
- **Wallet System:** Custom implementation
- **Blockchain (Optional):** For Raahi coins (Polygon/BSC)

### 2.6 Infrastructure & DevOps
- **Cloud Provider:** AWS / Google Cloud Platform
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Monitoring:** Sentry, New Relic
- **Analytics:** Firebase Analytics + Custom dashboard

---

## 3. Core Features Implementation

### 3.1 University Student Verification System

```
Verification Flow:
1. Email Domain Check (.edu, university-specific domains)
2. Student ID Upload & Verification
3. Manual Admin Review (for edge cases)
4. Document Verification API integration
```

**Implementation:**
- Create verification service in backend
- Integrate with university databases (where possible)
- Manual verification dashboard for admins
- Multi-step verification process

### 3.2 Location-Based Ride Matching

```
Algorithm Flow:
1. Driver posts ride with route
2. System creates geofenced zones along route
3. Passengers search within proximity zones
4. AI-powered matching based on:
   - Route similarity
   - Time compatibility
   - User ratings
   - University affiliation
```

**Technical Implementation:**
- **Geospatial Database:** PostGIS for location queries
- **Real-time Updates:** WebSocket connections
- **Matching Algorithm:** Custom scoring system
- **Radius Search:** Haversine formula for distance calculation

### 3.3 Raahi Coins Reward System

```
Coin Earning Events:
- Complete ride as passenger: 10 coins
- Complete ride as driver: 15 coins
- Refer new user: 50 coins
- Monthly active user bonus: 25 coins
- Rating above 4.5: 5 bonus coins
```

**Technical Implementation:**
- Blockchain-based token system (optional)
- Traditional database approach with audit trails
- Integration with university merchant APIs
- QR code generation for coupon redemption

### 3.4 University Merchant Integration

```
Partnership Models:
1. Revenue Sharing: 5-10% commission on coin redemptions
2. Fixed Monthly Fee: For participating outlets
3. Promotional Partnerships: Cross-marketing opportunities
```

**Implementation Steps:**
1. Create merchant dashboard
2. API endpoints for coupon validation
3. QR code system for redemptions
4. Analytics for merchants

---

## 4. Enhanced Security Features

### 4.1 Multi-Layer Security Model

```
Security Layers:
1. Device Level: Biometric authentication
2. Network Level: SSL/TLS encryption
3. Application Level: JWT tokens, API security
4. Data Level: Database encryption at rest
5. User Level: Verification & rating system
```

### 4.2 Safety Features

```
Safety Mechanisms:
1. Real-time Trip Tracking
2. Emergency SOS Button
3. Ride Sharing with Trusted Contacts
4. Driver Background Checks
5. In-app Panic Button
6. Live Location Sharing
7. Auto Check-in Reminders
```

**Implementation:**
- Emergency contact integration
- SMS/Email alerts to emergency contacts
- Integration with local emergency services
- Real-time location tracking
- Geofencing for safety zones

### 4.3 Trust & Safety System

```
Trust Mechanisms:
1. Mutual Rating System
2. University Email Verification
3. Student ID Verification
4. Social Media Verification (Optional)
5. Phone Number Verification
6. Ride History & Behavior Analysis
```

---

## 5. Database Schema Design

### 5.1 Core Entities

```sql
-- Users Table
users (
  id, email, phone, university_id, student_id_verified,
  profile_image, full_name, year_of_study, department,
  emergency_contacts, rating, total_rides, created_at
)

-- Rides Table
rides (
  id, driver_id, origin, destination, departure_time,
  available_seats, price_per_seat, status, route_polyline,
  created_at, updated_at
)

-- Bookings Table
bookings (
  id, ride_id, passenger_id, pickup_location,
  booking_status, coins_earned, payment_status
)

-- Raahi Coins Table
raahi_transactions (
  id, user_id, transaction_type, amount, description,
  related_booking_id, created_at
)
```

### 5.2 Location Tracking Schema

```sql
-- Live Locations
live_locations (
  id, user_id, latitude, longitude, accuracy,
  timestamp, ride_id, is_active
)

-- Geofences
geofences (
  id, name, center_lat, center_lng, radius,
  university_id, type, is_active
)
```

---

## 6. API Architecture

### 6.1 REST API Endpoints

```
Authentication:
POST /auth/register
POST /auth/login
POST /auth/verify-student
GET  /auth/profile

Rides:
GET  /rides/search
POST /rides/create
PUT  /rides/{id}
GET  /rides/nearby

Bookings:
POST /bookings/create
PUT  /bookings/{id}/confirm
GET  /bookings/history

Location:
POST /location/update
GET  /location/nearby-users
POST /location/track-ride

Coins:
GET  /coins/balance
GET  /coins/history
POST /coins/redeem
```

### 6.2 WebSocket Events

```
Real-time Events:
- location_update
- ride_request
- booking_confirmed
- driver_arrived
- ride_started
- ride_completed
- emergency_alert
```

---

## 7. University Merchant Integration Strategy

### 7.1 Partnership Approach

```
Target Merchants:
1. Campus Cafeterias
2. Bookstores
3. Campus Convenience Stores
4. Local Restaurants near Campus
5. Study Material Vendors
6. Campus Gyms
7. Printing Services
```

### 7.2 Technical Integration

```
Merchant Dashboard Features:
- Coupon Management
- Redemption Analytics
- Revenue Tracking
- Student Demographics
- Marketing Campaign Tools

API for Merchants:
- Coupon validation endpoint
- Real-time redemption notifications
- Analytics data export
- QR code generation
```

---

## 8. Implementation Roadmap

### Phase 1: Core MVP (8-10 weeks)
1. **Week 1-2:** Backend architecture setup
2. **Week 3-4:** User authentication & verification
3. **Week 5-6:** Basic ride posting & searching
4. **Week 7-8:** Location services integration
5. **Week 9-10:** Testing & bug fixes

### Phase 2: Enhanced Features (6-8 weeks)
1. **Week 1-2:** Real-time tracking & matching
2. **Week 3-4:** Raahi coins system
3. **Week 5-6:** Safety features implementation
4. **Week 7-8:** Payment integration

### Phase 3: Merchant Integration (4-6 weeks)
1. **Week 1-2:** Merchant dashboard
2. **Week 3-4:** Coupon redemption system
3. **Week 5-6:** Analytics & reporting

### Phase 4: Production & Scaling (4-6 weeks)
1. **Week 1-2:** Performance optimization
2. **Week 3-4:** Security audits
3. **Week 5-6:** App store deployment

---

## 9. Nearby Location Detection Implementation

### 9.1 Technical Approach

```javascript
// Geospatial Query Example (PostGIS)
SELECT u.id, u.name, 
       ST_Distance(u.location, ST_Point($lng, $lat)) as distance
FROM users u 
WHERE u.is_active = true
AND ST_DWithin(u.location, ST_Point($lng, $lat), 5000) -- 5km radius
ORDER BY distance;
```

### 9.2 Real-time Implementation

```
Architecture:
1. WebSocket connections for real-time updates
2. Redis for caching active user locations
3. Background job for periodic location cleanup
4. Push notifications for nearby ride alerts
```

---

## 10. Deployment & DevOps

### 10.1 Infrastructure Requirements

```
Production Environment:
- Load Balancer: AWS ALB / Nginx
- App Servers: 2-3 EC2 instances (auto-scaling)
- Database: RDS PostgreSQL with read replicas
- Cache: Redis Cluster
- File Storage: S3
- CDN: CloudFront
- Monitoring: CloudWatch + Sentry
```

### 10.2 CI/CD Pipeline

```yaml
# GitHub Actions Workflow
- Code Push → Automated Tests
- Tests Pass → Build Docker Images
- Deploy to Staging → Integration Tests
- Manual Approval → Deploy to Production
- Post-deployment → Health Checks
```

---

## 11. Security Recommendations

### 11.1 Data Protection
- End-to-end encryption for sensitive data
- GDPR compliance for user data
- Regular security audits
- Penetration testing
- OWASP security guidelines

### 11.2 API Security
- Rate limiting per user/IP
- API key authentication for merchants
- Request signing for critical operations
- Input validation and sanitization
- SQL injection prevention

---

## 12. Analytics & KPIs

### 12.1 Key Metrics
- Daily/Monthly Active Users
- Ride Completion Rate
- User Acquisition Cost
- Revenue per User
- Safety Incident Rate
- Merchant Engagement Rate

### 12.2 Analytics Tools
- Firebase Analytics
- Custom dashboard with Grafana
- User behavior tracking
- A/B testing framework

---

## 13. Legal & Compliance

### 13.1 Required Documentation
- Privacy Policy
- Terms of Service
- Safety Guidelines
- Merchant Agreement Templates
- Data Processing Agreements

### 13.2 Compliance Requirements
- GDPR (if targeting EU students)
- Local transportation regulations
- University partnership agreements
- Insurance requirements

---

## 14. Budget Estimation

### 14.1 Development Costs (Approximate)
- Backend Development: $15,000 - $25,000
- Mobile App Development: $10,000 - $20,000
- UI/UX Design: $5,000 - $10,000
- Testing & QA: $3,000 - $7,000
- **Total Development: $33,000 - $62,000**

### 14.2 Operational Costs (Monthly)
- AWS Infrastructure: $200 - $500
- Third-party APIs: $100 - $300
- Monitoring Tools: $50 - $150
- **Total Monthly: $350 - $950**

---

## 15. Risk Mitigation

### 15.1 Technical Risks
- **Scalability Issues:** Implement auto-scaling from day one
- **Data Breaches:** Multi-layer security implementation
- **API Downtime:** Implement fallback mechanisms

### 15.2 Business Risks
- **Low Adoption:** Aggressive marketing at partner universities
- **Safety Concerns:** Comprehensive safety features
- **Merchant Partnerships:** Start with campus outlets

---

This PRD provides a comprehensive roadmap for building Raahi as a production-ready carpooling platform. Focus on implementing the MVP first, then gradually add advanced features based on user feedback and adoption metrics.