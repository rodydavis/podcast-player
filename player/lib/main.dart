import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/controllers/podcast.dart';
import 'ui/home/screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = PodcastController();

  @override
  void initState() {
    _controller.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PodcastController>.value(value: _controller),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Creative Engineering',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData.dark().copyWith(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
