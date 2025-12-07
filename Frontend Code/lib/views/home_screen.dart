// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/language_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final LanguageController langCtrl =
      Get.find<LanguageController>(); // Changed from Get.put

  final Map<String, List<String>> healthTips = {
    'en': [
      "💧 Drink 2–3 liters of water daily to stay hydrated.",
      "😴 Sleep 7–9 hours to boost immunity & brain function.",
      "🚶 Take a 10-minute walk after meals for better digestion.",
      "🍎 Eat fruits & vegetables daily for essential vitamins.",
      "🧠 A calm mind supports a healthy body — meditate 5 minutes.",
      "💪 Regular exercise reduces risk of chronic disease.",
      "😊 Take small breaks to avoid mental fatigue.",
    ],
    'hi': [
      "💧 रोज 2-3 लीटर पानी पिएं ताकि शरीर हाइड्रेटेड रहे।",
      "😴 7-9 घंटे की नींद लें इम्यूनिटी और दिमाग के लिए।",
      "🚶 खाने के बाद 10 मिनट टहलें बेहतर पाचन के लिए।",
      "🍎 फल और सब्जियां रोज खाएं जरूरी विटामिन के लिए।",
      "🧠 शांत दिमाग स्वस्थ शरीर का आधार है — 5 मिनट ध्यान करें।",
      "💪 नियमित व्यायाम से क्रोनिक बीमारियों का खतरा कम होता है।",
      "😊 मानसिक थकान से बचने के लिए बीच-बीच में ब्रेक लें।",
    ],
  };

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    langCtrl.loadSavedLanguage();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage < healthTips[langCtrl.currentLanguage.value]!.length) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(0);
        }
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER WITH LANGUAGE SWITCHER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langCtrl.currentLanguage.value == 'en'
                        ? "AI Health Assistant"
                        : "एआई स्वास्थ्य सहायक",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  _buildLanguageSwitcher(),
                ],
              ),
            ),

            /// SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                langCtrl.currentLanguage.value == 'en'
                    ? "Your personal health helper 💙\nLet's understand your symptoms better."
                    : "आपकी व्यक्तिगत स्वास्थ्य सहायक 💙\nआइए आपके लक्षणों को बेहतर समझें।",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ),

            const SizedBox(height: 20),

            /// ANIMATION - Use existing file
            SizedBox(
              height: 220,
              child: Lottie.asset("assets/animations/education.json"),
            ),

            const SizedBox(height: 20),

            /// HEALTH STATS CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.medical_services,
                    value: "100+",
                    label: langCtrl.currentLanguage.value == 'en'
                        ? "Diseases"
                        : "बीमारियाँ",
                    color: Colors.blue.shade100,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    icon: Icons.psychology,
                    value: "98%",
                    label: langCtrl.currentLanguage.value == 'en'
                        ? "Accuracy"
                        : "सटीकता",
                    color: Colors.green.shade100,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    icon: Icons.language,
                    value: "2",
                    label: langCtrl.currentLanguage.value == 'en'
                        ? "Languages"
                        : "भाषाएँ",
                    color: Colors.purple.shade100,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// HEALTH TIPS CAROUSEL
            Expanded(
              child: Obx(() {
                // FIXED: Obx not GekX
                final tips = healthTips[langCtrl.currentLanguage.value]!;
                return PageView.builder(
                  controller: _pageController,
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    return _buildTipCard(tips[index], index);
                  },
                );
              }),
            ),

            const SizedBox(height: 15),

            /// START BUTTON
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed("/input"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.shade300,
                ),
                icon: const Icon(Icons.medical_services, color: Colors.white),
                label: Text(
                  langCtrl.currentLanguage.value == 'en'
                      ? "Start Diagnosis"
                      : "निदान शुरू करें",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.language, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Obx(() => Text(
                // FIXED: Obx not GekX
                langCtrl.currentLanguage.value == 'en' ? 'EN' : 'हिंदी',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              )),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            onSelected: (value) => langCtrl.changeLanguage(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('English'),
                    if (langCtrl.currentLanguage.value == 'en')
                      const Icon(Icons.check, size: 16),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hi',
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('हिंदी'),
                    if (langCtrl.currentLanguage.value == 'hi')
                      const Icon(Icons.check, size: 16),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.arrow_drop_down, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.blue.shade700),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            index % 2 == 0 ? Colors.blue.shade50 : Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          tip,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade900,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
