class beaconadsmodel {
  String ads;
  String pizzahut;


  beaconadsmodel({this.ads, this.pizzahut});

  beaconadsmodel.fromJson(Map<String, dynamic> parsedJSON)
      : ads = parsedJSON['ads'],
        pizzahut = parsedJSON['pizzahut'];

}