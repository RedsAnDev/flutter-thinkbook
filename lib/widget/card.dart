import 'package:thinkbook/widget/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// TODO after the first build, the position of title and text followed correctly the image. I think is a good choice to use Future.
// TODO maybe is a good choice to show the skeleton after the app has get the media
/// Card Gradient provides a simple way to show data and info, with a content like an image.
class CardGradient extends StatefulWidget {
  CardGradient({Key key}) : super(key: key);

  @override
  _CardGradient createState() => _CardGradient();
}

class _CardGradient extends State<CardGradient> {
  final GlobalKey _keyImage = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Container spaceImage = Container(height: 100);
    setState(() {
      spaceImage = Container(
          height: _keyImage.currentContext == null
              ? 100
              : (_keyImage.currentContext.findRenderObject()
                          as RenderShaderMask)
                      .child
                      .size
                      .height *
                  0.7);
    });

    return Card(
      color: Colors.white,
      child: Stack(
        children: [
          ShaderMask(
            key: _keyImage,
            shaderCallback: (rect) {
              spaceImage = Container(
                  height:
                      _keyImage.currentContext == null ? 0 : rect.height * 0.7);
              print(rect.height);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(rect.width * 0.6, rect.height * 0.6,
                  rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: Image.network(
              "https://googleflutter.com/sample_image.jpg",
              semanticLabel: "Avatar",
              loadingBuilder: (BuildContext context, Widget widget,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null){
                  print(((widget as Semantics).child as RawImage).image.height);
                  return widget;}
                return Center(
                    child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                ));
              },
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                textBarColorWithIcon(icon: Icons.today),
                spaceImage,
                textBarColor(text: "A kind of title to share"),
                authorBarInRow(
                    url: "https://googleflutter.com/sample_image.jpg.",
                    authorName: "Castellitto Angelo"),
                Text(
                  "The Tag class has some optional parameters. If you want to insert an icon, the title is not displayed but you can always use it.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget CardImageDefault() {
  return Card(
    color: Colors.white,
    child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Icon(Icons.bubble_chart),
              Text(
                "Title of journey",
                style: TextStyle(fontSize: 24),
              )
            ]),
            Image.network(
              "https://googleflutter.com/sample_image.jpg.",
              alignment: Alignment.center,
              height: 100,
              cacheHeight: 100,
              repeat: ImageRepeat.noRepeat,
            ),
            Row(
              children: [Text("2020 01 01 20:30")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("B"), Text("B"), Text("B"), Text("B")],
            ),
          ],
        )),
  );
}

Widget CardDefault() {
  return Card(
    color: Colors.white,
    child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Icon(Icons.bubble_chart),
              Text(
                "Title of journey",
                style: TextStyle(fontSize: 24),
              )
            ]),
            Image.network(
              "https://googleflutter.com/sample_image.jpg.",
              alignment: Alignment.center,
              height: 100,
              cacheHeight: 100,
              repeat: ImageRepeat.noRepeat,
            ),
            Row(
              children: [Text("2020 01 01 20:30")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("B"), Text("B"), Text("B"), Text("B")],
            ),
          ],
        )),
  );
}
