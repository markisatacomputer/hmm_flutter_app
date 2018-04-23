import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Media {
  final String id;
  final String filename;
  final int createDate;
  final int uploadDate;
  final dynamic derivative;
  final String mimeType;

  Media({
    this.id,
    this.filename,
    this.createDate,
    this.uploadDate,
    this.derivative,
    this.mimeType
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return new Media(
      id: json['_id'],
      filename: json['filename'],
      createDate: json['createDate'],
      uploadDate: json['uploadDate'],
      mimeType: json['mimeType'],
      derivative: json['derivative'],
    );
  }
}

class MediaService {
  final baseUrl = 'api.homemademess.com';
  final _client = new http.Client();

  Future<List<Media>> _parseMedia(http.Response res) async {
    final jayson = json.decode(res.body);
    List<Media> media = new List();

    for (var i in jayson['images']) {
      media.add(new Media.fromJson(i));
    }

    return media;
  }

  Future<List<Media>> index() async {
    print('Retrieving media...');
    final uri = new Uri.https(baseUrl, '/images');
    final res = await _client.get(
      uri,
      headers: {
        'accept': 'application/json',
        'origin': 'https://homemademess.com',
        'Authentication': 'Bearer ',
      }
    );

    return _parseMedia(res);
  }
}