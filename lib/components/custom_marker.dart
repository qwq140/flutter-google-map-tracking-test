import 'package:flutter/material.dart';

class CustomMarker extends StatefulWidget {
  final String imageUrl;
  final Function(GlobalKey globalKey) onRendering;

  const CustomMarker({super.key, required this.imageUrl, required this.onRendering});

  @override
  State<CustomMarker> createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker> {
  final GlobalKey _globalKey = GlobalKey();
  bool _hasRendered = false; // 이미지가 로드되었는지 체크하는 플래그

  @override
  void initState() {
    super.initState();
    _loadNetworkImage();
  }
  
  void _loadNetworkImage() {
    print('_loadNetworkImage ${_hasRendered} ${widget.imageUrl}');
    final ImageStream stream = NetworkImage(widget.imageUrl).resolve(ImageConfiguration());
    stream.addListener(ImageStreamListener((image, synchronousCall) {
      print("_loadNetworkImage call back : ${widget.imageUrl}");
      // if(!_hasRendered) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _hasRendered = true;
          widget.onRendering(_globalKey);
        });
      // }
    }, onError: (exception, stackTrace) {
      print('_loadNetworkImage error : ${widget.imageUrl}');
      print('$exception');
    }, onChunk: (event) {
      print('_loadNetworkImage onChunk : ${widget.imageUrl}');
    },));
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent, width: 4)),
        child: ClipOval(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
