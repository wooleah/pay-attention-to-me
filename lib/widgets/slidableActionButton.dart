import 'package:flutter/material.dart';

import '../constants.dart' as Constants;

class SlidableActionButton extends StatelessWidget {
  final Function onTap;
  final Color color;
  final IconData icon;
  final EdgeInsets margin;

  const SlidableActionButton(
      {Key key, this.onTap, this.color, this.icon, this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        onTap(context),
      },
      child: Container(
        height: double.infinity,
        margin: margin ?? EdgeInsets.only(top: 6, right: 6),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
