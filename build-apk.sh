#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  Saba Fit — one-command APK build + install script
#  Usage: ./build-apk.sh [optional: path/to/saba-fitness.zip]
#  Run from anywhere — it handles paths automatically
# ─────────────────────────────────────────────────────────────

ZIP="${1:-$HOME/Downloads/saba-fitness.zip}"
WEB_SRC="$HOME/saba-fitness"
CAP_DIR="$HOME/saba-fitness-app"
APK="$CAP_DIR/android/app/build/outputs/apk/debug/app-debug.apk"

echo "🏃 Saba Fit — Build & Deploy"
echo "──────────────────────────────"

# Step 1 — deploy web app if zip provided
if [ -f "$ZIP" ]; then
  echo "📦  Unzipping $ZIP..."
  unzip -o "$ZIP" -d "$HOME" > /dev/null
  echo "🌐  Deploying to GitHub..."
  cd "$WEB_SRC" && git add . && git commit -m "Update app $(date '+%b %d %H:%M')" && git push
else
  echo "ℹ️   No zip found — using existing web files"
fi

# Step 2 — copy updated web files into Capacitor
echo "📋  Copying web files..."
cp "$WEB_SRC/index.html" "$CAP_DIR/www/"
cp "$WEB_SRC/manifest.json" "$CAP_DIR/www/"

# Step 3 — sync Capacitor
echo "🔄  Syncing Capacitor..."
cd "$CAP_DIR"
npx cap sync android > /dev/null

# Step 3.5 — fix Java version (cap sync resets this every time)
echo "☕  Fixing Java version..."
find "$CAP_DIR" -name "*.gradle" -o -name "*.gradle.kts" | xargs grep -rl "VERSION_21" 2>/dev/null | while read f; do
  sed -i 's/VERSION_21/VERSION_17/g' "$f"
done

# Step 4 — build APK
echo "🔨  Building APK..."
cd "$CAP_DIR/android"
./gradlew assembleDebug --quiet

if [ $? -ne 0 ]; then
  echo "❌  Build failed — check output above"
  exit 1
fi

echo "✅  Build successful!"

# Step 5 — install on Pixel if connected
DEVICE=$(adb devices | grep -v "List of devices" | grep "device$" | head -1 | awk '{print $1}')
if [ -n "$DEVICE" ]; then
  echo "📱  Installing on Pixel ($DEVICE)..."
  adb -s "$DEVICE" install -r "$APK"
  echo "✅  Installed! Open Saba Fit on your Pixel."
else
  echo "⚠️   No device connected via USB."
  echo "    APK is at: $APK"
  echo "    Connect your Pixel and run:"
  echo "    adb install -r $APK"
fi

echo ""
echo "🎉  All done, Saba!"
