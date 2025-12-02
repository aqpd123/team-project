import 'package:flutter/widgets.dart';

import '../models/celebrity_model.dart';
import '../services/api_client.dart';

class CelebrityController extends ChangeNotifier {
  CelebrityController(this._api);

  final ApiClient _api;

  bool _isLoading = false;
  String? _error;
  List<CelebrityModel> _celebrities = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CelebrityModel> get celebrities => _celebrities;

  Future<void> loadCelebrities({String? keyword}) async {
    _setLoading(true);
    try {
      final queryParams = keyword != null && keyword.isNotEmpty
          ? '?keyword=$keyword'
          : '';
      final response = await _api.get('/celebrities$queryParams');
      _error = null;
      final itemsList = response['items'];
      if (itemsList == null || itemsList is! List) {
        _error = '유명인 데이터 형식이 올바르지 않습니다.';
        _celebrities = [];
        notifyListeners();
        return;
      }
      final items = itemsList
          .map((json) => CelebrityModel.fromJson(json))
          .toList();
      _celebrities = items;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _celebrities = [];
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = '유명인 목록을 불러오는 중 오류가 발생했습니다: $e';
      _celebrities = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<CelebrityModel> getCelebrity(int id) async {
    _setLoading(true);
    try {
      final response = await _api.get('/celebrities/$id');
      _error = null;
      return CelebrityModel.fromJson(response);
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> calculateCompatibility(
    int celebrityId,
    Map<String, String> userSaju,
    int userGender,
  ) async {
    _setLoading(true);
    try {
      final response = await _api.post(
        '/celebrities/$celebrityId/compatibility',
        data: {
          'saju': userSaju,
          'gender': userGender,
        },
      );
      _error = null;
      return Map<String, dynamic>.from(response);
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class CelebrityScope extends InheritedNotifier<CelebrityController> {
  const CelebrityScope({
    super.key,
    required CelebrityController controller,
    required super.child,
  }) : super(notifier: controller);

  static CelebrityController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CelebrityScope>();
    assert(scope != null, 'CelebrityScope is missing in the widget tree');
    return scope!.notifier!;
  }
}

