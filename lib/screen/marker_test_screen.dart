import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:map_route_test/components/custom_marker.dart';

class Player {
  final int id;
  final double lat;
  final double lng;
  final String imageUrl;
  final String name;

  Player(this.id, this.lat, this.lng, this.imageUrl, this.name);
}

class MarkerTestScreen extends StatefulWidget {
  const MarkerTestScreen({super.key});

  @override
  State<MarkerTestScreen> createState() => _MarkerTestScreenState();
}

class _MarkerTestScreenState extends State<MarkerTestScreen> {
  late GoogleMapController _controller;

  Set<Marker> _markers = Set<Marker>();
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<Uint8List> _captureWidgetAsImage(GlobalKey widgetKey) async {
    try {
      RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception('위젯 렌더링에 실패했습니다. : $e');
    }
  }

  void _loadPlayer() {
    _players.add(Player(
        1, 35.2098, 129.0082, 'https://picsum.photos/id/1/100', 'player A'));
    _players.add(Player(
        2, 35.2117, 129.0096, 'https://picsum.photos/id/2/100', 'player B'));
    _players.add(Player(
        3, 35.2131, 129.0064, 'https://picsum.photos/id/3/100', 'player C'));
    _players.add(Player(
        4, 35.2092, 129.0047, 'https://picsum.photos/id/4/100', 'player D'));
    _players.add(Player(
        5, 35.2075, 129.0079, 'https://picsum.photos/id/5/100', 'player E'));
    _players.add(Player(
        6, 35.2068, 129.0051, 'https://picsum.photos/id/6/100', 'player F'));
    _players.add(Player(
        7, 35.2188, 129.0224, 'https://picsum.photos/id/7/100', 'player G'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(35.2117, 129.0096), // 초기 카메라 위치
              zoom: 15,
            ),
            myLocationEnabled: true, // 현재 위치 표시
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
            zoomControlsEnabled: false,
          ),
          for (Player player in _players)
            Positioned(
              top: -9999,
              left: -9999,
              child: CustomMarker(
                imageUrl: player.imageUrl,
                onRendering: (globalKey) async {
                  Uint8List markerImage =
                      await _captureWidgetAsImage(globalKey);
                  setState(() {
                    _markers.add(Marker(
                        markerId: MarkerId('player${player.id}'),
                        position: LatLng(player.lat, player.lng),
                        icon: BitmapDescriptor.bytes(markerImage)));
                  });
                },
              ),
            ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _players.map((player) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        _controller.animateCamera(CameraUpdate.newLatLng(LatLng(player.lat, player.lng)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomMarker(
                            imageUrl: player.imageUrl,
                            onRendering: (globalKey) async {
                              Uint8List markerImage =
                              await _captureWidgetAsImage(globalKey);
                              setState(() {
                                _markers.add(Marker(
                                    markerId: MarkerId('player${player.id}'),
                                    position: LatLng(player.lat, player.lng),
                                    icon: BitmapDescriptor.bytes(markerImage)));
                              });
                            },
                          ),
                          Text(player.name),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
