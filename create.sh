flutter clean
flutter pub get
find . -name '*.g.dart' -delete
dart run build_runner build --delete-conflicting-outputs