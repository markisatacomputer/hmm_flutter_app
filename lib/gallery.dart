import 'package:flutter/material.dart';

import 'media.service.dart';


class GalleryMediaViewer extends StatefulWidget {
  const GalleryMediaViewer({ Key key, this.media }) : super(key: key);

  final Media media;

  @override
  _GalleryMediaViewerState createState() => new _GalleryMediaViewerState();
}

class _GalleryMediaViewerState extends State<GalleryMediaViewer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = new Offset(size.width, size.height) * (1.0 - _scale);
    return new Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < 800.0)
      return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = new Tween<Offset>(
        begin: _offset,
        end: _clampOffset(_offset + direction * distance)
    ).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: new ClipRect(
        child: new Transform(
          transform: new Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: new Image.network(
            widget.media.derivative[2]['uri'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class GalleryItem extends StatelessWidget {
  const GalleryItem({
    this.media,
  });

  final Media media;

  void showMedia(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            appBar: new AppBar(
                title: new Text(media.filename)
            ),
            body: new SizedBox.expand(
              child: new Hero(
                tag: media.id,
                child: new GalleryMediaViewer(media: media),
              ),
            ),
          );
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = new GestureDetector(
        onTap: () {
          showMedia(context);
        },
        child: new Hero(
            key: new Key(media.filename),
            tag: media.id,
            child: new Image.network(
              media.derivative[0]['uri'],
              fit: BoxFit.cover,
            )
        )
    );

    return new GridTile(child: image);
  }
}

class Gallery extends StatefulWidget {
  const Gallery({ Key key }) : super(key: key);

  @override
  GalleryState createState() => new GalleryState();
}

class GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    final media = new MediaService();
    var futureMedia = new FutureBuilder(
      future: media.index(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('loading...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return mediaGrid(context, snapshot);
        }
      },
    );


    return new Scaffold(
      body: new Flex(
        direction: Axis.vertical,
          children: [
          new Expanded(
            child: new SafeArea(
                top: false,
                bottom: false,
                child: futureMedia,
            ),
          ),
        ]
      ),
    );
  }

  Widget mediaGrid(BuildContext context, AsyncSnapshot snapshot) {
    List<Media> images = snapshot.data;
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new GridView.count(
        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
        children: images.map((Media media) {
          return new GalleryItem(media: media);
        }).toList(),
    );
  }
}