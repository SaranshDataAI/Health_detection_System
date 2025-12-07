import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  final RxString currentLanguage = 'en'.obs;

  final Map<String, Map<String, String>> translations = {
    'en': {
      'empty': 'Empty', // ADDED THIS
      'title': 'AI Health Assistant',
      'subtitle': 'Your personal health helper',
      'start_diagnosis': 'Start Diagnosis',
      'enter_symptoms': 'Enter Your Symptoms',
      'type_symptom': 'Type symptom (e.g., chest pain)',
      'add_symptom': 'Add Symptom',
      'predict': 'Predict Disease',
      'analyzing': 'Analyzing symptoms...',
      'result_title': 'Your Health Report',
      'description': 'Description',
      'precautions': 'Precautions',
      'alternate': 'Alternate Diagnoses',
      'confidence': 'Confidence',
      'questions': 'Follow-up Questions',
      'serious': 'Serious',
      'critical': 'Critical',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
    },
    'hi': {
      'empty': 'खाली', // ADDED THIS
      'title': 'एआई स्वास्थ्य सहायक',
      'subtitle': 'आपकी व्यक्तिगत स्वास्थ्य सहायक',
      'start_diagnosis': 'निदान शुरू करें',
      'enter_symptoms': 'अपने लक्षण दर्ज करें',
      'type_symptom': 'लक्षण टाइप करें (जैसे, छाती में दर्द)',
      'add_symptom': 'लक्षण जोड़ें',
      'predict': 'बीमारी की भविष्यवाणी करें',
      'analyzing': 'लक्षणों का विश्लेषण किया जा रहा है...',
      'result_title': 'आपकी स्वास्थ्य रिपोर्ट',
      'description': 'विवरण',
      'precautions': 'सावधानियाँ',
      'alternate': 'वैकल्पिक निदान',
      'confidence': 'विश्वसनीयता',
      'questions': 'अनुवर्ती प्रश्न',
      'serious': 'गंभीर',
      'critical': 'गंभीर (आपात)',
      'high': 'उच्च',
      'medium': 'मध्यम',
      'low': 'कम',
    },
  };

  void changeLanguage(String lang) {
    currentLanguage.value = lang;
    Get.updateLocale(Locale(lang));
    saveLanguage(lang);
  }

  Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language');
    if (savedLang != null) {
      currentLanguage.value = savedLang;
      Get.updateLocale(Locale(savedLang));
    }
  }

  String translate(String key) {
    return translations[currentLanguage.value]![key] ?? key;
  }
}
