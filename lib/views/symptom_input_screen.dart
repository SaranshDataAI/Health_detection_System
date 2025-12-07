import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lottie/lottie.dart';
import '../controllers/symptom_controller.dart';
import '../controllers/prediction_controller.dart';
import '../controllers/language_controller.dart';
import '../widgets/symptom_chip.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final SymptomController sCtrl = Get.find();
  final PredictionController pCtrl = Get.find();
  final LanguageController langCtrl = Get.find();
  final TextEditingController textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addFromText() {
    final raw = textCtrl.text.trim();
    if (raw.isEmpty) {
      Get.snackbar(
        "Empty",
        "Please type a symptom or choose from suggestions.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    sCtrl.addSymptom(raw);
    textCtrl.clear();
    _focusNode.requestFocus();
  }

  void _predict() async {
    if (sCtrl.selectedSymptoms.isEmpty) {
      Get.snackbar(
        "No symptoms",
        "Please add at least one symptom for diagnosis.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await pCtrl.predict(sCtrl.selectedSymptoms.toList());

    if (pCtrl.error.value.isNotEmpty) {
      Get.snackbar(
        "Error",
        pCtrl.error.value,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (pCtrl.result.value != null) {
      final unmatched = pCtrl.result.value!.unmatchedSymptoms;
      if (unmatched != null && unmatched.isNotEmpty) {
        Get.snackbar(
          "Note",
          "Some inputs were not recognized: ${unmatched.join(', ')}",
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      Get.toNamed('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enter Your Symptoms",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.blue.shade800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// WELCOME CARD
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.purple.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "🔍 How are you feeling today?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Describe your symptoms in simple words. Our AI will analyze them to provide accurate insights.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Lottie.asset(
                        "assets/animations/education.json",
                        height: 70,
                        width: 70,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// SYMPTOM INPUT SECTION
              Text(
                "📝 Enter Your Symptoms",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TypeAheadField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: textCtrl,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: "Try: chest pain, headache, fever...",
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blue.shade600,
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send_rounded),
                              onPressed: _addFromText,
                              color: Colors.blue.shade600,
                              tooltip: 'Add symptom',
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        suggestionsCallback: (q) => sCtrl.getSuggestions(q),
                        itemBuilder: (_, suggestion) {
                          final isSimilarMatch =
                              suggestion.contains('(similar to');
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSimilarMatch
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100,
                              radius: 20,
                              child: Icon(
                                isSimilarMatch
                                    ? Icons.lightbulb
                                    : Icons.medical_services,
                                size: 16,
                                color: isSimilarMatch
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                            title: Text(
                              isSimilarMatch
                                  ? suggestion
                                      .split(' (')[0]
                                      .replaceAll('_', ' ')
                                  : suggestion.replaceAll('_', ' '),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isSimilarMatch
                                    ? Colors.orange.shade800
                                    : Colors.black,
                              ),
                            ),
                            subtitle: isSimilarMatch
                                ? Text(
                                    "Similar to what you typed",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade600,
                                    ),
                                  )
                                : null,
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            dense: true,
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          sCtrl.addSymptom(suggestion);
                          textCtrl.clear();
                          _focusNode.requestFocus();
                        },
                        noItemsFoundBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No matching symptoms found",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try simpler terms like 'pain', 'fever', 'cough'",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final raw = textCtrl.text.trim();
                                  if (raw.isNotEmpty) {
                                    sCtrl.addSymptom(raw);
                                    textCtrl.clear();
                                    _focusNode.requestFocus();
                                  }
                                },
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: Colors.blue.shade700,
                                ),
                                label: Text(
                                  "Add anyway (AI will interpret)",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Type in English or Hindi. Examples: 'सिरदर्द' or 'headache', 'छाती में दर्द' or 'chest pain'",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// POPULAR SYMPTOMS QUICK SELECT
              Text(
                "💡 Common Symptoms:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'fever',
                  'headache',
                  'chest pain',
                  'cough',
                  'fatigue',
                  'nausea',
                  'dizziness',
                  'abdominal pain',
                ].map((symptom) {
                  return ActionChip(
                    avatar: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      radius: 12,
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    label: Text(symptom),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: () {
                      sCtrl.addSymptom(symptom);
                      Get.snackbar(
                        "Added",
                        "Added '$symptom' to symptoms list",
                        backgroundColor: Colors.green.shade100,
                        colorText: Colors.green.shade900,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// SELECTED SYMPTOMS SECTION
              Row(
                children: [
                  Text(
                    "📋 Selected Symptoms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    return Text(
                      "${sCtrl.selectedSymptoms.length} added",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (sCtrl.selectedSymptoms.isEmpty) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orange.shade50,
                            Colors.yellow.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.medical_information_outlined,
                            size: 48,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No symptoms added yet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add symptoms above for accurate AI diagnosis. The more symptoms you add, the better the prediction.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: sCtrl.selectedSymptoms.map((s) {
                            return SymptomChip(
                              label: s.replaceAll('_', ' '),
                              onDelete: () => sCtrl.removeSymptom(s),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                sCtrl.clearAllSymptoms();
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red.shade700,
                              ),
                              label: Text(
                                "Clear All",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade100,
                                    Colors.teal.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${sCtrl.selectedSymptoms.length} symptoms",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              /// PREDICT BUTTON
              Obx(() {
                return pCtrl.isLoading.value
                    ? Column(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.purple.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                children: [
                                  Lottie.asset(
                                    "assets/animations/loading.json",
                                    height: 100,
                                    width: 100,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Analyzing symptoms...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "AI is analyzing your symptoms to provide accurate diagnosis",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade300.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 24,
                          ),
                          label: const Text(
                            "Predict Disease",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: _predict,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
                      );
              }),

              const SizedBox(height: 20),

              /// TIP CARD
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "💡 Tip: Be specific with symptoms. Instead of 'pain', try 'sharp chest pain' or 'dull headache' for better accuracy.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
