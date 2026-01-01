import 'package:artsphere/app/app.dart';
import 'package:artsphere/core/services/hive_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();
  runApp(ProviderScope(child: MyApp()));
}
