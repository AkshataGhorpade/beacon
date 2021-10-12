import 'package:beacons_plugin_example/Beaconmodel.dart';
import 'package:beacons_plugin_example/beaconadsmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('category');
final CollectionReference _beaconCollection = _firestore.collection('beacon');

class Database {
  static String userUid;


  static Future<List<beaconadsmodel>> getBeacons() async {
    List<beaconadsmodel> lstdata=new List<beaconadsmodel>();
    QuerySnapshot querySnap = await FirebaseFirestore.instance.collection('beacon').get();
    final List<DocumentSnapshot> documentsval = querySnap.docs;
      if(documentsval != null && documentsval.length != 0){
      for (var privilegeval in documentsval) {
        String ads = privilegeval.data()["ads"];
        String pizzahut = privilegeval.data()["pizzahut"];
        beaconadsmodel nn=new beaconadsmodel();
        nn.ads=ads;
        nn.pizzahut=pizzahut;
        lstdata.add(nn);
      }
    }

    return lstdata;
  }

}
