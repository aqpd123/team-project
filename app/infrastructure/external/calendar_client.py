from __future__ import annotations

import os
import xml.etree.ElementTree as ET
from typing import Any, Dict, Optional

import requests

from app.common.exceptions import ValidationError
from app.config import Config


class LunarCalendarClient:
    """정부 공공데이터포털 음양력 변환 API 클라이언트."""

    BASE_URL = (
        "http://apis.data.go.kr/B090041/openapi/service"
        "/LrsrCldInfoService/getLunCalInfo"
    )

    def __init__(
        self,
        api_key: Optional[str] = None,
        session: Optional[requests.Session] = None,
        timeout: float = 5.0,
    ) -> None:
        self.api_key = api_key or os.getenv("LUNAR_API_KEY") or Config.LUNAR_API_KEY
        if not self.api_key:
            raise RuntimeError("LUNAR_API_KEY가 설정되지 않았습니다.")
        self.session = session or requests.Session()
        self.timeout = timeout

    def convert_solar_to_lunar(self, year: int, month: int, day: int) -> Dict[str, Any]:
        params = {
            "serviceKey": self.api_key,
            "solYear": str(year),
            "solMonth": f"{int(month):02d}",
            "solDay": f"{int(day):02d}",
        }
        try:
            response = self.session.get(
                self.BASE_URL, params=params, timeout=self.timeout
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise ValidationError("음양력 API 호출에 실패했습니다.") from exc

        try:
            root = ET.fromstring(response.text)
        except ET.ParseError as exc:
            raise ValidationError("음양력 API 응답을 파싱할 수 없습니다.") from exc

        item = root.find(".//item")
        if item is None:
            raise ValidationError("음양력 정보를 찾을 수 없습니다.")

        def _text(tag: str, default: str = "") -> str:
            node = item.find(tag)
            return node.text if node is not None else default

        lunar = {
            "year": _text("lunYear"),
            "month": _text("lunMonth"),
            "day": _text("lunDay"),
            "is_leap": _text("lunLeapYn") == "Y",
        }
        solar = {
            "year": _text("solYear") or str(year),
            "month": _text("solMonth") or f"{int(month):02d}",
            "day": _text("solDay") or f"{int(day):02d}",
        }
        return {"solar": solar, "lunar": lunar}


__all__ = ["LunarCalendarClient"]


