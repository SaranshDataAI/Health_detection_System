class PredictionResponse {
  final String predictedDisease;
  final String diseaseSeriousness; // New: "critical", "high", "medium", "low"
  final int severityScore;
  final double confidenceScore; // New
  final String description;
  final List<String> precautions;
  final List<String> suggestedQuestions; // New
  final List<AlternateDiagnosis> alternateDiagnoses; // New
  final List<String>? correctedSymptoms;
  final List<String>? unmatchedSymptoms;

  PredictionResponse({
    required this.predictedDisease,
    required this.diseaseSeriousness,
    required this.severityScore,
    required this.confidenceScore,
    required this.description,
    required this.precautions,
    required this.suggestedQuestions,
    required this.alternateDiagnoses,
    this.correctedSymptoms,
    this.unmatchedSymptoms,
  });

  // Computed property for backward compatibility
  bool get isSerious =>
      diseaseSeriousness == "critical" || diseaseSeriousness == "high";

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictedDisease: json["predicted_disease"] ?? "",
      diseaseSeriousness: json["disease_seriousness"] ?? "low",
      severityScore: json["severity_score"] ?? 0,
      confidenceScore: (json["confidence_score"] ?? 0).toDouble(),
      description: json["description"] ?? "",
      precautions: List<String>.from(json["precautions"] ?? []),
      suggestedQuestions: List<String>.from(json["suggested_questions"] ?? []),
      alternateDiagnoses: (json["alternate_diagnoses"] ?? [])
          .map((e) => AlternateDiagnosis.fromJson(e))
          .toList()
          .cast<AlternateDiagnosis>(),
      correctedSymptoms: json["corrected_symptoms"] != null
          ? List<String>.from(json["corrected_symptoms"])
          : null,
      unmatchedSymptoms: json["unmatched_symptoms"] != null
          ? List<String>.from(json["unmatched_symptoms"])
          : null,
    );
  }
}

class AlternateDiagnosis {
  final String disease;
  final double probability;

  AlternateDiagnosis({required this.disease, required this.probability});

  factory AlternateDiagnosis.fromJson(Map<String, dynamic> json) {
    return AlternateDiagnosis(
      disease: json["disease"] ?? "",
      probability: (json["prob"] ?? 0).toDouble(),
    );
  }
}
