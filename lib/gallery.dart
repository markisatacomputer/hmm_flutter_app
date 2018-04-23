import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  const Gallery({ Key key }) : super(key: key);

  @override
  GalleryState createState() => new GalleryState();
}

class GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Image.network('https://media.giphy.com/media/dJSX0GZYj6i6rexvUA/giphy.gif'),
    );
  }
}