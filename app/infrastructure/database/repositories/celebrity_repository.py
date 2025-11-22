from typing import Optional, Dict, Any, List

from app.domain.celebrity.models import Celebrity


class CelebrityRepository:
    """
    간단한 인메모리 저장소.
    실제 구현 시 DB/ORM으로 교체하면 됩니다.
    """

    def __init__(self) -> None:
        self._data = self._load_seed_data()

    def list(self, keyword: Optional[str] = None) -> List[Celebrity]:
        celebrities = list(self._data.values())
        if keyword:
            lower = keyword.lower()
            celebrities = [
                c for c in celebrities if lower in c.name.lower() or lower in c.category.lower()
            ]
        return celebrities

    def get_by_id(self, celebrity_id: int) -> Optional[Celebrity]:
        return self._data.get(celebrity_id)

    def _load_seed_data(self) -> Dict[int, Celebrity]:
        seed: List[Dict[str, Any]] = [
            {
                "id": 1,
                "name": "천은아",
                "description": "감성 발라드 가수",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/c1.jpg",
                "saju": {
                    "year_gan": "갑",
                    "year_ji": "자",
                    "month_gan": "을",
                    "month_ji": "축",
                    "day_gan": "병",
                    "day_ji": "인",
                },
            },
            {
                "id": 2,
                "name": "백운재",
                "description": "액션 영화 배우",
                "category": "movie",
                "gender": 1,
                "thumbnail": "https://example.com/c2.jpg",
                "saju": {
                    "year_gan": "정",
                    "year_ji": "미",
                    "month_gan": "무",
                    "month_ji": "신",
                    "day_gan": "기",
                    "day_ji": "유",
                },
            },
            {
                "id": 3,
                "name": "윤다솔",
                "description": "세계적인 피겨 스케이터",
                "category": "sports",
                "gender": 0,
                "thumbnail": "https://example.com/c3.jpg",
                "saju": {
                    "year_gan": "임",
                    "year_ji": "술",
                    "month_gan": "계",
                    "month_ji": "해",
                    "day_gan": "갑",
                    "day_ji": "자",
                },
            },
        ]
        return {item["id"]: Celebrity(**item) for item in seed}


celebrity_repository = CelebrityRepository()
