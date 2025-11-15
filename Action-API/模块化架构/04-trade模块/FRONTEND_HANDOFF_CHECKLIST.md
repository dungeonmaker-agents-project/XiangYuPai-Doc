# Trade Module - Frontend Handoff Checklist

**Date:** 2025-11-14
**Status:** ✅ **READY FOR HANDOFF**
**Handoff Package Version:** 1.0

---

## ✅ Pre-Handoff Verification Complete

### Documentation Status

| Document | Status | Notes |
|----------|--------|-------|
| 13-确认订单页面.md | ✅ Verified | Ready as-is |
| 14-支付页面.md | ✅ **FIXED** | API paths corrected (3 locations) |
| 15-支付成功页面.md | ✅ Verified | Ready as-is |
| 16-订单详情页面.md | ✅ Verified | Ready as-is |
| FRONTEND_INTERFACE_VERIFICATION.md | ✅ Created | Complete verification report |

### Critical Fixes Applied

✅ **Fixed 14-支付页面.md:**
- Line 82: `/api/order/pay` → `/api/payment/pay`
- Line 117: `/api/order/pay/verify` → `/api/payment/verify`
- Lines 161, 179: Updated data flow diagrams
- Lines 234-236: OrderService → PaymentService

**All frontend documentation is now 100% accurate!** 🎉

---

## 📦 Handoff Package Contents

### 1. Frontend Page Documentation (4 Files)

**Location:** `XiangYuPai-Doc/Action-API/模块化架构/04-trade模块/Frontend/`

```
Frontend/
├── 13-确认订单页面.md          ✅ Ready
├── 14-支付页面.md              ✅ Ready (Fixed)
├── 15-支付成功页面.md          ✅ Ready
├── 16-订单详情页面.md          ✅ Ready
└── FRONTEND_INTERFACE_VERIFICATION.md  ✅ New (Integration guide)
```

### 2. Backend API Documentation (2 Files)

**Location:** `XiangYuPai-Doc/Action-API/模块化架构/04-trade模块/Backend/`

```
Backend/
├── 订单服务接口文档.md         ✅ Complete API reference
└── 支付服务接口文档.md         ✅ Complete API reference
```

### 3. Test & Integration Guides (2 Files)

**Location:** `RuoYi-Cloud-Plus/`

```
├── TRADE_MODULE_API_TESTING_GUIDE.md     ✅ cURL examples for all APIs
└── TRADE_MODULE_TEST_DOCUMENTATION.md    ✅ 37 test scenarios
```

### 4. Module Overview

**Location:** `XiangYuPai-Doc/Action-API/模块化架构/04-trade模块/`

```
04-trade模块/
└── README.md                   ✅ Module overview
```

**Total Files for Frontend Team:** 9 documents

---

## 🔌 API Integration Summary

### OrderService APIs (6 APIs)

| Page | API | Method | Path | Ready |
|------|-----|--------|------|-------|
| 13-确认订单 | Order Preview | GET | `/api/order/preview` | ✅ |
| 13-确认订单 | Update Preview | POST | `/api/order/preview/update` | ✅ |
| 13-确认订单 | Create Order | POST | `/api/order/create` | ✅ |
| 15-支付成功 | Get Order Detail | GET | `/api/order/detail` | ✅ |
| 16-订单详情 | Get Order Status | GET | `/api/order/status` | ✅ |
| 16-订单详情 | Cancel Order | POST | `/api/order/cancel` | ✅ |

### PaymentService APIs (2 APIs Used)

| Page | API | Method | Path | Ready |
|------|-----|--------|------|-------|
| 14-支付页面 | Execute Payment | POST | `/api/payment/pay` | ✅ |
| 14-支付页面 | Verify Password | POST | `/api/payment/verify` | ✅ |

**Total APIs Ready:** 8 APIs ✅

---

## 🌐 Test Environment

### Backend Services (All Running)

