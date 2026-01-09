# 💀 Base App Skeleton

This is the standard skeleton for all new Factory Apps.
It comes pre-wired with:
- **UI Shell**: Standard Factory Theme (Dark/Light) & Widgets.
- **Analytics**: Wrappers pre-hooked into navigation.
- **Router**: GoRouter set up with Home/Settings.

## How to Create a New App (E.g. `rental_calc`)

1. **Copy** this folder to `apps/rental_calc`.
2. **Rename** in `pubspec.yaml`:
   ```yaml
   name: rental_calc
   ```
3. **Rename** in `android/app/build.gradle` (if you need Android):
   ```gradle
   applicationId "com.factory.rental_calc"
   ```
4. **Run**:
   ```bash
   flutter pub get
   flutter run
   ```

## Structure
- `lib/router.dart`: Add your new pages here.
- `lib/screens/`: Put your page logic here.
- `lib/main.dart`: Global app config (Theme, Providers).
