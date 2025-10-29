import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:manuscan/services/api_urls.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ScriptAndUploadResult {
  final DefectScriptResult scriptResult;
  final String? imagePath;

  ScriptAndUploadResult({required this.scriptResult, this.imagePath});
}

class DefectDetectionService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return ApiUrls.defectDetectionBaseAndroid;
    } else if (Platform.isIOS) {
      return ApiUrls.defectDetectionBaseIOS;
    } else {
      return ApiUrls.defectDetectionBaseWeb;
    }
  }

  static String get nodeServerUrl {
    return ApiUrls.palletDispatchBase; // Adjust as needed
  }
  static Future<DefectScriptResult> runDefectDetectionScript() async {
    try {
      final url = baseUrl + ApiUrls.runDefectDetection;
      print('Connecting to: $url');
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var jsonData = json.decode(response.body);

      print('Parsed JSON: $jsonData');
      print('Script output field: ${jsonData['data']?['output']}');

      if (response.statusCode == 200) {
        return DefectScriptResult.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to run script: ${jsonData['detail'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Error running defect detection script: $e');
    }
  }

  static Future<ScriptAndUploadResult> runScriptAndUploadImage(
      XFile imageFile, String palletId) async {
    // <-- ADD palletId
    try {
      final results = await Future.wait([
        runDefectDetectionScript(),
        // Pass palletId to the helper function
        _uploadImageToNode(imageFile, palletId), // <-- PASS palletId
      ]);

      final scriptResult = results[0] as DefectScriptResult;
      final imagePath = results[1] as String?;

      return ScriptAndUploadResult(
        scriptResult: scriptResult,
        imagePath: imagePath,
      );
    } catch (e) {
      print('Error in runScriptAndUploadImage: $e');
      rethrow;
    }
  }

  // --- MODIFIED: Accept palletId and add it to the request ---
  static Future<String?> _uploadImageToNode(
      XFile imageFile, String palletId) async {
    // <-- ADD palletId
    try {
      var nodeUri = Uri.parse('$nodeServerUrl/api/upload-image');
      var nodeRequest = http.MultipartRequest('POST', nodeUri);

      // Add the palletId as a field to the request
      nodeRequest.fields['palletId'] = palletId; // <-- ADD THIS LINE

      final mimeType = lookupMimeType(imageFile.path);

      nodeRequest.files.add(
        http.MultipartFile(
          'Image',
          imageFile.readAsBytes().asStream(),
          await imageFile.length(),
          filename: imageFile.name,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      var nodeResponse = await nodeRequest.send();
      final responseBody = await nodeResponse.stream.bytesToString();

      if (nodeResponse.statusCode == 201) {
        final jsonData = json.decode(responseBody);
        final filePath = jsonData['filePath'];
        print('Successfully uploaded to Node.js. Path: $filePath');
        return filePath;
      } else {
        print('Failed to upload image to Node.js: ${nodeResponse.statusCode}');
        print('Server response: $responseBody');
        throw Exception('Node.js upload failed');
      }
    } catch (e) {
      print('Error during Node.js upload: $e');
      return null;
    }
  }
   /// Check if the defect detection service is available
  static Future<bool> isServiceAvailable() async {
    try {
      final url = baseUrl + ApiUrls.health;
      print('Checking service availability at: $url');
      var response = await http.get(Uri.parse(url));
      print('Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}

class DefectScriptResult {
  final bool success;
  final String output;
  final double timestamp;

  DefectScriptResult({
    required this.success,
    required this.output,
    required this.timestamp,
  });

  factory DefectScriptResult.fromJson(Map<String, dynamic> json) {
    return DefectScriptResult(
      success: json['success'] ?? false,
      output: json['data']?['output'] ?? '',
      timestamp: json['timestamp']?.toDouble() ?? 0.0,
    );
  }
}

class DefectAnalysisResult {
  final String decision;
  final String analysis;
  final String imageUrl;
  final String? nodeJsImagePath; // <-- ADD THIS LINE

  DefectAnalysisResult({
    required this.decision,
    required this.analysis,
    required this.imageUrl,
    this.nodeJsImagePath, // <-- ADD THIS LINE
  });

  factory DefectAnalysisResult.fromJson(Map<String, dynamic> json,
      {String? nodePath}) {
    return DefectAnalysisResult(
      decision: json['decision'] ?? 'UNDETERMINED',
      analysis: json['analysis'] ?? '',
      imageUrl: json['image_url'] ?? '',
      nodeJsImagePath: nodePath, // <-- ADD THIS LINE
    );
  }

  bool get hasDefect => decision == 'DEFECT';
  bool get isNoDefect => decision == 'NO DEFECT';
}