```yaml
Gateway URL: http://localhost:8080

# Via Gateway (Frontend should use these)
Order APIs:   http://localhost:8080/order/api/order/*
Payment APIs: http://localhost:8080/payment/api/payment/*

# Direct Access (For debugging only)
OrderService:   http://localhost:9410
PaymentService: http://localhost:9411
```

### Health Checks

```bash
# Gateway
curl http://localhost:8080/actuator/health

# OrderService
curl http://localhost:9410/actuator/health

# PaymentService
curl http://localhost:9411/actuator/health
```

**Expected Response:** `{"status":"UP"}`

### Test Data Available

```javascript
// Test User Account
{
  userId: 1,
  nickname: "测试用户",
  balance: 100.00,        // 100 coins
  paymentPassword: "123456"  // For testing payment
}

// Test Service
{
  serviceId: 101,
  name: "王者荣耀陪玩",
  providerId: 2,
  unitPrice: 10.00,
  unit: "局"
}

// Expected Order Calculation
{
  quantity: 1,
  subtotal: 10.00,       // 10 coins × 1
  serviceFee: 0.50,      // 5% service fee
  total: 10.50           // Total to pay
}
```

---

## 🎯 Frontend Development Guide

### Step 1: Review Documentation

**Priority Order:**
1. Read `FRONTEND_INTERFACE_VERIFICATION.md` - Overview and integration guide
2. Read each page documentation (13, 14, 15, 16)
3. Reference backend API docs when needed
4. Use API testing guide for quick tests

### Step 2: Environment Setup

```bash
# Set up API base URL
const GATEWAY_URL = 'http://localhost:8080'

# Configure API paths
const ORDER_API_BASE = '/order/api/order'
const PAYMENT_API_BASE = '/payment/api/payment'
```

### Step 3: Implement Pages

**Recommended Order:**
1. ✅ 13-确认订单页面 (Start here - simplest flow)
2. ✅ 14-支付页面 (Payment modal components)
3. ✅ 15-支付成功页面 (Success page)
4. ✅ 16-订单详情页面 (Status tracking with polling)

### Step 4: Test Integration

**Use the API Testing Guide:**
- Copy cURL commands for quick API testing
- Verify request/response formats
- Test error scenarios
- Check database state after operations

---

## 🔑 Critical Integration Points

### 1. Authentication

**All APIs require authentication:**
```typescript
// Add Authorization header to all requests
headers: {
  'Authorization': `Bearer ${accessToken}`,
  'Content-Type': 'application/json'
}
```

**On 401 Unauthorized:**
```typescript
if (response.status === 401) {
  // Redirect to login page
  router.push('/login')
}
```

### 2. API Gateway Routing

**✅ Correct - Use Gateway:**
```typescript
// OrderService APIs
POST http://localhost:8080/order/api/order/create

// PaymentService APIs
POST http://localhost:8080/payment/api/payment/pay
```

**❌ Wrong - Don't call services directly:**
```typescript
// Don't do this
POST http://localhost:9410/api/order/create
POST http://localhost:9411/api/payment/pay
```

### 3. Payment Flow

**Critical: Two-step payment process**

```typescript
// Step 1: Execute payment (may require password)
const response = await axios.post('/payment/api/payment/pay', {
  orderId,
  orderNo,
  paymentMethod: 'balance',
  amount,
  paymentPassword: undefined  // Don't send yet
})

// Step 2a: If requirePassword = true
if (response.data.data.paymentStatus === 'require_password') {
  showPasswordInput()
}

// Step 2b: User inputs password, verify
const verifyResponse = await axios.post('/payment/api/payment/verify', {
  orderId,
  orderNo,
  paymentPassword: '123456'  // 6-digit password
})

// Step 3: Check final status
if (verifyResponse.data.data.paymentStatus === 'success') {
  router.push({
    path: '/payment/success',
    query: { orderId, orderNo, amount }
  })
}
```

### 4. Order Status Polling

**For order detail page:**
```typescript
// Start polling when status is 'pending'
useEffect(() => {
  if (orderStatus === 'pending') {
    const timer = setInterval(async () => {
      const status = await fetchOrderStatus(orderId)

      // Stop polling if status changed
      if (status !== 'pending') {
        clearInterval(timer)
      }
    }, 5000)  // Poll every 5 seconds

    return () => clearInterval(timer)
  }
}, [orderStatus, orderId])
```

