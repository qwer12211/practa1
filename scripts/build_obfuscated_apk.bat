@echo off
REM Сборка релизного APK с обфускацией Dart (имена классов/методов в snapshot).
REM Папка symbols/ — НЕ коммитить в git (в .gitignore); храни копию для расшифровки крашей.
cd /d "%~dp0.."
if not exist symbols mkdir symbols
echo.
echo === Flutter: release APK + obfuscate ===
echo Символы: %CD%\symbols
echo.
flutter build apk --release --obfuscate --split-debug-info=symbols
if errorlevel 1 exit /b 1
echo.
echo APK: build\app\outputs\flutter-apk\app-release.apk
exit /b 0
