from typing import Dict, List, Tuple

STEM_TO_ELEMENT = {
    "갑": "wood", "을": "wood",
    "병": "fire", "정": "fire",
    "무": "earth", "기": "earth",
    "경": "metal", "신": "metal",
    "임": "water", "계": "water",
}

BRANCH_TO_ELEMENT = {
    "자": "water", "축": "earth", "인": "wood", "묘": "wood",
    "진": "earth", "사": "fire", "오": "fire", "미": "earth",
    "신": "metal", "유": "metal", "술": "earth", "해": "water",
}

ELEMENT_KEYS = ["wood", "fire", "earth", "metal", "water"]


class PersonalityAnalyzer:
    def analyze_five_elements(self, saju: Dict[str, str]) -> Dict[str, float]:
        counts = {k: 0 for k in ELEMENT_KEYS}
        parts = [
            ("year_gan", STEM_TO_ELEMENT), ("year_ji", BRANCH_TO_ELEMENT),
            ("month_gan", STEM_TO_ELEMENT), ("month_ji", BRANCH_TO_ELEMENT),
            ("day_gan", STEM_TO_ELEMENT), ("day_ji", BRANCH_TO_ELEMENT),
        ]
        total = 0
        for field, m in parts:
            v = saju.get(field)
            if v:
                el = m.get(v)
                if el:
                    counts[el] += 1
                    total += 1
        if total == 0:
            return {k: 0.0 for k in ELEMENT_KEYS}
        return {k: counts[k] / float(total) for k in ELEMENT_KEYS}

    def calculate_8_traits(self, saju: Dict[str, str]) -> Dict[str, float]:
        five = self.analyze_five_elements(saju)
        wood, fire, earth, metal, water = (
            five["wood"], five["fire"], five["earth"], five["metal"], five["water"]
        )
        # 단순 가중 합으로 8특성 도출(초기 버전)
        traits = {
            "passion": clamp01(0.7 * fire + 0.3 * wood),
            "intuition": clamp01(0.6 * water + 0.4 * wood),
            "mood_swing": clamp01(0.5 * water + 0.5 * fire),
            "courage": clamp01(0.6 * fire + 0.4 * metal),
            "responsibility": clamp01(0.6 * earth + 0.4 * metal),
            "conflict": clamp01(0.6 * metal + 0.4 * wood),
            "charisma": clamp01(0.7 * fire + 0.3 * earth),
            "independence": clamp01(0.6 * metal + 0.4 * water),
        }
        return traits

    def generate_personality_report(self, traits: Dict[str, float]) -> str:
        items: List[Tuple[str, float]] = sorted(traits.items(), key=lambda x: x[1], reverse=True)
        top = items[:3]
        return ", ".join([f"{k}:{v:.2f}" for k, v in top])


def clamp01(v: float) -> float:
    return 0.0 if v < 0 else 1.0 if v > 1 else v


