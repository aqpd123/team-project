from app.domain.celebrity.services.celebrity_service import CelebrityService


def test_get_and_calculate_types() -> None:
    svc = CelebrityService()
    c = svc.get_celebrity(celebrity_id=1)
    assert isinstance(c, dict)
    sample_saju = {
        "year_gan": "갑",
        "year_ji": "자",
        "month_gan": "을",
        "month_ji": "축",
        "day_gan": "병",
        "day_ji": "인",
    }
    out = svc.calculate_with_celebrity(user_saju=sample_saju, celebrity_id=1)
    assert isinstance(out, dict)
    assert "celebrity" in out and "scores" in out


