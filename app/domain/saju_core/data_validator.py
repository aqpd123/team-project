from datetime import date
from typing import Dict

from app.common.exceptions import ValidationError

from .utils import HEAVENLY_STEMS, EARTHLY_BRANCHES


class DataValidator:
    def validate_birth_date(self, year: int, month: int, day: int) -> None:
        if not (1900 <= year <= 2100):
            raise ValidationError("연도는 1900~2100 범위여야 합니다.")
        if not (1 <= month <= 12):
            raise ValidationError("월은 1~12 범위여야 합니다.")
        if not (1 <= day <= 31):
            raise ValidationError("일은 1~31 범위여야 합니다.")
        try:
            date(year, month, day)
        except ValueError as exc:
            raise ValidationError("유효하지 않은 날짜입니다.") from exc

    def validate_saju_data(self, saju: Dict[str, str]) -> None:
        if not isinstance(saju, dict) or not saju:
            raise ValidationError("사주 데이터가 비어있습니다.")
        required = ("year_gan", "year_ji", "month_gan", "month_ji", "day_gan", "day_ji")
        missing = [k for k in required if k not in saju or not saju[k]]
        if missing:
            raise ValidationError(f"사주 필드 누락: {', '.join(missing)}")

        stem_fields = ("year_gan", "month_gan", "day_gan")
        branch_fields = ("year_ji", "month_ji", "day_ji")
        for field in stem_fields:
            if saju[field] not in HEAVENLY_STEMS:
                raise ValidationError(f"유효하지 않은 천간 값({field}): {saju[field]}")
        for field in branch_fields:
            if saju[field] not in EARTHLY_BRANCHES:
                raise ValidationError(f"유효하지 않은 지지 값({field}): {saju[field]}")


__all__ = ["DataValidator"]