### 5. Error Handling

**Standardized error responses:**
```typescript
try {
  const response = await api.post('/order/create', data)

  // Success
  if (response.data.code === 200) {
    handleSuccess(response.data.data)
  }
  // Business error
  else {
    showError(response.data.message)
  }
} catch (error) {
  // Network error or HTTP error
  if (error.response?.status === 401) {
    redirectToLogin()
  } else if (error.response?.status === 400) {
    showError(error.response.data.message)
  } else {
    showError('网络错误,请重试')
  }
}
```

---

## 📋 Page-by-Page Implementation Checklist

### Page 1: 13-确认订单页面

**Route:** `/order/confirm`

- [ ] Route parameter: `serviceId`
- [ ] On mount: Call `GET /api/order/preview`
- [ ] Display provider info, service info, price
- [ ] Quantity selector (+/- buttons)
- [ ] On quantity change: Call `POST /api/order/preview/update` (optional)
- [ ] Real-time total calculation
- [ ] On submit: Call `POST /api/order/create`
- [ ] On success: Show payment modal
- [ ] Error handling: Service unavailable, amount mismatch

**Test:**
```bash
curl -X GET "http://localhost:8080/order/api/order/preview?serviceId=101&quantity=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Page 2: 14-支付页面

**Type:** Modal/Popup

- [ ] Receive props: `orderId`, `orderNo`, `amount`, `userBalance`
- [ ] Display payment amount prominently
- [ ] Display user balance
- [ ] Check if balance sufficient
- [ ] On "立即支付" click: Call `POST /api/payment/pay`
- [ ] If `requirePassword=true`: Show password input modal
- [ ] Password input: 6-digit numeric keypad
- [ ] Auto-submit when 6 digits entered
- [ ] On password complete: Call `POST /api/payment/verify`
- [ ] On success: Close modal, navigate to success page
- [ ] Error handling: Wrong password (show remaining attempts), account locked

**Test:**
```bash
# Step 1: Try payment without password
curl -X POST "http://localhost:8080/payment/api/payment/pay" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"orderId":"123","orderNo":"20251114001","paymentMethod":"balance","amount":10.50}'

# Step 2: Verify with password
curl -X POST "http://localhost:8080/payment/api/payment/verify" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"orderId":"123","orderNo":"20251114001","paymentPassword":"123456"}'
```

---

### Page 3: 15-支付成功页面

**Route:** `/payment/success`

- [ ] Route params: `orderId`, `orderNo`, `amount`
- [ ] Display success icon (green checkmark)
- [ ] Display payment amount
- [ ] Display order number and timestamp
- [ ] Optional: Call `GET /api/order/detail` for more info
- [ ] Show 10-minute auto-cancel notice
- [ ] "完成" button navigates to order detail
- [ ] Optional: Auto-jump after 3-5 seconds

**Test:**
```bash
curl -X GET "http://localhost:8080/order/api/order/detail?orderId=123" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Page 4: 16-订单详情页面

**Route:** `/order/detail`

- [ ] Route param: `orderId`
- [ ] On mount: Call `GET /api/order/status`
- [ ] Display order status with label
- [ ] Display provider info (avatar, nickname, online status)
- [ ] Display service info (name, quantity, price)
- [ ] Display order info (order number, timestamps)
- [ ] **If status='pending'**: Start polling (every 3-5 seconds)
- [ ] **If status='pending'**: Show auto-cancel countdown
- [ ] **If status='pending'**: Show "取消订单" button
- [ ] On "取消订单" click: Confirm dialog → Call `POST /api/order/cancel`
- [ ] Display dynamic actions based on `actions` array
- [ ] Stop polling when status changes from 'pending'

**Test:**
```bash
# Get order status
curl -X GET "http://localhost:8080/order/api/order/status?orderId=123" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Cancel order
curl -X POST "http://localhost:8080/order/api/order/cancel" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"orderId":"123","reason":"Changed my mind"}'
```

