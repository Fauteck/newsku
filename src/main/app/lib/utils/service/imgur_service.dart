import 'dart:convert';

import 'package:app/utils/models/imgur_error.dart';
import 'package:http/http.dart' as http;

const urlImgurScreenshotUpload = 'https://api.imgur.com/3/image';

const imgurClientId = 'Client-ID 2cfbc27ce77879d';

class ImgurService {
  Future<String> uploadImageToImgur(String base64Image) async {
    Uri uri = Uri.parse(urlImgurScreenshotUpload);
    final headers = {'Authorization': imgurClientId};

    final data = <String, String>{'image': base64Image};

    final response = await http.post(uri, headers: headers, body: data);
    if (response.statusCode != 200) {
      throw ImgurError("Non 200 response from Imgur (${response.statusCode})");
    } else {
      var body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> decoded = jsonDecode(body);

      if (decoded.containsKey('data')) {
        final Map<String, dynamic> data = decoded['data'];

        if (data.containsKey('link')) {
          return data['link'].toString();
        } else {
          throw ImgurError("Response does not contain 'link' key");
        }
      } else {
        throw ImgurError("Response does not contain 'data' key");
      }
    }
  }
}
