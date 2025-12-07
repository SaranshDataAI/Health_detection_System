import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/prediction_response.dart';

class PredictionController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<PredictionResponse> result = Rxn<PredictionResponse>();
  final RxString error = ''.obs;

  Future<void> predict(List<String> symptoms) async {
    isLoading.value = true;
    error.value = '';
    result.value = null;

    final resp = await ApiService.predictDisease(symptoms);

    if (resp == null) {
      error.value =
          "Unable to fetch prediction. Please check your internet connection or try again.";
      isLoading.value = false;
      return;
    }

    result.value = resp;
    isLoading.value = false;
  }
}