---

## 🧪 Testing Checklist

### Happy Path Testing

- [ ] Complete order flow: Preview → Create → Pay → Success → Detail
- [ ] Payment with balance (sufficient funds)
- [ ] Order status updates correctly
- [ ] Auto-cancel countdown works
- [ ] Cancel order and verify refund

### Error Scenario Testing

- [ ] Insufficient balance
- [ ] Wrong payment password (3 times)
- [ ] Account lockout after 5 failed attempts
- [ ] Order already accepted (cannot cancel)
- [ ] Service not available
- [ ] Amount tampering detection
- [ ] Network error handling
- [ ] 401 Unauthorized (redirect to login)

### Edge Case Testing

- [ ] Concurrent payment prevention
- [ ] Auto-cancel after 10 minutes
- [ ] Status polling stops after status change
- [ ] Password input: backspace, clear
- [ ] Very large amounts (>10000 coins)
- [ ] Zero balance payment attempt

---

## 🐛 Known Issues & Limitations

### None - All Issues Resolved ✅

The previous API path issue in 14-支付页面.md has been fixed.

### Future Enhancements (Not Required Now)

- Order list page (17-订单列表页面)
- Wallet page (18-钱包页面)
- Recharge/Withdraw page (19-充值提现页面)
- Additional payment methods (Alipay, WeChat Pay)

---

## 📞 Support & Communication

### During Integration

**Backend Team Availability:**
- Available for API questions
- Can provide additional test data if needed
- Can help debug integration issues

**Communication Channels:**
- Questions about API behavior → Reference backend API docs
- Questions about frontend requirements → Reference page docs
- Integration issues → Contact backend team

### Quick References

| Need | Document |
|------|----------|
| "What should this page look like?" | Frontend/XX-页面.md |
| "What's the API request format?" | Frontend/XX-页面.md (Section 三) |
| "What's the API response format?" | Frontend/XX-页面.md (Section 三) |
| "What errors can occur?" | Frontend/XX-页面.md (Section 七) |
| "How do I test this API?" | TRADE_MODULE_API_TESTING_GUIDE.md |
| "What's the complete API spec?" | Backend/XX服务接口文档.md |

---

## ✅ Final Handoff Approval

### Backend Team Sign-off

- [x] All 8 APIs implemented and tested
- [x] All 4 frontend pages documented
- [x] Test environment running and accessible
- [x] Sample data loaded
- [x] API testing guide provided
- [x] Frontend documentation verified 100% accurate
- [x] Critical fixes applied (14-支付页面.md)

### Ready for Frontend Development

**Status:** ✅ **APPROVED - READY FOR HANDOFF**

**Next Steps:**
1. Frontend team reviews all documentation
2. Frontend team sets up development environment
3. Frontend team begins implementation
4. Integration testing with backend

---

## 📅 Timeline Expectations

### Phase 1: Review & Setup (1-2 days)
- Frontend team reviews documentation
- Set up development environment
- Test backend API connectivity

### Phase 2: Implementation (5-7 days)
- Implement 4 pages
- Integration with backend APIs
- Unit testing of components

### Phase 3: Integration Testing (2-3 days)
- End-to-end testing
- Bug fixes and refinements
- Performance testing

### Phase 4: Pre-Production (1-2 days)
- Final review
- Production deployment preparation
- Monitoring setup

**Estimated Total:** 2-3 weeks

---

## 🎉 Handoff Complete

All frontend documentation is verified, corrected, and ready for handoff.

**Package Status:** ✅ **COMPLETE**
**Documentation Accuracy:** ✅ **100%**
**Backend APIs:** ✅ **100% Ready**
**Test Environment:** ✅ **Running**

**The trade module frontend integration can now begin!** 🚀

---

**Document Version:** 1.0
**Last Updated:** 2025-11-14
**Prepared By:** Backend Team
**Approved For:** Frontend Team Handoff

**Status:** ✅ **READY FOR PRODUCTION FRONTEND DEVELOPMENT**
