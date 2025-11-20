# 🚀 Quick Start - Registration & Login

**Read This First!** ⭐ Estimated read time: 5 minutes

---

## 🎯 In 30 Seconds

```
1. Open App → LoginScreen
2. Click "Register"
3. Fill form (name, email, password, confirm)
4. Click "Register" → Data saved to database ✅
5. Click "Login"
6. Enter email & password
7. Check "Remember me" (optional)
8. Click "Login" → MainScreen ✅
```

---

## 📱 Step-by-Step Guide

### Step 1: Registration

**Location:** LoginScreen → "Register" button

```
┌─────────────────────────┐
│   Create Account        │
├─────────────────────────┤
│ Name:                   │
│ [Your Full Name      ]  │
│                         │
│ Email:                  │
│ [your@email.com      ]  │
│                         │
│ Password:               │
│ [••••••••••••••••    ]  │
│                         │
│ Confirm Password:       │
│ [••••••••••••••••    ]  │
│                         │
│ [Register Button  ]     │
└─────────────────────────┘
```

**Required Fields:**
- ✅ Name (not empty)
- ✅ Email (must have @)
- ✅ Password (min 6 characters)
- ✅ Confirm Password (must match)

**Example:**
```
Name:     John Doe
Email:    john@example.com
Password: MyPassword123
Confirm:  MyPassword123
```

**Result:** Success message → Back to Login ✅

---

### Step 2: Login

**Location:** LoginScreen

```
┌─────────────────────────┐
│   Bloom Manager         │
│   Login                 │
├─────────────────────────┤
│ Email:                  │
│ [john@example.com    ]  │
│                         │
│ Password:               │
│ [••••••••••••••••    ]  │
│                         │
│ ☑ Remember me           │
│ [Forgot Password?]      │
│                         │
│ [Login Button       ]   │
│                         │
│ Don't have an account?  │
│ [Register]              │
└─────────────────────────┘
```

**Fields:**
- ✅ Email: Use the email you registered with
- ✅ Password: Use the password you registered with

**Optional:**
- ☑ Remember me: Check this to auto-login next time

**Example:**
```
Email:    john@example.com
Password: MyPassword123
```

**Result:** Logged in → MainScreen ✅

---

## ✅ What Happens When...

### Registration Successful
```
✅ "Registration successful! Please login."
→ Automatically back to LoginScreen
→ User data saved in database
→ Ready to login
```

### Registration Failed: Email Already Registered
```
❌ "Email already registered!"
→ Stay on Register screen
→ Use different email
→ Or login with that email
```

### Registration Failed: Password Too Short
```
❌ "Password must be at least 6 characters"
→ Stay on Register screen
→ Enter longer password
```

### Login Successful
```
✅ MainScreen loaded
✅ User name displayed
✅ All features available
```

### Login Failed: Email Not Registered
```
❌ "Invalid email or password. Please check and try again."
→ Stay on LoginScreen
→ Must register first
→ Or check email spelling
```

### Login Failed: Wrong Password
```
❌ "Invalid email or password. Please check and try again."
→ Stay on LoginScreen
→ Re-enter correct password
→ Check caps lock
```

---

## 🔐 Remember Me Feature

### What It Does
- Saves your email & password on your phone
- Next time you open app → Auto-login
- No need to enter credentials again

### How to Use
```
1. At Login screen, check the "Remember me" checkbox
2. Click Login
3. Next time you open app → Directly in MainScreen
4. No login screen shown
```

### How to Disable
```
1. Go to Settings (in MainScreen)
2. Click "Logout" button
3. Next time → Login screen shown
```

### Security Note
⚠️ **Only use on your personal phone!**  
If others have access to your phone, they can auto-login as you.

---

## ❓ FAQ

### Q: Can I use any email?
**A:** Email must have @ symbol  
**Example:** ✅ john@gmail.com, ❌ johngmail.com

### Q: What's the minimum password length?
**A:** 6 characters  
**Example:** ✅ MyPass123, ❌ 12345

