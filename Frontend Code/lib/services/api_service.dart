import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/prediction_response.dart';

class ApiService {
  // Use your Render URL (HTTPS)
  static const String baseUrl = "https://health-api-n1ns.onrender.com";

  // Timeout in seconds
  static const int timeoutSeconds = 12;

  static Future<PredictionResponse?> predictDisease(
      List<String> symptoms) async {
    final url = Uri.parse("$baseUrl/predict");

    try {
      // Convert symptoms to backend format (lowercase with underscores)
      final formattedSymptoms = symptoms.map((s) {
        return s.toLowerCase().replaceAll(' ', '_');
      }).toList();

      final body = jsonEncode({"symptoms": formattedSymptoms});

      if (kDebugMode) {
        debugPrint("Sending symptoms to API: $formattedSymptoms");
      }

      final response = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: timeoutSeconds));

      if (kDebugMode) {
        debugPrint("API RESPONSE STATUS: ${response.statusCode}");
        debugPrint("API RESPONSE BODY: ${response.body}");
      }

      if (response.statusCode == 200) {
        return PredictionResponse.fromJson(jsonDecode(response.body));
      } else {
        // Try parsing error message if returned as JSON
        try {
          final m = jsonDecode(response.body);
          debugPrint("API error: $m");
        } catch (_) {
          debugPrint("API returned status ${response.statusCode}");
        }
        return null;
      }
    } catch (e) {
      debugPrint("Network/API exception: $e");
      return null;
    }
  }
}
