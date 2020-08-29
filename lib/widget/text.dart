import 'package:flutter/material.dart';

/// Author and own avatars presented by URL
Widget authorBarInRow({String url, String authorName}) {
  return authorBarInRowRAW(
      image: Image.network(url).image, authorName: authorName);
}

/// Author and Avatar builded with imageprovider
Widget authorBarInRowRAW({ImageProvider image, String authorName}) {
  return Row(
    children: [
      Padding(
        padding: EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundImage: image,
        ),
      ),
      Text(authorName)
    ],
  );
}

Widget textBarColorWithIcon(
    {IconData icon: Icons.info_outline,
    String text,
    Color backgroundColor: Colors.white,
    int percentage: 70}) {
  int percentageColor = (2.55 * percentage).ceil().abs();
  return Container(
    color:
        Colors.white.withAlpha(percentageColor > 100 ? 100 : percentageColor),
    child: Row(children: [
      Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
        ),
      ),
      Text(DateTime.now().toIso8601String())
    ]),
  );
}

Widget textBarColor(
    {String text, Color backgroundColor: Colors.white, int percentage: 70}) {
  int percentageColor = (2.55 * percentage).ceil().abs();
  return Container(
      color: backgroundColor
          .withAlpha(percentageColor > 100 ? 100 : percentageColor),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 24,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ));
}