### Q: Can I use same email twice?
**A:** No, each email can only register once  
**Error:** "Email already registered"

### Q: I forgot my password!
**A:** Click "Forgot Password?" on login screen  
*(Feature in development)*

### Q: Remember me not working?
**A:** 
- Make sure you checked the checkbox
- Check app settings > permissions
- Try logging out and in again

### Q: I can't login
**Troubleshoot:**
1. Check email spelling (lowercase)
2. Check password spelling (case sensitive)
3. Make sure you registered first
4. Clear app cache if needed

### Q: Can I change my password?
**A:** Not yet - future feature  
*Workaround: Register with different email*

### Q: Where is my data saved?
**A:** Local database on your phone (SQLite)  
**File:** bloom_manager.db

### Q: Is my password secure?
**A:** Encrypted in local database  
**Not encrypted in transit:** Use HTTPS in future

---

## 🧪 Test User (After First Registration)

After you register your first user, you can test with:

```
Email:    testuser@example.com
Password: testpass123
```

**How to Create:**
1. Click Register
2. Name: Test User
3. Email: testuser@example.com
4. Password: testpass123
5. Confirm: testpass123
6. Click Register

---

## 🎯 Common Scenarios

### Scenario 1: First Time Opening App
```
1. App opens → LoginScreen
2. No auto-login (first time)
3. Click "Register"
4. Create account
5. Login with new account
6. Enjoy app!
```

### Scenario 2: Returning User (with Remember Me)
```
1. App opens → MainScreen
2. Auto-login (saved credentials)
3. No login screen needed
4. Ready to work!
```

### Scenario 3: Returning User (without Remember Me)
```
1. App opens → LoginScreen
2. Enter email & password
3. Click Login
4. MainScreen loaded
5. Ready to work!
```

### Scenario 4: New Device / Fresh Install
```
1. Register on new device
2. Enter email & password
3. Can't login with old account
   (because it's on different device)
4. Must register again
5. OR sync credentials somehow
```

---

## 📊 What Gets Saved

### In Database (Permanent)
```
✅ Email address
✅ Password (plain text currently)
✅ Full name
✅ Registration date/time
```

### On Phone (Temporary - if Remember Me)
```
✅ Email (encrypted)
✅ Password (encrypted)
✅ Remember Me flag
```

### Cleared When
```
🗑️ You click Logout
🗑️ You uninstall app
🗑️ You clear app data
```

---

## 🔧 Troubleshooting

### Problem: "Email already registered"
**Cause:** Email already used in database  
**Solution:** 
- Use different email
- Or login with that email

### Problem: "Password must be at least 6 characters"
**Cause:** Password too short  
**Solution:** Use 6+ characters

### Problem: "Invalid email or password"
**Cause:** 
- Email not registered yet
- Password incorrect
**Solution:**
- Register first if new user
- Check password spelling (case sensitive)

### Problem: "Email already registered" but I'm new
**Cause:** Email used by another user  
**Solution:**
- Use different email
- Ask admin to clear that email

### Problem: Remember Me not working
**Cause:**
- Didn't check checkbox
- App cache cleared
- Phone restarted
**Solution:**
- Check checkbox when login
- Try logout and login again
- Reinstall if needed

### Problem: Can't click Register/Login buttons
**Cause:** Form validation failed  
**Solution:**
- Fill all required fields
- Check email format (has @)
- Check password length (6+ chars)
- Confirm passwords match

---

## 📚 Learn More

For more detailed information:
- 📖 **REGISTRATION_GUIDE.md** - Complete guide
- 📖 **LOGIN_AUTHENTICATION.md** - Login details
- 📖 **DOCUMENTATION_INDEX.md** - All docs
- 📖 **README.md** - Project overview

---

## 💬 Questions?

Check the troubleshooting section above!  
If issue persists:
1. Read REGISTRATION_GUIDE.md
2. Check database with sqlite3
3. Clear app cache & reinstall
4. Contact developer

---

**Last Updated:** November 12, 2025  
**Version:** 1.0  
**Status:** ✅ Ready to Use
