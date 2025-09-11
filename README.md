# AezaFlutter

iOS Flutter app with Firebase auth/storage, drawing editor, gallery, share/export. Uses BLoC for state, Dio+Retrofit for network.

## Stack
- Flutter, Dart
- Firebase: Auth, Firestore, Storage
- State: bloc, flutter_bloc
- Network: dio, retrofit (+ build_runner)
- Media: image_picker, image_gallery_saver, share_plus
- iOS: flutter_local_notifications (pending wiring)

## Setup
1. Install Flutter and Firebase CLI. Login: `firebase login`
2. Configure Firebase for iOS:
   - Create a Firebase project, add iOS app with bundle id `com.aeza.aezaFlutter`.
   - Run:
     ```bash
     flutterfire configure --platforms=ios --ios-bundle-id com.aeza.aezaFlutter --out=lib/firebase_options.dart
     ```
3. Install deps:
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run iOS:
   ```bash
   flutter run -d ios
   ```

## Permissions
- Photos read/write, Camera, Notifications configured in `ios/Runner/Info.plist`.

## Architecture
- `lib/app.dart`: root app, routes, BLoCs
- `lib/main.dart`: Firebase init
- `lib/data/`: repositories (`auth_repository.dart`, `storage_repository.dart`)
- `lib/feature/auth/`: Auth BLoC + UI
- `lib/feature/gallery/`: user images grid
- `lib/feature/editor/`: canvas, import, save, share
- `lib/network/`: retrofit `ApiClient`

## Features
- Email/password sign up/sign in with validation and errors.
- Drawing canvas with brush, eraser, color, thickness, image import.
- Save to gallery and upload to Firebase Storage + Firestore metadata.
- Share sheet export.
- Gallery of user images, tap to open in editor, sign out.

## Notes
- Replace temporary canvas with `flutter_painter` if desired; current version uses a CustomPainter for stability with pinned deps.
- Hook local notifications on successful save (pending).
