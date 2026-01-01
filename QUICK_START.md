# 🚀 Quick Start: Get FluentMind on Your Phone

## Option 1: Install on Android (Fastest - 15 minutes)

### Step 1: Build the APK
```bash
cd mobile
flutter build apk --release
```

### Step 2: Transfer to Phone
The APK will be at: `mobile/build/app/outputs/flutter-apk/app-release.apk`

**Method A - USB:**
```bash
# Connect phone via USB
# Enable USB debugging on phone
flutter install
```

**Method B - Email/Cloud:**
1. Email the APK to yourself
2. Open on phone
3. Allow "Install from unknown sources"
4. Install

### Step 3: Note About Backend
⚠️ **Important:** The app will try to connect to `http://10.0.2.2:8000` (emulator localhost).

**For real device testing, you have 2 options:**

**A) Use Local Network (Testing Only):**
1. Find your computer's IP:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   ```

2. Update `mobile/lib/core/config/app_config.dart`:
   ```dart
   static const String _defaultApiUrl = 'http://YOUR_IP:8000'; // e.g., http://192.168.1.100:8000
   ```

3. Rebuild APK:
   ```bash
   flutter build apk --release
   flutter install
   ```

4. Start backend:
   ```bash
   cd backend
   source venv/bin/activate
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

5. **Make sure phone and computer are on same WiFi**

**B) Deploy Backend (Production):**
   - See DEPLOYMENT_GUIDE.md
   - Deploy to Railway/Render (30 min)
   - Update API URL
   - Rebuild app

---

## Option 2: Install on iPhone (Requires Mac)

### Prerequisites:
- Mac computer
- Xcode installed
- iPhone connected

### Steps:
```bash
cd mobile
flutter build ios --release

# Then in Xcode:
# 1. Open ios/Runner.xcworkspace
# 2. Select your iPhone as destination
# 3. Product > Run
```

---

## Option 3: Test in Web Browser (No Build Needed)

```bash
cd mobile
flutter run -d chrome
```

Opens in Chrome - great for quick testing UI/UX, but:
- ❌ No audio recording
- ❌ No native features
- ✅ Good for navigation/layout testing

---

## ⚡ Fastest Way to See It Working

### 1. Local Testing (5 minutes):
```bash
# Terminal 1 - Start Backend
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Terminal 2 - Run App
cd mobile
flutter run -d chrome
```

### 2. What You Can Test:
✅ All UI/UX
✅ Navigation
✅ Gamification features
✅ Word Association games
❌ Audio recording (Chrome limitation)
❌ Firebase auth (needs configuration)

---

## 🎯 Recommended Path

**For Quick Demo:**
→ Use web version (`flutter run -d chrome`)

**For Full Testing:**
→ Build Android APK + Deploy backend to Railway

**For App Store:**
→ See DEPLOYMENT_GUIDE.md (full process)

---

## 🔧 Troubleshooting

### Build Failed?
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

### Can't Connect to Backend?
1. Check backend is running: `curl http://localhost:8000/health`
2. Check phone and computer on same WiFi
3. Check firewall isn't blocking port 8000
4. Try IP instead of localhost

### "Install Blocked"?
- Android: Settings > Security > Allow unknown sources
- iOS: Settings > General > Device Management > Trust app

---

## 📱 What Works Without Backend?

**Fully Functional:**
- ✅ Gamification (XP, levels, achievements) - Uses local storage
- ✅ Word Association game - All 4 modes
- ✅ UI navigation
- ✅ Dark mode
- ✅ Animations

**Requires Backend:**
- ❌ Speech recognition
- ❌ AI feedback
- ❌ User authentication
- ❌ Progress sync across devices

So you can actually test most features offline!

---

## 🎉 Success!

Once installed, you'll see:
1. Splash screen
2. Onboarding (swipe through)
3. Home screen with gamification card
4. Try the Word Association game!

Enjoy testing FluentMind! 🚀
