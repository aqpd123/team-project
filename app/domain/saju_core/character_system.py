from typing import Dict


class CharacterSystem:
    def determine(self, five_elements_scores: Dict[str, float]) -> str:
        if not five_elements_scores:
            return "unknown"
        # 최댓값 오행을 캐릭터 타입으로 사용
        best = max(five_elements_scores, key=five_elements_scores.get)
        return best


