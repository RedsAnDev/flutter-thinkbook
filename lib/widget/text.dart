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

Widget textFormFieldText(context,
    {String labelText: "Nome Campo",
    String initialValue: "",
    bool showCursor: true,
    String errorMessage: "L'evento deve avere un titolo",
    Function cb,
    String errorMessageCB}) {
  return TextFormField(
    decoration: InputDecoration(labelText: labelText),
    initialValue: initialValue,
    showCursor: showCursor,
    validator: (String val) {
      if (val == null || val.trim().length == 0) {
        return errorMessage;
      }
      try {
        cb(val);
        return null;
      } catch (e) {
        return errorMessageCB == null ? "$e" : errorMessageCB;
      }
    },
    onEditingComplete: () {
      // DESIGN [@redsandev] non sono proprio sicuro di cosa faccia questa funzione
      // https://stackoverflow.com/a/56946311/5930652
      FocusScope.of(context).unfocus();
    },
    onSaved: (String value) => value,
  );
}

Widget textFormFieldDateTime(context,
    {IconData icon: Icons.calendar_today,
    String labelText: "Data inizio evento",
    DateTime initialValue,
    Function cb}) {
  return TextFormField(
    decoration: InputDecoration(
      icon: Icon(icon),
      labelText: labelText,
      hintText: "dd/mm/yyyy [HH:MM[:SS]]",
    ),
    initialValue: (initialValue == null ? DateTime.now() : initialValue)
        .toLocal()
        .toString()
        .split(".")[0],
    showCursor: true,
    validator: (String val) {
      if (val == null || val.trim().length == 0) {
        return "L'evento deve avere una data di inizio";
      }
      try {
        cb(val);
        return null;
      } catch (e) {
        print(e);
        return "Data non corretta, controlla il formato";
      }
    },
    onEditingComplete: () {
      // DESIGN [@redsandev] non sono proprio sicuro di cosa faccia questa funzione
      // https://stackoverflow.com/a/56946311/5930652
      FocusScope.of(context).unfocus();
    },
    onSaved: (String value) => value,
  );
}
