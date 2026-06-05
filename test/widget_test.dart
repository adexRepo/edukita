// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:edukita/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Edukita app loads', (WidgetTester tester) async {
    dotenv.testLoad(
      fileInput: '''
APP_DATA_PATH=.dart_tool/test_app_data
DB_PATH=database
STORAGE_PATH=storage
''',
    );
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const EdukitaApp());
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
