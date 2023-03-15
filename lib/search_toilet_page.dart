import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:toilenow/toilet.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchToiletPage extends StatefulWidget {
  const SearchToiletPage({Key? key}) : super(key: key);

  @override
  State<SearchToiletPage> createState() => _SearchToiletPageState();
}

class _SearchToiletPageState extends State<SearchToiletPage> {
  final apiKey = 'AIzaSyCvDDjz-_5aEJF58SUgv3QZAdgywpR2tJ4';
  Toilet? toilet;
  Uri? mapURL;
  bool? isExist;

  Future _searchLocation() async {
    final position = await _determinePosition();
    print(position.latitude);
    print(position.longitude);

    final googlePlace = GooglePlace("Your-Key");
    final response = await googlePlace.search.getNearBySearch(
      Location(lat: position.latitude, lng: position.longitude),
      1000,
      language: 'ja',
      keyword: "トイレ",
      rankby: RankBy.Distance,
    );

    final results = response?.results;
    final isExist = results?.isNotEmpty ?? false;
    setState(() {
      this.isExist = isExist;
    });
    if (!isExist) {
      return;
    }
    final firstResult = results?.first;

    if (Platform.isAndroid) {
      // Android-specific code
    } else if (Platform.isIOS) {
      // iOS-specific code
    }

    if (firstResult != null) {
      final photoReference = firstResult.photos?.first.photoReference;
      final String photoURL;
      if (photoReference != null) {
        photoURL =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&+key=$apiKey';
      } else {
        photoURL =
            'https://3.bp.blogspot.com/-V99GyD3-bK8/UnIEQKrp7RI/AAAAAAAAaBM/K1iCkorbGDI/s400/room_toilet.+png';
      }
      // TODO: firstResultから必要な情報を取り出す
      setState(() {
        toilet = Toilet(
          firstResult.name,
          photoURL,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (isExist == false) {
      return const Scaffold(
        body: Center(child: Text('近くにトイレがありません')),
      );
    }
    if (toilet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('一番近くのトイレ'),
      ),
      body: Column(
        children: [
          Image.network(toilet!.photo!),
          SizedBox(
            height: 8,
          ),
          Text(
            toilet!.name!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              if (mapURL != null) {
                await launchUrl(mapURL!);
              }
            },
            child: Text('Google Mapへ'),
          ),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    //
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('設定にて位置情報を許可してください');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('設定にて位置情報を許可してください');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('設定にて位置情報を許可してください');
    }
    return await Geolocator.getCurrentPosition();
  }
}
