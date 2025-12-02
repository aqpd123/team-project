import 'package:flutter/widgets.dart';

import '../models/saju_models.dart';
import '../services/api_client.dart';

class SajuController extends ChangeNotifier {
  SajuController(this._api);

  final ApiClient _api;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<SajuAnalysisResult> analyzeTraits(SajuBirthTraitsRequest request) async {
    _setLoading(true);
    try {
      final response = await _api.post(
        '/saju/traits/birth',
        data: request.toJson(),
      );
      _error = null;
      final result = SajuAnalysisResult.fromJson(response);
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<SajuCompatibilityResult> calculateCompatibility(
    SajuBirthCompatibilityRequest request,
  ) async {
    _setLoading(true);
    try {
      final response = await _api.post(
        '/saju/compatibility/birth',
        data: request.toJson(),
      );
      _error = null;
      return SajuCompatibilityResult.fromJson(response);
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}

class SajuScope extends InheritedNotifier<SajuController> {
  const SajuScope({
    super.key,
    required SajuController controller,
    required super.child,
  }) : super(notifier: controller);

  static SajuController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SajuScope>();
    assert(scope != null, 'SajuScope is missing in the widget tree');
    return scope!.notifier!;
  }
}


