import 'package:beacons_plugin_example/add_item_form.dart';
import 'package:beacons_plugin_example/app_bar_title.dart';
import 'package:beacons_plugin_example/custom_colors.dart';

import 'package:flutter/material.dart';


class AddScreen extends StatelessWidget {
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _productnameFocusNode = FocusNode();
  final FocusNode _productpriceFocusNode = FocusNode();
  final FocusNode _subcategoryFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _titleFocusNode.unfocus();
        _productnameFocusNode.unfocus();
        _productpriceFocusNode.unfocus();
        _subcategoryFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: CustomColors.firebaseNavy,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CustomColors.firebaseNavy,
          title: AppBarTitle(),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: AddItemForm(
              titleFocusNode: _titleFocusNode,
              productnameFocusNode: _productnameFocusNode,
              productpriceFocusNode: _productpriceFocusNode,
              subcategoryFocusNode: _subcategoryFocusNode,
            ),
          ),
        ),
      ),
    );
  }
}
