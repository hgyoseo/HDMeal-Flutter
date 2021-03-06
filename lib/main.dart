// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:hdmeal/screens/home.dart';
import 'package:hdmeal/screens/settings.dart';
import 'package:hdmeal/screens/settings/changeorder.dart';
import 'package:hdmeal/screens/settings/keyword_highlight.dart';
import 'package:hdmeal/screens/settings/theme.dart';
import 'package:hdmeal/screens/settings/about.dart';
import 'package:hdmeal/screens/settings/about/osslicences.dart';
import 'package:hdmeal/utils/preferences_manager.dart';
import 'package:hdmeal/utils/theme.dart';

FirebaseAnalytics analytics;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  analytics = FirebaseAnalytics();
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  await PrefsManager().init();

  final ThemeData theme = ThemeNotifier().determineTheme();

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(theme),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      themeNotifier.handleChangeTheme();
    };

    return MaterialApp(
      title: "흥덕고 급식",
      theme: themeNotifier.getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/settings': (context) => SettingsPage(),
        '/settings/changeOrder': (context) => ChangeOrderPage(),
        '/settings/keywordHighlight': (context) => KeywordHighlightPage(),
        '/settings/theme': (context) => ThemeSettingsPage(),
        '/settings/about': (context) => AboutPage(),
        '/settings/about/OSSLicences': (context) => OSSLicencesPage(),
      },
      navigatorObservers: [
        routeObserver,
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      supportedLocales: [
        const Locale('ko'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
