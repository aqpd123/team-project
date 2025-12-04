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
      
      // 디버깅: 응답에 ai_summary가 포함되어 있는지 확인
      print("📥 개인 사주 분석 응답 수신");
      print("📥 응답 키 목록: ${response.keys.toList()}");
      if (response.containsKey('ai_summary')) {
        final aiSummary = response['ai_summary'];
        print("✅ 응답에 ai_summary 포함됨");
        print("📝 ai_summary 타입: ${aiSummary.runtimeType}");
        print("📝 ai_summary 값: ${aiSummary?.toString().substring(0, (aiSummary?.toString().length ?? 0) > 100 ? 100 : (aiSummary?.toString().length ?? 0))}...");
      } else {
        print("⚠️ 응답에 ai_summary가 없음");
      }
      
      final result = SajuAnalysisResult.fromJson(response);
      print("📝 파싱된 result.aiSummary 길이: ${result.aiSummary.length}자");
      if (result.aiSummary.isNotEmpty) {
        print("✅ result.aiSummary 내용: ${result.aiSummary.substring(0, result.aiSummary.length > 100 ? 100 : result.aiSummary.length)}...");
      } else {
        print("⚠️ result.aiSummary가 비어있음");
      }
      
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


