# FluentMind App Icon

## 📱 Icon Design Requirements

### Current Status: ⚠️ Using Default Flutter Icon

You need to create a 1024x1024 PNG icon and place it here as `app_icon.png`

### Design Suggestions:

**Concept Ideas:**
1. **Brain + Speech Bubble** - Combines learning and speaking
2. **Microphone + Language Symbol** - Audio learning focus
3. **Graduation Cap + Globe** - Global language education
4. **Abstract Fluid Shapes** - Modern, app-like feel

**Color Scheme:**
- Primary: `#6366F1` (Indigo) - App's main color
- Secondary: `#8B5CF6` (Purple)
- Accent: `#F59E0B` (Amber) - Used in gamification

**Design Requirements:**
- Size: 1024x1024 pixels
- Format: PNG with transparent background
- Safe area: Keep important elements in center 75%
- No text (too small to read on home screen)
- Simple and recognizable at small sizes
- Follows iOS and Android guidelines

### Quick Options:

#### Option 1: Use Canva (Free)
1. Go to [canva.com](https://canva.com)
2. Create 1024x1024 design
3. Use templates: Search "App Icon"
4. Customize with your colors
5. Download as PNG

#### Option 2: Hire on Fiverr
- Search "app icon design"
- Price: $5-50
- Turnaround: 24-48 hours

#### Option 3: Use AI (Midjourney/DALL-E)
Prompt example:
```
"minimalist app icon design for language learning app, 
speech bubble with microphone, gradient purple and blue colors, 
clean modern style, flat design, no text"
```

#### Option 4: Use Free Tools
- [Figma](https://figma.com) - Professional design tool (free)
- [Photopea](https://photopea.com) - Online Photoshop (free)
- [GIMP](https://gimp.org) - Desktop editor (free)

### After Creating Icon:

1. Save as `app_icon.png` (1024x1024)
2. Place in this directory
3. Run generation command:
   ```bash
   cd mobile
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

This will automatically create all required sizes for:
- ✅ Android (48-192px)
- ✅ iOS (20-1024px)
- ✅ Web (192, 512px)

### Testing Your Icon:

After generation, rebuild the app:
```bash
flutter clean
flutter pub get
flutter run
```

Your new icon will appear on the home screen!

---

## 🎨 Temporary Solution

If you need to test the app immediately without a custom icon, the default Flutter icon will work fine. You can add a custom icon later without affecting functionality.

## 📐 Icon Dimensions Reference

**Android:**
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

**iOS:**
- App icon: 20x20 to 1024x1024 (multiple sizes)
- See `Contents.json` for complete list

**Web:**
- 192x192 (PWA)
- 512x512 (maskable)
- favicon.png (16x16)
