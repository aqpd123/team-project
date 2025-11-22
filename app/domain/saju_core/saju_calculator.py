from typing import Any, Dict, List, Tuple, Optional, Protocol

from .data_validator import DataValidator
from .personality_analyzer import PersonalityAnalyzer
from .character_system import CharacterSystem
from .calendar_converter import GanjiCalculator
from app.common.exceptions import ValidationError
from .utils import HEAVENLY_STEMS, EARTHLY_BRANCHES, load_h5_model_if_available

import math


class CalendarClientProtocol(Protocol):
    def convert_solar_to_lunar(self, year: int, month: int, day: int) -> Dict[str, Any]:
        ...


class SajuCalculator:
    def __init__(
        self,
        validator: DataValidator,
        analyzer: PersonalityAnalyzer,
        characters: CharacterSystem,
        calendar_client: Optional[CalendarClientProtocol] = None,
        ganji_calculator: Optional[GanjiCalculator] = None,
    ) -> None:
        if validator is None or analyzer is None or characters is None:
            raise ValidationError("필수 의존성이 누락되었습니다: validator/analyzer/characters")
        self.validator = validator
        self.analyzer = analyzer
        self.characters = characters
        self.calendar_client = calendar_client
        self.ganji_calculator = ganji_calculator or GanjiCalculator()
        # 모델은 선택적 의존성: 존재하면 사용, 없으면 폴백 상수 사용
        self.sky_model = None
        self.earth_model = None

    # ===== Public APIs =====

    def get_birth_data(self, year: int, month: int, day: int, hour: int = 12, minute: int = 0) -> Dict[str, Any]:
        if not self.validator:
            raise ValidationError("DataValidator가 설정되지 않았습니다.")
        if self.ganji_calculator is None:
            raise ValidationError("Ganji 계산기가 설정되지 않았습니다.")
        self.validator.validate_birth_date(year, month, day)
        ganji = self.ganji_calculator.calculate(year, month, day, hour, minute)
        if self.calendar_client:
            try:
                lunar = self.calendar_client.convert_solar_to_lunar(year, month, day)
                ganji["lunar"] = lunar.get("lunar")
            except ValidationError:
                ganji["lunar"] = None
        return ganji

    def calculate_personal_traits(self, saju: Dict[str, str]) -> Dict[str, float]:
        self._ensure_valid_saju(saju)
        five = self.analyzer.analyze_five_elements(saju)
        traits = self.analyzer.calculate_8_traits(saju)
        report = self.analyzer.generate_personality_report(traits)
        return {"five": five, "traits": traits, "report": report}

    def calculate_compatibility(
        self,
        saju1: Dict[str, str],
        saju2: Dict[str, str],
        gender1: int,
        gender2: int,
    ) -> Dict[str, float]:
        self._ensure_valid_saju(saju1)
        self._ensure_valid_saju(saju2)
        if gender1 not in (0, 1) or gender2 not in (0, 1):
            raise ValidationError("gender 값은 0(여) 또는 1(남)이어야 합니다.")
        token0 = self._build_tokens_from_saju(saju1)
        token1 = self._build_tokens_from_saju(saju2)

        ys = self._predict_sky(token0[0], token1[0])
        ms = self._predict_sky(token0[2], token1[2])
        ds = self._predict_sky(token0[4], token1[4])
        ye = self._predict_earth(token0[1], token1[1])
        me = self._predict_earth(token0[3], token1[3])
        de = self._predict_earth(token0[5], token1[5])

        org_score = (0.6 * ys) + (4.5 * ds) + (1.0 * ye) + (1.5 * me) + (4.5 * de)
        score, sal0, sal1 = self._original_calculate(token0, token1, gender1, gender2, org_score)

        if sum(sal0) > 0 and sum(sal1) > 0:
            stress = 0.5 * (106 - org_score) + (org_score - score) * 1.8
        else:
            stress = 0.5 * (106 - org_score) + (org_score - score)

        return {
            "original": float(round(org_score, 3)),
            "final": float(round(score, 3)),
            "stress": float(round(stress, 3)),
        }

    def determine_character_type(self, saju: Dict[str, str]) -> str:
        self._ensure_valid_saju(saju)
        five = self.analyzer.analyze_five_elements(saju)
        return self.characters.determine(five)

    def calculate_personality_flags_hd2(
        self, saju: Dict[str, str], gender: int = 0
    ) -> Dict[str, Any]:
        self._ensure_valid_saju(saju)
        if gender not in (0, 1):
            raise ValidationError("gender 값은 0(여) 또는 1(남)이어야 합니다.")
        token = self._build_tokens_from_saju(saju)

        ys = self._predict_sky(token[0], token[0])
        ms = self._predict_sky(token[2], token[2])
        ds = self._predict_sky(token[4], token[4])
        ye = self._predict_earth(token[1], token[1])
        me = self._predict_earth(token[3], token[3])
        de = self._predict_earth(token[5], token[5])

        org_score = (0.6 * ys) + (4.5 * ds) + (1.0 * ye) + (1.5 * me) + (4.5 * de)
        _score, sal0, _sal1 = self._original_calculate(token, token, gender, gender, org_score)

        keywords = [
            "열정 에너지 예술 중독",
            "예민 직감 영적 불안",
            "감정기복 갈등 오해 고독",
            "강함 용감 충동 변화",
            "책임감 의리 완벽 자존심 인내",
            "충돌 자유 고집",
            "카리스마 승부욕 용감 외로움",
            "의지 솔직 직설 개성 고집 독립심",
        ]
        flags = [keywords[i] for i, v in enumerate(sal0) if v > 0]
        return {"flags": flags, "sal": sal0}

    def analyze_personality(self, saju: Dict[str, str], gender: int = 0) -> Dict[str, Any]:
        self._ensure_valid_saju(saju)
        if gender not in (0, 1):
            raise ValidationError("gender 값은 0(여) 또는 1(남)이어야 합니다.")
        base = self.calculate_personal_traits(saju)
        flags = self.calculate_personality_flags_hd2(saju, gender).get("flags", [])
        result = dict(base)
        result["flags"] = flags
        return result

    # ===== Internal: hd2 logic =====
    def _build_tokens_from_saju(self, saju: Dict[str, str]) -> List[int]:
        self._ensure_valid_saju(saju)

        def idx_of_stem(s: str) -> int:
            return HEAVENLY_STEMS.index(s) + 1

        def idx_of_branch(s: str) -> int:
            return EARTHLY_BRANCHES.index(s) + 1

        ys = idx_of_stem(saju["year_gan"])
        ye = idx_of_branch(saju["year_ji"])
        ms = idx_of_stem(saju["month_gan"])
        me = idx_of_branch(saju["month_ji"])
        ds = idx_of_stem(saju["day_gan"])
        de = idx_of_branch(saju["day_ji"])
        return [ys, ye, ms, me, ds, de]

    def _predict_sky(self, i: int, j: int) -> float:
        # lazy-load
        if self.sky_model is None:
            self.sky_model = load_h5_model_if_available("source/sky3000.h5")
        if self.sky_model is None:
            return 60.0
        import numpy as np

        t0 = np.eye(10)[int(i - 1)].flatten()
        t1 = np.eye(10)[int(j - 1)].flatten()
        s = np.concatenate((t0, t1)).reshape(1, 20)
        pred = self.sky_model.predict(s)
        return float(pred.ravel()[0])

    def _predict_earth(self, i: int, j: int) -> float:
        # lazy-load
        if self.earth_model is None:
            self.earth_model = load_h5_model_if_available("source/earth3000.h5")
        if self.earth_model is None:
            return 60.0
        import numpy as np

        t0 = np.eye(12)[int(i - 1)].flatten()
        t1 = np.eye(12)[int(j - 1)].flatten()
        s = np.concatenate((t0, t1)).reshape(1, 24)
        pred = self.earth_model.predict(s)
        return float(pred.ravel()[0])

    def _original_calculate(
        self, token0, token1, gender0, gender1, s
    ) -> Tuple[float, List[float], List[float]]:
        # hd2.ipynb 원본 상수
        p1 = 8
        p11 = 9.5
        p2 = 7
        p21 = 8.2
        p3 = 6
        p31 = 7.2
        p41 = 10
        p42 = 8
        p43 = 6
        p5 = 8
        p6 = 8
        p7 = 0
        p71 = 10
        p8 = 0
        p81 = 10
        p82 = 6
        p83 = 4

        score = float(s)
        a1 = token0[1]
        a2 = token0[3]
        a3 = token0[5]
        b1 = token1[1]
        b2 = token1[3]
        b3 = token1[5]
        sal0 = [0, 0, 0, 0, 0, 0, 0, 0]
        sal1 = [0, 0, 0, 0, 0, 0, 0, 0]

        # 그룹 0
        if a3 == 3:
            if a1 in (6, 9):
                score -= p1 if gender0 == 1 else p11
                sal0[0] += p1 if gender0 == 1 else p11
            if a2 in (6, 9):
                score -= p1 if gender0 == 1 else p11
                sal0[0] += p1 if gender0 == 1 else p11
        if a3 == 7:
            if a1 in (2, 5, 7):
                score -= p1 if gender0 == 1 else p11
                sal0[0] += p1 if gender0 == 1 else p11
            if a2 in (2, 5, 7):
                score -= p1 if gender0 == 1 else p11
                sal0[0] += p1 if gender0 == 1 else p11
        if a3 == 2:
            if a1 in (7, 8, 11):
                score -= p1 if gender0 == 1 else p11
                sal0[0] += p1 if gender0 == 1 else p11
            if a2 in (7, 8, 11):
                score -= p1 if gender0 == 1 else p11
                sal0[0] += p1 if gender0 == 1 else p11
        if b3 == 3:
            if b1 in (6, 9):
                score -= p1 if gender1 == 1 else p11
                sal1[0] += p1 if gender1 == 1 else p11
            if b2 in (6, 9):
                score -= p1 if gender1 == 1 else p11
                sal1[0] += p1 if gender1 == 1 else p11
        if b3 == 7:
            if b1 in (2, 5, 7):
                score -= p1 if gender1 == 1 else p11
                sal1[0] += p1 if gender1 == 1 else p11
            if b2 in (2, 5, 7):
                score -= p1 if gender1 == 1 else p11
                sal1[0] += p1 if gender1 == 1 else p11
        if b3 == 2:
            if b1 in (7, 8, 11):
                score -= p1 if gender1 == 1 else p11
                sal1[0] += p1 if gender1 == 1 else p11
            if b2 in (7, 8, 11):
                score -= p1 if gender1 == 1 else p11
                sal1[0] += p1 if gender1 == 1 else p11

        # 그룹 1 매핑 축약
        mapping = {1: (10,), 2: (7,), 3: (8,), 4: (9,), 5: (12,), 6: (11,), 7: (2,), 8: (3,), 9: (4,), 10: (1,), 11: (6,), 12: (5,)}
        if a3 in mapping:
            for v in mapping[a3]:
                if a1 == v or a2 == v:
                    delta = p2 if gender0 == 1 else p21
                    score -= delta
                    sal0[1] += delta
        if b3 in mapping:
            for v in mapping[b3]:
                if b1 == v or b2 == v:
                    delta = p2 if gender1 == 1 else p21
                    score -= delta
                    sal1[1] += delta

        # 차이 6 규칙
        pairs = [(a3, a2, 0), (a3, a1, 0), (a1, a2, 0), (b3, b2, 1), (b3, b1, 1), (b1, b2, 1)]
        for x, y, who in pairs:
            if abs(x - y) == 6:
                d = p41 if (x, y) in ((a3, a2), (b3, b2)) else (p42 if (x, y) in ((a3, a1), (b3, b1)) else p43)
                score -= d
                if who == 0:
                    sal0[3] += d
                else:
                    sal1[3] += d

        # p5 대표 케이스
        if a3 == 1 and (a1 == 4 or a2 == 4):
            score -= p5
            sal0[4] += p5
        if b3 == 1 and (b1 == 4 or b2 == 4):
            score -= p5
            sal1[4] += p5
        if a3 == 3 and (a1 == 6 or a2 == 6):
            score -= p5
            sal0[4] += p5
        if b3 == 3 and (b1 == 6 or b2 == 6):
            score -= p5
            sal1[4] += p5

        # p6 대표 케이스
        if a3 == 7 and (a1 == 4 or a2 == 4):
            score -= p6
            sal0[5] += p6
        if b3 == 7 and (b1 == 4 or b2 == 4):
            score -= p6
            sal1[5] += p6
        if a3 == 5 and (a1 == 2 or a2 == 2):
            score -= p6
            sal0[5] += p6
        if b3 == 5 and (b1 == 2 or b2 == 2):
            score -= p6
            sal1[5] += p6

        # p7 / p71
        if (
            (token0[4] == 5 and a3 == 5)
            or (token0[4] == 4 and a3 == 2)
            or (token0[4] == 3 and a3 == 11)
            or (token0[4] == 2 and a3 == 8)
            or (token0[4] == 1 and a3 == 5)
            or (token0[4] == 10 and a3 == 2)
            or (token0[4] == 9 and a3 == 11)
        ):
            if gender0 == 1:
                score -= p7
                sal0[6] += p7
            else:
                score -= p71
                sal0[6] += p71
        if (
            (token1[4] == 5 and b3 == 5)
            or (token1[4] == 4 and b3 == 2)
            or (token1[4] == 3 and b3 == 11)
            or (token1[4] == 2 and b3 == 8)
            or (token1[4] == 1 and b3 == 5)
            or (token1[4] == 10 and b3 == 2)
            or (token1[4] == 9 and b3 == 11)
        ):
            if gender1 == 1:
                score -= p7
                sal1[6] += p7
            else:
                score -= p71
                sal1[6] += p71

        # 여성 특화 p81/p82/p83
        if (gender0 != 1) and ((token0[4] == 9 and a3 == 5) or (token0[4] == 5 and a3 == 11) or (token0[4] == 7 and a3 == 5) or (token0[4] == 7 and a3 == 11)):
            score -= p81
            sal0[7] += p81
        if (gender0 != 1) and ((token0[2] == 9 and a2 == 5) or (token0[2] == 5 and a2 == 11) or (token0[2] == 7 and a2 == 5) or (token0[2] == 7 and a2 == 11)):
            score -= p82
            sal0[7] += p82
        if (gender0 != 1) and ((token0[0] == 9 and a1 == 5) or (token0[0] == 5 and a1 == 11) or (token0[0] == 7 and a1 == 5) or (token0[0] == 7 and a1 == 11)):
            score -= p83
            sal0[7] += p83

        if (gender1 != 1) and ((token1[4] == 9 and b3 == 5) or (token1[4] == 5 and b3 == 11) or (token1[4] == 7 and b3 == 5) or (token1[4] == 7 and b3 == 11)):
            score -= p81
            sal1[7] += p81
        if (gender1 != 1) and ((token1[2] == 9 and b2 == 5) or (token1[2] == 5 and b2 == 11) or (token1[2] == 7 and b2 == 5) or (token1[2] == 7 and b2 == 11)):
            score -= p82
            sal1[7] += p82
        if (gender1 != 1) and ((token1[0] == 9 and b1 == 5) or (token1[0] == 5 and b1 == 11) or (token1[0] == 7 and b1 == 5) or (token1[0] == 7 and b1 == 11)):
            score -= p83
            sal1[7] += p83

        return score, sal0, sal1

    def _ensure_valid_saju(self, saju: Dict[str, str]) -> None:
        if not isinstance(saju, dict) or not saju:
            raise ValidationError("필수 사주 정보가 없습니다.")
        required = {"year_gan", "year_ji", "month_gan", "month_ji", "day_gan", "day_ji"}
        missing = [k for k in required if k not in saju or not saju[k]]
        if missing:
            raise ValidationError(f"사주 데이터 누락: {', '.join(missing)}")


