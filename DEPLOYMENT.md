# 🚀 FluentMind Deployment Guide

This guide walks you through deploying FluentMind backend to Render.com and configuring the mobile app for production.

---

## 📋 Prerequisites

Before deploying, ensure you have:
- [x] GitHub repository with the FluentMind code
- [x] [Render.com](https://render.com) account (free tier works)
- [x] [OpenAI API Key](https://platform.openai.com/api-keys)
- [x] Firebase project with service account JSON

---

## 🗄️ Step 1: Deploy to Render.com

### Option A: Blueprint Deployment (Recommended)

1. **Push code to GitHub**
   ```bash
   git add -A
   git commit -m "Add Render deployment configuration"
   git push origin main
   ```

2. **Go to Render Dashboard**
   - Visit [render.com/dashboard](https://render.com/dashboard)
   - Click **"New +"** → **"Blueprint"**

3. **Connect Repository**
   - Select your GitHub repository: `igRoy3/fluentmind`
   - Render will detect `render.yaml` and create:
     - PostgreSQL database: `fluentmind-db`
     - Web service: `fluentmind-api`

4. **Wait for deployment** (5-10 minutes)

### Option B: Manual Deployment

1. **Create PostgreSQL Database**
   - Render Dashboard → **New +** → **PostgreSQL**
   - Name: `fluentmind-db`
   - Plan: Free
   - Click **Create Database**
   - Copy the **Internal Database URL**

2. **Create Web Service**
   - Render Dashboard → **New +** → **Web Service**
   - Connect your GitHub repo
   - Settings:
     - **Name:** `fluentmind-api`
     - **Root Directory:** `backend`
     - **Runtime:** Python
     - **Build Command:** `pip install -r requirements.txt`
     - **Start Command:** `gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT`

---

## 🔐 Step 2: Configure Environment Variables

In the Render dashboard for your web service, go to **Environment** and add:

| Variable | Value | Description |
|----------|-------|-------------|
| `ENVIRONMENT` | `production` | Production mode |
| `DATABASE_URL` | *(auto-linked from database)* | PostgreSQL connection string |
| `OPENAI_API_KEY` | `sk-...` | Your OpenAI API key |
| `FIREBASE_CREDENTIALS_JSON` | `{...}` | Firebase service account JSON (see below) |
| `CORS_ORIGINS` | `*` | Allowed origins |
| `LOG_LEVEL` | `INFO` | Logging level |
| `RATE_LIMIT` | `100/minute` | API rate limit |

### Getting Firebase Credentials JSON

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project → **Project Settings** → **Service Accounts**
3. Click **"Generate new private key"**
4. Open the downloaded JSON file
5. Copy the **entire contents** and paste as `FIREBASE_CREDENTIALS_JSON` value

---

## 📱 Step 3: Update Mobile App

### Update API URL

1. Open `mobile/lib/core/config/app_config.dart`
2. Update the production URL:
   ```dart
   static const String productionApiUrl = 'https://fluentmind-api.onrender.com';
   ```
   Replace `fluentmind-api` with your actual Render service name.

### Build Production APK

```bash
cd mobile

# Build with production flag
flutter build apk --release --dart-define=IS_PRODUCTION=true

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build for iOS (requires Mac + Xcode)

```bash
cd mobile

# Build for iOS
flutter build ios --release --dart-define=IS_PRODUCTION=true

# Then open Xcode to archive and distribute
open ios/Runner.xcworkspace
```

---

## ✅ Step 4: Verify Deployment

### Test API Health

```bash
curl https://fluentmind-api.onrender.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "environment": "production"
}
```

### Test with Mobile App

1. Install the production APK on your device
2. Open the app and try:
   - Creating an account / Signing in
   - Recording speech for analysis
   - Starting a conversation

---

## 🔧 Database Migrations

After first deployment, run migrations:

```bash
# On Render, use Shell (in Dashboard → Shell)
alembic upgrade head
```

Or set up auto-migrations by adding to `render.yaml`:
```yaml
buildCommand: pip install -r requirements.txt && alembic upgrade head
```

---

## 📊 Monitoring

### View Logs
- Render Dashboard → Your service → **Logs**

### Set Up Alerts
- Render Dashboard → Your service → **Settings** → **Health Check**
- Configure: `/health` endpoint

### Error Tracking (Optional)
Add Sentry for error tracking:
1. Create account at [sentry.io](https://sentry.io)
2. Create a FastAPI project
3. Add `SENTRY_DSN` environment variable in Render

---

## 💰 Cost Estimate

### Free Tier Limits
- **Web Service:** 750 hours/month (enough for 1 service)
- **PostgreSQL:** 1GB storage, 97 hours uptime/month
- **Note:** Free services spin down after 15 minutes of inactivity

### Starter Plan (Recommended for production)
- **Web Service:** $7/month (always on)
- **PostgreSQL:** $7/month (persistent)

---

## 🐛 Troubleshooting

### "Service Unavailable" after deploy
- Check logs for errors
- Verify all environment variables are set
- Wait for the service to fully start (can take 2-3 minutes)

### Database connection errors
- Ensure `DATABASE_URL` is set
- Check if database is created and running
- Verify the connection string format

### Firebase errors
- Ensure `FIREBASE_CREDENTIALS_JSON` is valid JSON
- Check that it's not escaped (should be raw JSON)

### OpenAI API errors
- Verify `OPENAI_API_KEY` is correct
- Check OpenAI account has credits/billing set up

### Mobile app can't connect
- Verify the API URL in `app_config.dart`
- Check if CORS is configured (`CORS_ORIGINS=*`)
- Ensure the app is built with `IS_PRODUCTION=true`

---

## 📝 Quick Commands Reference

```bash
# Push to GitHub
git add -A && git commit -m "Update" && git push

# Build Android APK (production)
cd mobile && flutter build apk --release --dart-define=IS_PRODUCTION=true

# Build iOS (production)
cd mobile && flutter build ios --release --dart-define=IS_PRODUCTION=true

# Test API locally
curl http://localhost:8000/health

# Test production API
curl https://fluentmind-api.onrender.com/health

# Run migrations (on Render Shell)
alembic upgrade head
```

---

## 🎉 Done!

Your FluentMind app is now deployed and accessible worldwide! 

- **API URL:** `https://fluentmind-api.onrender.com`
- **Share the APK** with friends to test

---

Need help? Open an issue on GitHub!
