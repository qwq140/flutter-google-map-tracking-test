import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_route_test/components/custom_marker.dart';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  Location _location = Location();
  late User _me;
  Map<String, Marker> _userMarkers = {};
  Map<String, BitmapDescriptor> _customMarkerIcons = {};

  List<User> _otherUsers = [];

  int _callCount = 0;

  @override
  void initState() {
    super.initState();
    _getMyUserInfo();
    _getOtherUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationTracking();
    });
  }

  void _getOtherUsers() {
    _otherUsers.add(User(
        id: 2,
        name: 'User2',
        imageUrl: '이미지 url',
        latitude: 35.1994,
        longitude: 129.0055));
    _otherUsers.add(User(
        id: 3,
        name: 'User3',
        imageUrl: '이미지 url',
        latitude: 35.2035,
        longitude: 129.0039));
    _otherUsers.add(User(
        id: 4,
        name: 'User4',
        imageUrl: '이미지 url',
        latitude: 35.2053,
        longitude: 129.0043));
    _otherUsers.add(User(
        id: 5,
        name: 'User5',
        imageUrl: '이미지 url',
        latitude: 35.2070,
        longitude: 129.0048));
    _otherUsers.add(User(
        id: 6,
        name: 'User6',
        imageUrl: '이미지 url',
        latitude: 35.2100,
        longitude: 129.0055));
  }

  void _getMyUserInfo() {
    _me = User(
        id: 1,
        name: 'Me',
        imageUrl: '이미지 url',
        latitude: 35.2115,
        longitude: 129.0045);
    _buildCustomMarker(_me);
  }

  void _initializeLocationTracking() async {
    _location.onLocationChanged
        .listen((LocationData currentLocation) {
      setState(() {
        print("latitude : ${currentLocation.latitude}");
        print("longitude : ${currentLocation.longitude}");
        _callCount = _callCount + 1;
        _userMarkers.clear();
        _me = _me.copyWith(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude);
        _updateUserMarker(_me);
        for (var otherUser in _otherUsers) {
          var distance = _calculateDistance(
              currentLocation.latitude!,
              currentLocation.longitude!,
              otherUser.latitude,
              otherUser.longitude);
          if (distance <= 1000) {
            print("거리 내부 : ${otherUser.id}");
            _updateUserMarker(otherUser);
          }
        }
      });
    });
  }

  // 사용자 위치에 마커 업데이트
  void _updateUserMarker(User user) {
    final icon = _customMarkerIcons[user.id.toString()];
    print('icon user ${user.id}: $icon');
    if (icon == null) return; // 아이콘이 없으면 무시

    final position = LatLng(user.latitude, user.longitude);

    final newMarker = Marker(
      markerId: MarkerId(user.id.toString()),
      position: position,
      icon: icon,
    );

    _userMarkers[user.id.toString()] = newMarker;
  }

  // 캡처한 CustomMarker를 비트맵으로 변환하는 함수
  Future<BitmapDescriptor> _captureMarkerImage(
      GlobalKey globalKey, User user) async {
    // 캡처 로직 구현
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      throw Exception('위젯 렌더링에 실패했습니다. ${user.id} : $e');
    }
  }

  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  Widget _buildCustomMarker(User user) {
    print('_build ${user.id}');
    // if(_customMarkerIcons.containsKey(user.id.toString())) {
    //   return const SizedBox.shrink();
    // }

    return CustomMarker(
      imageUrl: user.imageUrl,
      onRendering: (globalKey) async {
        print('user ${user.id} onRendering');
        final icon = await _captureMarkerImage(globalKey, user);
        print('onRendering $icon');
        setState(() {
          _customMarkerIcons[user.id.toString()] = icon;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_me.latitude, _me.longitude), zoom: 15),
            markers: Set<Marker>.of(_userMarkers.values),
            onMapCreated: (controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('call count : $_callCount'),
                  Text('latitude : ${_me.latitude}'),
                  Text('longitude : ${_me.longitude}'),
                ],
              ),
            ),
          ),
          // CustomMarker 추가 (예를 들어, 미리 렌더링된 위젯으로 보여줌)
          // Positioned(
          //   top: -9999,
          //   left: -9999,
          //   child: _buildCustomMarker(_me),
          // ),
          // for (var otherUser in _otherUsers)
          //   Positioned(
          //     top: -9999,
          //     left: -9999,
          //     child: _buildCustomMarker(otherUser),
          //   ),
          Positioned(
            top: 0,
            left: 0,
            child: Column(
              children: [
                _buildCustomMarker(_me),
                for(var otherUser in _otherUsers)
                  _buildCustomMarker(otherUser),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String imageUrl;
  final double latitude;
  final double longitude;

  User({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  // copyWith 메서드
  User copyWith({
    int? id,
    String? name,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
