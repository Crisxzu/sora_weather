import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/l10n/l10n.dart';
import 'package:weather_app/providers/params.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/home/home.dart';
import 'package:weather_app/view/home/widgets/link_button.dart';
import 'package:weather_app/view/home/widgets/position.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/view/settings/settings.dart';

import 'env/env.dart';


Future main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox("appParams");
  await AppLogger.initialize();
  runApp(MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override le buildOverscrollIndicator pour désactiver l'effet "glow"
  // qui est tactile et moins pertinent sur desktop/web.
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Retourne simplement l'enfant, sans l'indicateur
  }

  // Permet le défilement par glisser-déposer sur toutes les plateformes,
  // y compris la souris et le clavier.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // Permet le défilement avec la souris
    // PointerDeviceKind.stylus,
    // PointerDeviceKind.unknown,
  };
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getAllProviders(),
      builder: (context, child) {
        final paramsProvider = Provider.of<ParamsProvider>(context);

        return MaterialApp(
          title: 'WeatherApp',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          supportedLocales: L10n.supportedLocales,
          locale: paramsProvider.locale,
          localizationsDelegates: const [
            LocaleNamesLocalizationsDelegate(),
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              // Vérifier si la locale demandée est supportée
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            // Si la locale n'est pas supportée, utiliser le français
            return const Locale('en');
          },
          scrollBehavior: MyCustomScrollBehavior(),
          home: const Main(),
        );
      },
    );
  }

  List<SingleChildWidget> getAllProviders() {
    return [
      ChangeNotifierProvider(
        create: (context) => WeatherDataProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ParamsProvider(),
      ),
    ];
  }
}

class Main extends StatefulWidget {
  const Main({super.key,});


  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    _loadRefreshKey();
    super.initState();
  }

  _loadRefreshKey() {
    final paramsProvider = Provider.of<ParamsProvider>(context, listen: false);

    paramsProvider.refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }


  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Utils.white,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 6,
        title: Row(
          children: [
            const Expanded(child: PositionView()),
            if(kIsWeb || Utils.checkIfDesktop())
              IconButton(
                  onPressed: () {
                    paramsProvider.refreshIndicatorKey!.currentState!.show();
                  },
                  icon: const Icon(
                      Icons.refresh
                  )
              )
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: Text(
                          AppLocalizations.of(context)!.settingsTitle,
                          style: textStyle['bodyHighlight'],
                        ),
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Settings()),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  LinkButton(
                      urlStr: Env.portfolioLink ?? '',
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        AppLocalizations.of(context)!.credits,
                        style: textStyle['bodyHighlight'],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: const Home(),
    );
  }
}
