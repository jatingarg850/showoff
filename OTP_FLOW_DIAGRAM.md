# OTP System Flow Diagrams

## Complete OTP Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User Application                            │
│                      (Flutter App)                                  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ POST /api/auth/send-otp
                             │ { phone, email, countryCode }
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      ShowOff.life Server                            │
│                   (Node.js + Express)                               │
│                                                                     │
│  authController.sendOTP()                                          │
│  ├─ Check if email or phone                                        │
│  ├─ Validate user doesn't exist                                    │
│  └─ Route to appropriate service                                   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │  Phone Request   │      │  Email Request   │
        └────────┬─────────┘      └────────┬─────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │  AuthKey.io SMS  │      │  Resend Email    │
        │  Service         │      │  Service         │
        └────────┬─────────┘      └────────┬─────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │ Generate OTP     │      │ Generate OTP     │
        │ (6 digits)       │      │ (6 digits)       │
        └────────┬─────────┘      └────────┬─────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │ Send SMS via     │      │ Send Email via   │
        │ api.authkey.io   │      │ api.resend.com   │
        │ (Template 29663) │      │ (HTML Template)  │
        └────────┬─────────┘      └────────┬─────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │ SMS Sent         │      │ Email Sent       │
        │ LogID: xxxxx     │      │ MessageID: xxxxx │
        └────────┬─────────┘      └────────┬─────────┘
                 │                         │
                 └────────────┬────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │ Store OTP in Memory  │
                    │ - OTP: 123456        │
                    │ - Expiry: 10 min     │
                    │ - Attempts: 0/3      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Return to App        │
                    │ - identifier         │
                    │ - expiresIn: 600s    │
                    │ - logId/messageId    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ User Receives OTP    │
                    │ - SMS or Email       │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ User Enters OTP      │
                    │ in App               │
                    └──────────┬───────────┘
                               │
                               │ POST /api/auth/verify-otp
                               │ { phone/email, otp }
                               ▼
                    ┌──────────────────────┐
                    │ Verify OTP           │
                    │ - Check expiry       │
                    │ - Check attempts     │
                    │ - Compare with stored│
                    └──────────┬───────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
                    ▼                     ▼
            ┌──────────────┐      ┌──────────────┐
            │ Valid OTP    │      │ Invalid OTP  │
            │ ✅ Success   │      │ ❌ Error     │
            └──────────────┘      └──────────────┘
                    │                     │
                    ▼                     ▼
            ┌──────────────┐      ┌──────────────┐
            │ Proceed with │      │ Return Error │
            │ Registration │      │ Retry or     │
            │ or Login     │      │ Resend OTP   │
            └──────────────┘      └──────────────┘
```

## Phone OTP Sequence

```
User                App              Server           AuthKey.io
 │                  │                  │                  │
 │ Request OTP      │                  │                  │
 ├─────────────────>│                  │                  │
 │                  │ POST /send-otp   │                  │
 │                  ├─────────────────>│                  │
 │                  │                  │ Generate OTP     │
 │                  │                  │ (123456)         │
 │                  │                  │                  │
 │                  │                  │ Send SMS         │
 │                  │                  ├─────────────────>│
 │                  │                  │                  │
 │                  │                  │ SMS Sent         │
 │                  │                  │ LogID: xxxxx     │
 │                  │                  │<─────────────────┤
 │                  │                  │                  │
 │                  │ Store OTP        │                  │
 │                  │ in Memory        │                  │
 │                  │                  │                  │
 │                  │ Response OK      │                  │
 │                  │<─────────────────┤                  │
 │ SMS Received     │                  │                  │
 │<─────────────────┤                  │                  │
 │                  │                  │                  │
 │ Enter OTP        │                  │                  │
 ├─────────────────>│                  │                  │
 │                  │ POST /verify-otp │                  │
 │                  ├─────────────────>│                  │
 │                  │                  │ Verify OTP       │
 │                  │                  │ (123456 == 123456)
 │                  │                  │ ✅ Match         │
 │                  │ Verified ✅      │                  │
 │                  │<─────────────────┤                  │
 │ Success          │                  │                  │
 │<─────────────────┤                  │                  │
```

## Email OTP Sequence

```
User                App              Server           Resend
 │                  │                  │                │
 │ Request OTP      │                  │                │
 ├─────────────────>│                  │                │
 │                  │ POST /send-otp   │                │
 │                  ├─────────────────>│                │
 │                  │                  │ Generate OTP   │
 │                  │                  │ (654321)       │
 │                  │                  │                │
 │                  │                  │ Send Email     │
 │                  │                  ├───────────────>│
 │                  │                  │                │
 │                  │                  │ Email Sent     │
 │                  │                  │ MessageID: xxx │
 │                  │                  │<───────────────┤
 │                  │                  │                │
 │                  │ Store OTP        │                │
 │                  │ in Memory        │                │
 │                  │                  │                │
 │                  │ Response OK      │                │
 │                  │<─────────────────┤                │
 │ Email Received   │                  │                │
 │<─────────────────┤                  │                │
 │                  │                  │                │
 │ Enter OTP        │                  │                │
 ├─────────────────>│                  │                │
 │                  │ POST /verify-otp │                │
 │                  ├─────────────────>│                │
 │                  │                  │ Verify OTP     │
 │                  │                  │ (654321 == 654321)
 │                  │                  │ ✅ Match       │
 │                  │ Verified ✅      │                │
 │                  │<─────────────────┤                │
 │ Success          │                  │                │
 │<─────────────────┤                  │                │
