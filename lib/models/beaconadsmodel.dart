class beaconadsmodel {
  String ads;
  String pizzahut;
  String docUUID;


  beaconadsmodel({this.ads, this.pizzahut,this.docUUID});

  beaconadsmodel.fromJson(Map<String, dynamic> parsedJSON)
      : ads = parsedJSON['ads'],
        pizzahut = parsedJSON['pizzahut'],
        docUUID = parsedJSON['uuid'];

}