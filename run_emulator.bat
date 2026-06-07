@echo off
cd /d "%~dp0"
echo Building and running APS Pro POS on Android emulator...
flutter pub get
flutter run -d emulator-5554 --no-enable-impeller
