class Beaconmodel {
  String title;
  String productname;
  String productprice;
  String subcategory;

  Beaconmodel({this.title, this.subcategory,this.productprice,this.productname});

  Beaconmodel.fromJson(Map<String, dynamic> parsedJSON)
      : title = parsedJSON['title'],
        productname = parsedJSON['productname'],
        productprice = parsedJSON['productprice'],
        subcategory = parsedJSON['subcategory'];
}

