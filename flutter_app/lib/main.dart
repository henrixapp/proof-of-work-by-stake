import 'dart:convert';
import 'dart:io';
import 'package:duration/duration.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/chain_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:staking_lib/staking_lib.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(BlocProvider(
      create: (context) {
        var bl = ChainBloc();
        bl.add(ChainLoad());
        bl.add(ChainRequest());
        return bl;
      },
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoW by POS Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "PoW by PoS"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: BlocBuilder<ChainBloc, ChainState>(
        builder: (context, state) {
          var amount = state.amount;

          final style = Theme.of(context).textTheme.headlineLarge;
          final style3 = Theme.of(context).textTheme.caption;
          if (state is ChainTimeRunning) {
            return Column(
              children: [
                Text("You have announced to work on project", style: style3),
                Text(state.to, style: style),
                Text("since", style: style3),
                Timeago(
                  date: state.since,
                  builder: (_, value) => Text(value, style: style),
                  allowFromNow: true,
                  refreshRate: Duration(seconds: 10),
                ),
                TextButton.icon(
                    onPressed: () {
                      BlocProvider.of<ChainBloc>(context).add(ChainSend(
                          DateTime.now().difference(state.since).inSeconds,
                          state.to));
                    },
                    icon: Icon(Icons.send),
                    label: Text(
                      "CheckIn Time",
                      style: style,
                    )),
                TextButton.icon(
                    onPressed: () {
                      BlocProvider.of<ChainBloc>(context).add(ChainAbort());
                    },
                    icon: Icon(Icons.cancel),
                    label: Text(
                      "Abort",
                      style: style,
                    )),
              ],
            );
          }
          return Column(children: [
            Text("Amount left ${prettyDuration(Duration(seconds: amount))}"),
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.pubkey));
                },
                child: Text("Copy own pubkey to clipboard")),
            TextButton.icon(
                onPressed: () {
                  BlocProvider.of<ChainBloc>(context).add(ChainRequest());
                },
                icon: Icon(Icons.abc),
                label: Text("Request an update")),
            Text("Start by scanning a project pubkey."),
            MobileScanner(
                allowDuplicates: false,
                onDetect: (barcode, args) {
                  if (barcode.rawValue == null) {
                    debugPrint('Failed to scan Barcode');
                  } else {
                    final String code = barcode.rawValue!;
                    debugPrint('Barcode found! $code');
                    BlocProvider.of<ChainBloc>(context)
                        .add(ChainAnnounced(DateTime.now(), code));
                  }
                }),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<ChainBloc>(context).add(ChainLoad());
          BlocProvider.of<ChainBloc>(context).add(ChainRequest());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.replay_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
