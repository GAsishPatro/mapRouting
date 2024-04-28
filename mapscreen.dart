import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List listOfPoints = [];
  List<LatLng> points = [];
   final List<LatLng> dummyCoordinates = [
    const LatLng(19.157428,72.9959931),
    const LatLng(19.18196,72.9893241),
    const LatLng(19.190958,72.9830221)
  ];
  LatLng startPoint = const LatLng(19.157428,72.9959931);
  LatLng endPoint = const LatLng(19.18196,72.9893241);

  getCoordinates() async {
    for (int i = 0; i < dummyCoordinates.length - 1; i++) {

      setState(() {
        startPoint = dummyCoordinates[i];
      endPoint = dummyCoordinates[i + 1];
      });
      
      final url = Uri.parse(
          "https://api.geoapify.com/v1/routing?waypoints=${startPoint.latitude},${startPoint.longitude}|${endPoint.latitude},${endPoint.longitude}&mode=drive&apiKey=your_api_key");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        listOfPoints = resData['features'][0]['geometry']['coordinates'][0];
      }
      setState(() {
        points = listOfPoints
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
      });
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: getCoordinates,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      body: FlutterMap(
        options:
             MapOptions(initialZoom: 15, center: startPoint),
        children: [
          TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'dev.fleaflet.flutter_map.example'),
           MarkerLayer(
            markers: [
              Marker(
                point: startPoint,
                width: 80,
                height: 80,
                child: const Icon(Icons.location_on, color: Colors.green, size: 50),
              ),
              Marker(
                point: endPoint,
                width: 80,
                height: 80,
                child: const Icon(Icons.location_on, color: Colors.red, size: 50),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(points: points, color: Colors.blue, strokeWidth: 5),
            ],
          ),
        ],
      ),
    );
  }
}
