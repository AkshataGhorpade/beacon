import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin_example/models/beaconadsmodel.dart';
import 'package:beacons_plugin_example/res/custom_colors.dart';
import 'package:beacons_plugin_example/widgets/notification.dart';
import 'package:intl/intl.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Dashboard());
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();

  String _beaconResult = 'Not Scanned Yet.';
  int _nrMessagesReceived = 0;
  var isRunning = false;
  List<String> _results = [];
  bool _isInForeground = true;

  final ScrollController _scrollController = ScrollController();

  final StreamController<String> beaconEventsController =
  StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initPlatformState();
    scan();
    // initialise the plugin.
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =
    IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
  }

  Future<void> scan() async {
    if (isRunning) {
      await BeaconsPlugin.stopMonitoring();
    } else {
      initPlatformState();
      await BeaconsPlugin.startMonitoring();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    beaconEventsController.close();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

//Location Permission
  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Need Location Permission",
          message: "This app collects location data to work with beacons.");

    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);
    //Adding region
    await BeaconsPlugin.addRegion(
        "BeaconType1", "e2c56db5-dffb-48d2-b060-d0f5a71096e0");


    //Adding beaconlayout
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");


    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 220000, foregroundBetweenScanPeriod: 60);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 220000, backgroundBetweenScanPeriod: 60);

    beaconEventsController.stream.listen(
            (data) async {
          if (data.isNotEmpty && isRunning) {
            setState(() {
              _beaconResult = data;
              _results.add(_beaconResult);
              _nrMessagesReceived++;
            });

            //fetching beacon data from api
            if (data!=null) {
              String distance = jsonDecode(data)['distance'];
              double myDouble = double.parse(distance);

              // notification
              List<beaconadsmodel> lstData=await Database.getBeacons();
              String ads="";
              String pizzahut="";
              String titleval="";

              if(lstData != null && lstData.length != 0){
                ads=lstData[0].ads;
                pizzahut=lstData[0].pizzahut;
                titleval= ads +""+pizzahut;
              }

              if( myDouble >= 0){
              new NotificationAlert().showNotification(titleval);

              } if(0> myDouble && myDouble >= 2){
                new NotificationAlert().showNotification(titleval);

              }else if(2 > myDouble && myDouble >= 5){
                new NotificationAlert().showNotification(titleval);
              }
            }

            if (!_isInForeground) {
              new NotificationAlert().showNotification("Beacons DataReceived: " +  data);
            }

            print("Beacons DataReceived: " + data);
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          new NotificationAlert().showNotification("Beacons monitoring started..");
          await BeaconsPlugin.startMonitoring();
          setState(() {
            isRunning = true;
          });
        }
      });
    } else if (Platform.isIOS) {
      new NotificationAlert().showNotification("Beacons monitoring started..");
      await BeaconsPlugin.startMonitoring();
      setState(() {
        isRunning = true;
      });
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: CustomColors.firebaseNavy,
        appBar: AppBar(
          title: const Text('Beacons'),
          backgroundColor: CustomColors.firebaseOrange,
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Expanded(child: _buildResultsList()),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildResultsList() {
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: ListView.separated(
        shrinkWrap: true,
        reverse: true,
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        controller: _scrollController,
        itemCount: _results.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1,
          color: Colors.white,
        ),
        itemBuilder: (context, index) {
          DateTime now = DateTime.now();
          String formattedDate =
          DateFormat('yyyy-MM-dd – kk:mm:ss.SSS').format(now);
          final item = ListTile(
              title: Text(
                "Time: $formattedDate\n${_results[index]}",
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.headline4?.copyWith(
                  fontSize: 14,
                  color: CustomColors.firebaseYellow,
                  fontWeight: FontWeight.normal,
                ),
              ),
              onTap: () {});
          return item;
        },
      ),
    );
  }
}
