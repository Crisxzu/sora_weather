import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/home/home.dart';
import 'package:weather_app/view/home/widgets/position.dart';


Future main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getAllProviders(),
      child: MaterialApp(
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
        home: const Main(),
      ),
    );
  }

  List<SingleChildWidget> getAllProviders() {
    return [
      ChangeNotifierProvider(
        create: (context) => WeatherDataProvider(),
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
  Widget build(BuildContext context) {



    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Utils.white,
        elevation: 0,
        title: const PositionView(),
      ),
      drawer: Drawer(),
      body: Home(),
    );
  }
}
