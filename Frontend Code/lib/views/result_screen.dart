import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/prediction_controller.dart';
import '../controllers/language_controller.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Color _getSeriousnessColor(String level) {
    switch (level) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      default:
        return Colors.green;
    }
  }

  String _translateSeriousness(String level, LanguageController langCtrl) {
    if (langCtrl.currentLanguage.value == 'hi') {
      switch (level) {
        case 'critical':
          return langCtrl.translate('critical');
        case 'high':
          return langCtrl.translate('high');
        case 'medium':
          return langCtrl.translate('medium');
        default:
          return langCtrl.translate('low');
      }
    }
    return level;
  }

  @override
  Widget build(BuildContext context) {
    final pCtrl = Get.find<PredictionController>();
    final langCtrl = Get.find<LanguageController>();
    final res = pCtrl.result.value;

    if (res == null) {
      return Scaffold(
        appBar: AppBar(title: Text(langCtrl.translate('result_title'))),
        body: Center(
          child: Text(
            langCtrl.currentLanguage.value == 'en'
                ? "No result available."
                : "कोई परिणाम उपलब्ध नहीं है।",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(langCtrl.translate('result_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DISEASE NAME & CONFIDENCE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res.predictedDisease,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            backgroundColor: Colors.blue.shade100,
                            label: Text(
                              "${(res.confidenceScore * 100).toStringAsFixed(1)}% ${langCtrl.translate('confidence')}",
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor:
                                _getSeriousnessColor(res.diseaseSeriousness),
                            label: Text(
                              _translateSeriousness(
                                  res.diseaseSeriousness, langCtrl),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  res.diseaseSeriousness == 'critical'
                      ? Icons.warning
                      : res.diseaseSeriousness == 'high'
                          ? Icons.error
                          : Icons.info,
                  color: _getSeriousnessColor(res.diseaseSeriousness),
                  size: 36,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// SERIOUSNESS WARNING
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: res.diseaseSeriousness == 'critical'
                    ? Colors.red.shade100
                    : res.diseaseSeriousness == 'high'
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSeriousnessColor(res.diseaseSeriousness),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        res.isSerious ? Icons.warning : Icons.check_circle,
                        color: _getSeriousnessColor(res.diseaseSeriousness),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          res.isSerious
                              ? langCtrl.currentLanguage.value == 'en'
                                  ? "⚠ ${res.diseaseSeriousness.toUpperCase()} condition detected — please consult a specialist immediately."
                                  : "⚠ ${_translateSeriousness(res.diseaseSeriousness, langCtrl).toUpperCase()} स्थिति का पता चला है — कृपया तुरंत विशेषज्ञ से सलाह लें।"
                              : langCtrl.currentLanguage.value == 'en'
                                  ? "✅ This condition looks manageable. Follow precautions and seek care if symptoms worsen."
                                  : "✅ यह स्थिति प्रबंधनीय लगती है। सावधानियों का पालन करें और लक्षण बिगड़ने पर देखभाल लें।",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getSeriousnessColor(res.diseaseSeriousness),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (res.isSerious)
                    Text(
                      langCtrl.currentLanguage.value == 'en'
                          ? "• Call emergency services if you experience severe symptoms\n• Do not self-medicate\n• Keep someone with you"
                          : "• गंभीर लक्षण दिखने पर आपातकालीन सेवाओं को बुलाएं\n• स्वयं दवा न लें\n• अपने साथ किसी को रखें",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SYMPTOM SUMMARY
            if (res.correctedSymptoms != null &&
                res.correctedSymptoms!.isNotEmpty)
              _buildSectionCard(
                title: langCtrl.currentLanguage.value == 'en'
                    ? "📋 Interpreted Symptoms"
                    : "📋 समझे गए लक्षण",
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: res.correctedSymptoms!.map((s) {
                    return Chip(
                      label: Text(s),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
              ),

            if (res.unmatchedSymptoms != null &&
                res.unmatchedSymptoms!.isNotEmpty)
              _buildSectionCard(
                title: langCtrl.currentLanguage.value == 'en'
                    ? "⚠ Unrecognized Inputs"
                    : "⚠ अपरिचित इनपुट",
                child: Text(
                  res.unmatchedSymptoms!.join(", "),
                  style: const TextStyle(color: Colors.orange),
                ),
              ),

            /// DESCRIPTION
            _buildSectionCard(
              title: langCtrl.translate('description'),
              child: Text(
                res.description,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            /// PRECAUTIONS
            _buildSectionCard(
              title: langCtrl.translate('precautions'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: res.precautions.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              idx.toString(),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            /// ALTERNATE DIAGNOSES
            if (res.alternateDiagnoses.isNotEmpty)
              _buildSectionCard(
                title: langCtrl.translate('alternate'),
                child: Column(
                  children: res.alternateDiagnoses.map((alt) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            "${(alt.probability * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(alt.disease),
                        subtitle: LinearProgressIndicator(
                          value: alt.probability,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            /// SUGGESTED QUESTIONS
            if (res.suggestedQuestions.isNotEmpty)
              _buildSectionCard(
                title: langCtrl.translate('questions'),
                child: Column(
                  children: res.suggestedQuestions.map((q) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.blue.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.question_answer, size: 20),
                        title: Text(q),
                      ),
                    );
                  }).toList(),
                ),
              ),

            /// BACK TO HOME
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langCtrl.currentLanguage.value == 'en'
                          ? "🧠 Mind & Relax Tip"
                          : "🧠 दिमाग और आराम टिप",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      langCtrl.currentLanguage.value == 'en'
                          ? "Try a 4-2-6 breathing exercise: Inhale 4s, hold 2s, exhale 6s. Repeat 5 times to reduce stress."
                          : "4-2-6 सांस लेने का व्यायाम आजमाएं: 4 सेकंड में सांस लें, 2 सेकंड रोकें, 6 सेकंड में छोड़ें। तनाव कम करने के लिए 5 बार दोहराएं।",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.offAllNamed('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          langCtrl.currentLanguage.value == 'en'
                              ? "Back to Home"
                              : "होम पर वापस जाएं",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
