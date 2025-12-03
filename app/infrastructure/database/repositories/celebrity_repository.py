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
        # 2000~2010 범위의 유명인 데이터 (원본 소스코드 지원 범위)
        seed: List[Dict[str, Any]] = [
            # 기존 유명인
            {
                "id": 1,
                "name": "이하린",
                "description": "차세대 K-POP 보컬리스트",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/celebrity1.jpg",
                "saju": {
                    "year_gan": "경",
                    "year_ji": "진",
                    "month_gan": "신",
                    "month_ji": "사",
                    "day_gan": "병",
                    "day_ji": "인",
                    "time_gan": "경",
                    "time_ji": "오",
                },
            },
            {
                "id": 2,
                "name": "강도윤",
                "description": "액션 장르로 주목받는 영화 배우",
                "category": "movie",
                "gender": 1,
                "thumbnail": "https://example.com/celebrity2.jpg",
                "saju": {
                    "year_gan": "신",
                    "year_ji": "사",
                    "month_gan": "신",
                    "month_ji": "묘",
                    "day_gan": "을",
                    "day_ji": "해",
                    "time_gan": "무",
                    "time_ji": "오",
                },
            },
            {
                "id": 3,
                "name": "서주민",
                "description": "세계 대회를 석권한 피겨 스타",
                "category": "sports",
                "gender": 0,
                "thumbnail": "https://example.com/celebrity3.jpg",
                "saju": {
                    "year_gan": "임",
                    "year_ji": "오",
                    "month_gan": "정",
                    "month_ji": "미",
                    "day_gan": "정",
                    "day_ji": "유",
                    "time_gan": "임",
                    "time_ji": "오",
                },
            },
            {
                "id": 4,
                "name": "유도현",
                "description": "글로벌 인디씬을 이끄는 싱어송라이터",
                "category": "music",
                "gender": 1,
                "thumbnail": "https://example.com/celebrity4.jpg",
                "saju": {
                    "year_gan": "계",
                    "year_ji": "미",
                    "month_gan": "신",
                    "month_ji": "유",
                    "day_gan": "갑",
                    "day_ji": "오",
                    "time_gan": "병",
                    "time_ji": "오",
                },
            },
            # 아이브 (IVE) 멤버
            {
                "id": 5,
                "name": "안유진",
                "description": "아이브(IVE) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/ive_an_yujin.jpg",
                "saju": {
                    "year_gan": "계",
                    "year_ji": "미",
                    "month_gan": "경",
                    "month_ji": "신",
                    "day_gan": "을",
                    "day_ji": "해",
                    "time_gan": "무",
                    "time_ji": "오",
                },
            },
            {
                "id": 6,
                "name": "가을",
                "description": "아이브(IVE) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/ive_gaeul.jpg",
                "saju": {
                    "year_gan": "임",
                    "year_ji": "오",
                    "month_gan": "기",
                    "month_ji": "유",
                    "day_gan": "계",
                    "day_ji": "사",
                    "time_gan": "갑",
                    "time_ji": "오",
                },
            },
            {
                "id": 7,
                "name": "레이",
                "description": "아이브(IVE) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/ive_rei.jpg",
                "saju": {
                    "year_gan": "갑",
                    "year_ji": "신",
                    "month_gan": "을",
                    "month_ji": "축",
                    "day_gan": "경",
                    "day_ji": "술",
                    "time_gan": "무",
                    "time_ji": "오",
                },
            },
            {
                "id": 8,
                "name": "장원영",
                "description": "아이브(IVE) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/ive_jang_wonyoung.jpg",
                "saju": {
                    "year_gan": "갑",
                    "year_ji": "신",
                    "month_gan": "임",
                    "month_ji": "신",
                    "day_gan": "경",
                    "day_ji": "진",
                    "time_gan": "무",
                    "time_ji": "오",
                },
            },
            {
                "id": 9,
                "name": "리즈",
                "description": "아이브(IVE) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/ive_liz.jpg",
                "saju": {
                    "year_gan": "갑",
                    "year_ji": "신",
                    "month_gan": "을",
                    "month_ji": "해",
                    "day_gan": "임",
                    "day_ji": "인",
                    "time_gan": "임",
                    "time_ji": "오",
                },
            },
            {
                "id": 10,
                "name": "이서",
                "description": "아이브(IVE) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/ive_leeseo.jpg",
                "saju": {
                    "year_gan": "정",
                    "year_ji": "해",
                    "month_gan": "임",
                    "month_ji": "인",
                    "day_gan": "갑",
                    "day_ji": "신",
                    "time_gan": "병",
                    "time_ji": "오",
                },
            },
            # 에스파 (aespa) 멤버
            {
                "id": 11,
                "name": "카리나",
                "description": "에스파(aespa) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/aespa_karina.jpg",
                "saju": {
                    "year_gan": "경",
                    "year_ji": "진",
                    "month_gan": "경",
                    "month_ji": "진",
                    "day_gan": "정",
                    "day_ji": "유",
                    "time_gan": "임",
                    "time_ji": "오",
                },
            },
            {
                "id": 12,
                "name": "지젤",
                "description": "에스파(aespa) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/aespa_giselle.jpg",
                "saju": {
                    "year_gan": "경",
                    "year_ji": "진",
                    "month_gan": "병",
                    "month_ji": "술",
                    "day_gan": "기",
                    "day_ji": "미",
                    "time_gan": "병",
                    "time_ji": "오",
                },
            },
            {
                "id": 13,
                "name": "윈터",
                "description": "에스파(aespa) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/aespa_winter.jpg",
                "saju": {
                    "year_gan": "신",
                    "year_ji": "사",
                    "month_gan": "무",
                    "month_ji": "자",
                    "day_gan": "임",
                    "day_ji": "술",
                    "time_gan": "임",
                    "time_ji": "오",
                },
            },
            {
                "id": 14,
                "name": "닝닝",
                "description": "에스파(aespa) 멤버",
                "category": "music",
                "gender": 0,
                "thumbnail": "https://example.com/aespa_ningning.jpg",
                "saju": {
                    "year_gan": "임",
                    "year_ji": "오",
                    "month_gan": "경",
                    "month_ji": "술",
                    "day_gan": "임",
                    "day_ji": "술",
                    "time_gan": "임",
                    "time_ji": "오",
                },
            },
        ]
        return {item["id"]: Celebrity(**item) for item in seed}


celebrity_repository = CelebrityRepository()
