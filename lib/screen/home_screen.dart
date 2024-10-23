import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  Location _location = Location();
  bool _tracking = false; // 경로 추적 상태
  List<LatLng> _route = []; // 경로를 저장할 리스트
  Set<Polyline> _polylines = {}; // 지도에 표시할 Polyline

  @override
  void initState() {
    super.initState();
  }

  // 경로 추적 시작
  void _startTracking() {
    _route.clear(); // 이전 경로 초기화
    _polylines.clear(); // 지도에서 경로 초기화
    setState(() {
      _tracking = true; // 추적 상태로 변경
    });

    // 위치 추적 시작
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_tracking) {
        setState(() {
          print("latitude : " + currentLocation.latitude!.toString());
          print("longitude : " + currentLocation.longitude!.toString());
          LatLng position =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _route.add(position); // 새로운 좌표 추가
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            points: _route,
            color: Colors.blue,
            width: 5,
          ));
          _controller
              ?.animateCamera(CameraUpdate.newLatLng(position)); // 카메라 위치 이동
        });
      }
    });
  }

  // 경로 추적 중지
  void _stopTracking() {
    setState(() {
      _tracking = false; // 추적 중지 상태로 변경
    });
  }

  void _tempShow() {
    setState(() {
      _route.clear();
      _route.add(LatLng(35.2130, 129.0074));
      _route.add(LatLng(35.2129, 129.0071));
      _route.add(LatLng(35.2128, 129.0069));
      _route.add(LatLng(35.2128, 129.0066));
      _route.add(LatLng(35.2127, 129.0063));
      _route.add(LatLng(35.2126, 129.0061));
      _route.add(LatLng(35.2125, 129.0062));
      _route.add(LatLng(35.2122, 129.0063));
      _route.add(LatLng(35.2122, 129.0064));
      _polylines.add(Polyline(
          polylineId: PolylineId("temp"),
          points: _route,
          color: Colors.blue,
          width: 5
      ));
      _controller?.animateCamera(CameraUpdate.newLatLng(LatLng(35.2122, 129.0064)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("맵 루트 표시 테스트"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(35.1691, 129.0874), // 초기 카메라 위치
                zoom: 17,
              ),
              myLocationEnabled: true, // 현재 위치 표시
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              polylines: _polylines, // 경로를 지도에 표시
            ),
            // child: Container(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _tracking ? _stopTracking : _startTracking,
                child: Text(_tracking ? '중지' : '시작'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _tracking ? null : _tempShow,
                child: Text('임의의 좌표로 경로 그리기'),
              ),
              SizedBox(height: 12),
            ],
          )
        ],
      ),
    );
  }
}