```

## OTP Storage & Verification

```
┌─────────────────────────────────────────────────────────────┐
│                    OTP Store (In-Memory)                    │
│                                                             │
│  Map {                                                      │
│    "919811226924": {                                        │
│      otp: "123456",                                         │
│      logId: "05f9038825fd406fbdc6f862bc617ad6",            │
│      expiresAt: 1702641000000,  // 10 min from now        │
│      attempts: 0,                                           │
│      createdAt: 1702640400000                              │
│    },                                                       │
│    "user@example.com": {                                    │
│      otp: "654321",                                         │
│      logId: "message_id_here",                              │
│      expiresAt: 1702641000000,  // 10 min from now        │
│      attempts: 0,                                           │
│      createdAt: 1702640400000                              │
│    }                                                        │
│  }                                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │  Verification Process               │
        │                                     │
        │  1. Get identifier (phone/email)    │
        │  2. Look up in OTP Store            │
        │  3. Check if exists                 │
        │  4. Check if expired                │
        │  5. Check attempt count             │
        │  6. Compare OTP values              │
        │  7. Return result                   │
        │                                     │
        └─────────────────────────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
                ▼                   ▼
        ┌──────────────┐    ┌──────────────┐
        │ Valid OTP    │    │ Invalid OTP  │
        │ ✅ Success   │    │ ❌ Error     │
        │              │    │              │
        │ - Delete     │    │ - Increment  │
        │   from store │    │   attempts   │
        │ - Proceed    │    │ - Return     │
        │   with auth  │    │   error      │
        └──────────────┘    └──────────────┘
```

## Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   authController.js                         │
│                                                             │
│  sendOTP(req, res)                                          │
│  ├─ Extract phone/email/countryCode                         │
│  ├─ Validate input                                          │
│  ├─ Check if user exists                                    │
│  └─ Route to service                                        │
│                                                             │
│  verifyOTP(req, res)                                        │
│  ├─ Extract phone/email/otp                                 │
│  ├─ Look up in OTP Store                                    │
│  ├─ Verify OTP matches                                      │
│  └─ Return result                                           │
│                                                             │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│ authkeyService   │      │ resendService    │
│                  │      │                  │
│ sendOTP()        │      │ sendEmailOTP()   │
│ ├─ Generate OTP  │      │ ├─ Generate OTP  │
│ ├─ Build params  │      │ ├─ Build HTML    │
│ ├─ Call API      │      │ ├─ Call API      │
│ └─ Return result │      │ └─ Return result │
│                  │      │                  │
│ verifyOTP()      │      │ sendEmail()      │
│ ├─ Call API      │      │ ├─ Build request │
│ └─ Return result │      │ ├─ Call API      │
│                  │      │ └─ Return result │
└────────┬─────────┘      └────────┬─────────┘
         │                         │
         ▼                         ▼
    AuthKey.io              Resend API
    api.authkey.io          api.resend.com
    /request                /emails
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Send OTP Request                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ Try to send OTP        │
        └────────────┬───────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
    ┌─────────┐            ┌──────────┐
    │ Success │            │ Error    │
    └────┬────┘            └────┬─────┘
         │                      │
         ▼                      ▼
    Store OTP          ┌──────────────────┐
    Return OK          │ Check NODE_ENV   │
                       └────────┬─────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
            ┌──────────────┐        ┌──────────────┐
            │ Development  │        │ Production   │
            │              │        │              │
            │ Use fallback │        │ Throw error  │
            │ OTP locally  │        │ Return 500   │
            │ Return OK    │        │              │
            └──────────────┘        └──────────────┘
```

## OTP Expiry & Cleanup

```
┌─────────────────────────────────────────────────────────────┐
│                    OTP Store Timeline                       │
│                                                             │
│  T=0s: OTP Created                                          │
│  ├─ expiresAt = now + 600000ms (10 minutes)                │
│  │                                                          │
│  T=300s: User enters OTP (5 minutes later)                 │
│  ├─ Check: now < expiresAt? YES ✅                         │
│  ├─ Verify OTP                                             │
│  ├─ Delete from store                                      │
│  │                                                          │
│  T=600s: OTP Expires (10 minutes later)                    │
│  ├─ Check: now < expiresAt? NO ❌                          │
│  ├─ Return: "OTP expired"                                  │
│  ├─ Delete from store                                      │
│  │                                                          │
│  T=601s: Store cleaned up                                  │
│  └─ OTP removed from memory                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

These diagrams show the complete OTP flow from request to verification!
