import 'dart:convert';

import 'dart:html';

class GenerateImageUrl {
  late bool success;
  late String message;

  late bool isGenerated;
  late String uploadUrl;
  late String downloadUrl;

  get http => null;

  Future<void> call(String fileType) async {
    try {
      Map body = {"fileType": fileType};

      var response = await http.post(
        'http://${Platform.supportsSimd ? 'localhost' : '10.0.2.2'}:5000/generatePresignedUrl',
        body: body,
      );

      var result = jsonDecode(response.body);

      if (result['success'] != null) {
        success = result['success'];
        message = result['message'];

        if (response.statusCode == 201) {
          isGenerated = true;
          uploadUrl = result["uploadUrl"];
          downloadUrl = result["downloadUrl"];
        }
      }
    } catch (e) {
      throw ('Error getting url');
    }
  }
}