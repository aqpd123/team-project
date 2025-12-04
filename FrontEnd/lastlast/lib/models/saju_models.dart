class SajuBirthTraitsRequest {
  SajuBirthTraitsRequest({
    required this.year,
    required this.month,
    required this.day,
    this.hour = 12,
    this.minute = 0,
    this.gender = 0,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int gender;

  Map<String, dynamic> toJson() {
    return {
      'birth': {
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
      },
      'gender': gender,
    };
  }
}

class SajuBirthInfo {
  const SajuBirthInfo({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  Map<String, int> toJson() => {
        'year': year,
        'month': month,
        'day': day,
      };
}

class SajuBirthCompatibilityRequest {
  SajuBirthCompatibilityRequest({
    required this.person1,
    required this.person2,
    this.gender1 = 0,
    this.gender2 = 0,
    this.person1Name,
    this.person2Name,
  });

  final SajuBirthInfo person1;
  final SajuBirthInfo person2;
  final int gender1;
  final int gender2;
  final String? person1Name;
  final String? person2Name;

  Map<String, dynamic> toJson() => {
        'birth1': person1.toJson(),
        'birth2': person2.toJson(),
        'gender1': gender1,
        'gender2': gender2,
        if (person1Name != null) 'person1_name': person1Name,
        if (person2Name != null) 'person2_name': person2Name,
      };
}

class SajuAnalysisResult {
  SajuAnalysisResult({
    required this.character,
    required this.fiveElements,
    required this.traits,
    required this.flags,
    required this.report,
    required this.saju,
    this.aiSummary = '',
  });

  final String character;
  final Map<String, double> fiveElements;
  final Map<String, double> traits;
  final List<String> flags;
  final String report;
  final Map<String, String> saju;
  final String aiSummary; // Gemini로 생성한 개인 사주 전반 분석 요약

  factory SajuAnalysisResult.fromJson(Map<String, dynamic> json) {
    Map<String, double> toDoubleMap(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return raw.map(
          (key, value) => MapEntry(
            key,
            double.tryParse(value.toString()) ?? 0,
          ),
        );
      }
      return {};
    }
    Map<String, String> toStringMap(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return raw.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        );
      }
      return {};
    }

    // ai_summary 파싱 (null 체크 및 타입 변환)
    final aiSummaryRaw = json['ai_summary'];
    final aiSummary = aiSummaryRaw != null 
        ? (aiSummaryRaw is String ? aiSummaryRaw : aiSummaryRaw.toString())
        : '';

    return SajuAnalysisResult(
      character: (json['character'] ?? '') as String,
      fiveElements: toDoubleMap(json['five']),
      traits: toDoubleMap(json['traits']),
      flags: (json['flags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      report: (json['report'] ?? '') as String,
      saju: toStringMap(json['saju']),
      aiSummary: aiSummary,
    );
  }
}

class SajuCompatibilityResult {
  SajuCompatibilityResult({
    required this.original,
    required this.finalScore,
    required this.stress,
    required this.details,
    required this.saju1,
    required this.saju2,
    this.insights = const {},
    this.advice = '',
  });

  final double original;
  final double finalScore;
  final double stress;
  final Map<String, dynamic> details;
  final Map<String, String> saju1;
  final Map<String, String> saju2;
  final Map<String, String> insights; // AI 생성 인사이트 (연애, 우정, 직장)
  final String advice; // AI 생성 관계 발전 조언

  factory SajuCompatibilityResult.fromJson(Map<String, dynamic> json) {
    Map<String, String> toStringMap(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return raw.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        );
      }
      return {};
    }
    
    // insights 파싱
    Map<String, String> insightsMap = {};
    if (json['insights'] is Map<String, dynamic>) {
      final insightsRaw = json['insights'] as Map<String, dynamic>;
      insightsMap = insightsRaw.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
    }
    
    // advice 파싱
    final advice = (json['advice'] ?? '') as String;

    return SajuCompatibilityResult(
      original: (json['original'] ?? 0).toDouble(),
      finalScore: (json['final'] ?? 0).toDouble(),
      stress: (json['stress'] ?? 0).toDouble(),
      details: (json['details'] as Map<String, dynamic>? ?? const {}),
      saju1: toStringMap(json['saju1']),
      saju2: toStringMap(json['saju2']),
      insights: insightsMap,
      advice: advice,
    );
  }
}


