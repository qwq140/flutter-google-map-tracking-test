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
    final ImageStream stream = NetworkImage(widget.imageUrl).resolve(ImageConfiguration());
    stream.addListener(ImageStreamListener((image, synchronousCall) {
      if(!_hasRendered) {
        _hasRendered = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onRendering(_globalKey);
        });
      }
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
            // loadingBuilder: (context, child, loadingProgress) {
            //   print("로딩 프로그래스 : $loadingProgress");
            //   if(loadingProgress != null) {
            //     return Center(
            //       child: CircularProgressIndicator(),
            //     );
            //   }
            //   if(loadingProgress == null && !_hasRendered) {
            //     _hasRendered = true;
            //     WidgetsBinding.instance.addPostFrameCallback((_) {
            //       widget.onRendering(_globalKey);
            //     });
            //   }
            //   print("이미지 로드가 완료되었습니다.");
            //   return child;
            // },
          ),
        ),
      ),
    );
  }
}
