import 'package:beacons_plugin_example/models/beaconadsmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _beaconCollection = _firestore.collection('beacon');

class Database {
  static String userUid;

  static Future<List<beaconadsmodel>> getBeacons() async {
    List<beaconadsmodel> lstdata=new List<beaconadsmodel>();
    QuerySnapshot querySnap = await FirebaseFirestore.instance.collection('beacon').get();
    final List<DocumentSnapshot> documentsval = querySnap.docs;
      if(documentsval != null && documentsval.length != 0){
      for (var beaconval in documentsval) {
        String ads = beaconval.data()["ads"];
        String pizzahut = beaconval.data()["pizzahut"];
        beaconadsmodel nn=new beaconadsmodel();
        nn.ads=ads;
        nn.pizzahut=pizzahut;
        lstdata.add(nn);
      }
    }
    return lstdata;
  }

}
