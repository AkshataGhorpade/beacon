import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin_example/models/beaconadsmodel.dart';
import 'package:beacons_plugin_example/res/custom_colors.dart';
import 'package:beacons_plugin_example/widgets/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  // intilizion local notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  //create instance for firebase messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String _beaconResult = 'Not Scanned Yet.';
  int _nrMessagesReceived = 0;
  var isRunning = false;
  List<String> _results = [];
  bool _isInForeground = true;

  final ScrollController _scrollController = ScrollController();

  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();


  void pushFCMtoken() async {
    String token=await messaging.getToken();
    print(token);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initPlatformState();
    pushFCMtoken();
    initMessaging();
    //monitoring beacon status
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

  void initMessaging() {
    var androiInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = IOSInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSetting);
    var androidDetails =
    AndroidNotificationDetails('1', 'channelName', 'channel Description');
    var iosDetails = IOSNotificationDetails();
    var generalNotificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification=message.notification;
      AndroidNotification android=message.notification?.android;
      if(notification!=null && android!=null){
        flutterLocalNotificationsPlugin.show(
            notification.hashCode, notification.title, notification.body, generalNotificationDetails);
      }});}


//monitoring beacon status
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
    //application state
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    //beaconcontroller closed
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
    await BeaconsPlugin.addRegion("Beacon2201", "e2c56db5-dffb-48d2-b060-d0f5a71096e0");
    await BeaconsPlugin.addRegion(
        "Beacon2031", "b9407f30-f5f8-466e-aff9-25556b57fe6d");
    await BeaconsPlugin.addRegion(
        "Beacon2050", "74278bda-b644-4520-8f0c-720eaf059935");
    //Adding beaconlayout
    BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");

    //foreground scan period
    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 220000, foregroundBetweenScanPeriod: 6000);
    //background scan period
    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 220000, backgroundBetweenScanPeriod: 6000);

    beaconEventsController.stream.listen(
            (data) async {
          //    checking the status and data from beacon pluging
          if (data.isNotEmpty && isRunning) {
            setState((){
              _beaconResult = data;
              _results.add(_beaconResult);
              _nrMessagesReceived++;
            });

            //fetching beacon data from api
            if (data!=null) {
              // taking distance from the json
              String distance = jsonDecode(data)['distance'];
              double myDouble = double.parse(distance);
              String strUUID = jsonDecode(data)['uuid'];

              // getting list of beacons data from database
              List<beaconadsmodel> lstData=await Database.getBeacons();
              String ads="";
              String pizzahut="";
              String titleval="";
              //checking list is empty or not
              if(lstData != null && lstData.length != 0){
                for(beaconadsmodel beaconItem in lstData){

                  String strDocUuid=beaconItem.docUUID;
                  if(strUUID==strDocUuid){
                    ads=beaconItem.ads;
                    pizzahut=beaconItem.pizzahut;
                    titleval= ads +""+pizzahut;
                    break;
                  }
                }

              }
              //display the notification from database
              new NotificationAlert().showNotification(titleval);

            }
            // if application not in foreground we displaying below notification
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
  //UI
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

  //list of data
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
