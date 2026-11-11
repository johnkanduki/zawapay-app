import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/account/app_rules.dart';
import 'core/account/zawapay_account.dart';
import 'core/settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  // Signed in last time: straight to the home page (read on the phone, no
  // network needed).
  final signedIn = await zawapayAccount.saved();
  // Latest fees from the admin dashboard, without waiting for them.
  refreshAppRules();
  final settings = AppSettings();
  await settings.load();
  runApp(ZawapayApp(signedIn: signedIn, settings: settings));
}
