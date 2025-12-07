// ignore_for_file: equal_keys_in_map

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SymptomController extends GetxController {
  final RxList<String> allSymptoms = <String>[].obs;
  final RxList<String> selectedSymptoms = <String>[].obs;

  // Common symptom synonyms mapping
  final Map<String, List<String>> symptomSynonyms = {
    'chest_pain': [
      'heart pain',
      'chest discomfort',
      'tight chest',
      'chest pressure',
      'heartache'
    ],
    'headache': ['head pain', 'migraine', 'head ache', 'cephalalgia'],
    'fever': ['high temperature', 'pyrexia', 'temperature', 'hot body'],
    'fatigue': ['tiredness', 'exhaustion', 'weakness', 'lethargy'],
    'cough': ['coughing', 'hacking', 'dry cough', 'wet cough'],
    'shortness_of_breath': [
      'breathlessness',
      'difficulty breathing',
      'can\'t breathe',
      'wheezing'
    ],
    'nausea': ['sick feeling', 'queasy', 'upset stomach', 'feeling vomit'],
    'vomiting': ['throwing up', 'puking', 'emesis'],
    'diarrhoea': [
      'loose motions',
      'watery stool',
      'runny stool',
      'loose bowels'
    ],
    'dizziness': ['lightheadedness', 'vertigo', 'spinning', 'unsteady'],
    'abdominal_pain': [
      'stomach pain',
      'belly pain',
      'stomach ache',
      'tummy ache'
    ],
    'muscle_pain': ['body pain', 'muscle ache', 'body ache', 'sore muscles'],
    'joint_pain': ['joint ache', 'arthralgia', 'painful joints'],
    'chest_pain': ['heart pain', 'angina', 'cardiac pain'],
  };

  @override
  void onInit() {
    super.onInit();
    loadSymptoms();
  }

  Future<void> loadSymptoms() async {
    try {
      String data = await rootBundle.loadString("assets/symptoms.json");
      List<dynamic> list = jsonDecode(data);
      allSymptoms.value = list.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint("Error loading symptoms: $e");
      // Fallback to common symptoms if JSON fails
      allSymptoms.value = [
        'itching',
        'skin_rash',
        'continuous_sneezing',
        'shivering',
        'chills',
        'fever',
        'headache',
        'cough',
        'fatigue',
        'nausea',
        'vomiting',
        'chest_pain',
        'abdominal_pain',
        'diarrhoea',
        'breathlessness',
        'muscle_pain',
        'joint_pain',
        'dizziness',
        'weight_loss',
        'sweating'
      ];
    }
  }

  void addSymptom(String value) {
    if (value.trim().isEmpty) return;

    // Clean the symptom (remove "similar to" text if present)
    String cleanSymptom = value;
    if (value.contains('(similar to')) {
      cleanSymptom = value.split(' (')[0].trim();
    }

    // Convert to backend format
    final formatted = cleanSymptom.toLowerCase().replaceAll(' ', '_');

    if (!selectedSymptoms.contains(formatted)) {
      selectedSymptoms.add(formatted);
    }
  }

  void removeSymptom(String value) {
    selectedSymptoms.remove(value);
  }

  void clearAllSymptoms() {
    selectedSymptoms.clear();
  }

  List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final results = <String>{};

    // 1. Check for exact matches in all symptoms
    for (var symptom in allSymptoms) {
      if (symptom.toLowerCase().contains(lowerQuery.replaceAll(' ', '_'))) {
        results.add(symptom);
      }
    }

    // 2. Check synonyms
    for (var entry in symptomSynonyms.entries) {
      final mainSymptom = entry.key;
      final synonyms = entry.value;

      // Check if query matches any synonym
      for (var synonym in synonyms) {
        if (synonym.toLowerCase().contains(lowerQuery) &&
            allSymptoms.contains(mainSymptom)) {
          results.add('$mainSymptom (similar to "$query")');
          break; // Add only once per main symptom
        }
      }
    }

    // 3. Check if query matches main symptom names (without underscores)
    for (var symptom in allSymptoms) {
      final readableName = symptom.replaceAll('_', ' ');
      if (readableName.toLowerCase().contains(lowerQuery)) {
        results.add(symptom);
      }
    }

    // 4. Fuzzy matching for close matches
    if (results.length < 8) {
      for (var symptom in allSymptoms) {
        final readableName = symptom.replaceAll('_', ' ');
        if (_isSimilar(readableName.toLowerCase(), lowerQuery) &&
            !results.contains(symptom)) {
          results.add(symptom);
        }
      }
    }

    return results.take(8).toList();
  }

  bool _isSimilar(String symptom, String query) {
    if (symptom.isEmpty || query.isEmpty) return false;

    // Simple similarity checks
    if (symptom.contains(query) || query.contains(symptom)) return true;

    // Check for word overlaps
    final symptomWords = symptom.split(' ');
    final queryWords = query.split(' ');

    for (var sWord in symptomWords) {
      for (var qWord in queryWords) {
        if (sWord.length > 2 && qWord.length > 2) {
          // Check first 3 characters
          if (sWord.startsWith(qWord.substring(0, min(3, qWord.length))) ||
              qWord.startsWith(sWord.substring(0, min(3, sWord.length)))) {
            return true;
          }
        }
      }
    }

    return false;
  }

  int min(int a, int b) => a < b ? a : b;
}
