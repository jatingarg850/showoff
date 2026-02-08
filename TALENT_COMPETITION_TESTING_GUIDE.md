# Talent Competition End Date - Testing Guide

## Quick Test (5 minutes)

### Step 1: Create a Test Competition
1. Go to Admin Panel → Talent Management
2. Click "Create Competition"
3. Fill in:
   - **Title:** "Test Competition - 5 Min"
   - **Type:** Weekly
   - **Start Date:** Now
   - **End Date:** 5 minutes from now
   - **Prizes:** Default
4. Click Create

### Step 2: Open App and Watch Countdown
1. Open ShowOff Life app
2. Go to Talent/SYT screen
3. Look at the countdown timer (top right)
4. **Expected:** Shows "Ends 5m" or similar
5. **Watch for 30 seconds** - countdown should update (5m → 4m 50s, etc.)

### Step 3: Wait for Competition to End
1. Keep the screen open
2. Wait for 5 minutes
3. **Expected:** 
   - Countdown reaches "Ends 0m"
   - Changes to "Competition ended"
   - No app reload needed!

---

## Detailed Test Scenarios

### Scenario 1: Timezone Verification
**Purpose:** Verify dates are stored correctly regardless of timezone

**Steps:**
1. Note your server timezone (check server logs or `date` command)
2. Note your admin panel timezone (browser timezone)
3. Create competition with end date: "Tomorrow at 2:00 PM"
4. Check server logs for date parsing:
   ```
   📅 Competition dates: {
     startDate: "2024-01-15T14:00",
     endDate: "2024-01-16T14:00",
     parsedStart: "2024-01-15T08:30:00.000Z",  // UTC
     parsedEnd: "2024-01-16T08:30:00.000Z",    // UTC
     now: "2024-01-15T08:45:00.000Z"
   }
   ```
5. **Expected:** Parsed dates should match your local timezone intent

### Scenario 2: Real-Time Countdown
**Purpose:** Verify countdown updates without reload

**Steps:**
1. Create competition ending in 2 minutes
2. Open Talent Screen
3. Note the countdown (e.g., "Ends 2m")
4. Wait 30 seconds
5. **Expected:** Countdown updated to "Ends 1m 30s"
6. Don't reload - just wait
7. **Expected:** Continues updating every 10 seconds

### Scenario 3: Competition End Transition
**Purpose:** Verify smooth transition when competition ends

**Steps:**
1. Create competition ending in 1 minute
2. Create another competition starting after the first one ends
3. Open Talent Screen
4. Watch countdown reach 0
5. **Expected:**
   - Shows "Competition ended"
   - Automatically loads new competition
   - Countdown updates to new competition's end time
   - No manual refresh needed

### Scenario 4: Multiple Competitions
**Purpose:** Verify only active competition is shown

**Steps:**
1. Create Competition A: ends in 5 minutes
2. Create Competition B: starts after A ends, ends in 10 minutes
3. Open Talent Screen
4. **Expected:** Shows Competition A countdown
5. Wait for A to end
6. **Expected:** Automatically switches to Competition B
7. Verify entries are from Competition B only

### Scenario 5: App Lifecycle
**Purpose:** Verify timer cleanup and no memory leaks

**Steps:**
1. Open Talent Screen
2. Wait 30 seconds (verify countdown updates)
3. Navigate away from Talent Screen
4. **Expected:** Timer stops (no more API calls)
5. Return to Talent Screen
6. **Expected:** Timer restarts, countdown updates
7. Check device memory - should not increase over time

---

## Server-Side Verification

### Check Competition in Database
```bash
# SSH into server
ssh user@server

# Connect to MongoDB
mongosh

# Check competition
db.competitionsettings.findOne({type: "weekly", isActive: true})

# Expected output:
{
  _id: ObjectId(...),
  type: "weekly",
  title: "Test Competition",
  startDate: ISODate("2024-01-15T08:30:00.000Z"),
  endDate: ISODate("2024-01-16T08:30:00.000Z"),
  isActive: true,
  ...
}
```

### Check Server Logs
```bash
# Watch server logs
tail -f server.log | grep -E "📅|✅|❌"

# Expected logs when creating competition:
📅 Competition dates: {...}
✅ Competition created: {...}
```

### Test API Endpoint
```bash
# Get current competition
curl "http://localhost:3000/api/syt/current-competition?type=weekly"

# Expected response:
{
  "success": true,
  "data": {
    "hasActiveCompetition": true,
    "competition": {
      "id": "...",
      "title": "Test Competition",
      "startDate": "2024-01-15T08:30:00.000Z",
      "endDate": "2024-01-16T08:30:00.000Z",
      "isActive": true
    }
  }
}
```

---

## App-Side Verification

### Check App Logs
```
# In Flutter console, look for:
📅 Loaded competition: Ends 5m
📅 Loaded competition: Ends 4m 50s  (after 10 seconds)
📅 Loaded competition: Ends 4m 40s  (after 20 seconds)
...
📅 Loaded competition: Competition ended
📅 Loaded competition: Ends 10m  (new competition)
```

### Verify Timer Updates
1. Open Talent Screen
2. Open Flutter DevTools
3. Go to Performance tab
4. Look for periodic API calls to `/api/syt/current-competition`
5. **Expected:** Calls every 30 seconds (not every 10 - that's just UI update)

---

## Troubleshooting

### Issue: Countdown doesn't update
**Solution:**
1. Check if timer is running: Look for API calls in network tab
2. Check app logs for errors
3. Verify `_countdownTimer` is initialized in `initState()`
4. Verify `dispose()` is not called prematurely

### Issue: Competition doesn't end at exact time
**Solution:**
1. Check server timezone: `date` command
2. Check admin panel timezone: Browser DevTools
3. Check database dates: `mongosh` query above
4. Verify date parsing in server logs

### Issue: New competition doesn't appear after old one ends
**Solution:**
1. Verify new competition exists in database
2. Verify new competition's `startDate` is before current time
3. Verify new competition's `endDate` is after current time
4. Check app logs for errors in `_loadCompetitionInfo()`

### Issue: Memory leak / app slows down
**Solution:**
1. Verify timer is cancelled in `dispose()`
2. Check for multiple timer instances
3. Monitor device memory in DevTools
4. Check for circular references in state

---

## Performance Benchmarks

### Expected Behavior
- **Countdown update:** Every 10 seconds (UI only, no API call)
- **Competition refresh:** Every 30 seconds (API call)
- **API response time:** < 100ms
- **Memory usage:** < 5MB increase per screen
- **Battery impact:** Negligible (timers are very lightweight)

### Acceptable Ranges
- Countdown update: 8-12 seconds
- Competition refresh: 25-35 seconds
- API response: < 200ms
- Memory: < 10MB increase

---

## Sign-Off Checklist

- [ ] Countdown updates every 10 seconds
- [ ] Competition ends at exact time (no reload needed)
- [ ] New competition appears automatically
- [ ] No memory leaks
- [ ] Works on Android
- [ ] Works on iOS
- [ ] Works with different timezones
- [ ] Server logs show correct date parsing
- [ ] Database stores correct dates
- [ ] API returns correct competition status
