#!/bin/bash
# Dieses Skript wird von Cloudflare Pages automatisch ausgeführt.
# Es installiert Flutter (feste Version 3.35.4) und baut die Web-App.
set -e

echo "==> Installiere Flutter 3.35.4 ..."
git clone https://github.com/flutter/flutter.git -b 3.35.4 --depth 1 _flutter
export PATH="$PWD/_flutter/bin:$PATH"

echo "==> Aktiviere Web-Support ..."
flutter config --enable-web

echo "==> Lade Abhängigkeiten ..."
flutter pub get

echo "==> Baue Release-Version der Web-App ..."
flutter build web --release

echo "==> Fertig! Ausgabe liegt in build/web"
