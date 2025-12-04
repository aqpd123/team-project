from __future__ import annotations

import math
from pathlib import Path
from typing import Dict, Tuple, Optional

import numpy as np

from app.common.exceptions import ValidationError
from .utils import HEAVENLY_STEMS, EARTHLY_BRANCHES


class GanjiCalculator:
    """
    hd2.ipynb 의 cal.csv, 24절기 전환 규칙을 그대로 사용하여
    연·월 천간/지지를 계산하고, 일주는 Julian Day 기반의 60갑자로 산출한다.
    """

    def __init__(self, calendar_file: Optional[str] = None) -> None:
        root = Path(__file__).resolve().parents[3]
        default_path = root / "source" / "cal.csv"
        self.calendar_file = Path(calendar_file) if calendar_file else default_path
        self._calendar: Optional[np.ndarray] = None

    def calculate(self, year: int, month: int, day: int, hour: int = 12, minute: int = 0) -> Dict[str, str]:
        self._ensure_range(year)
        ys, yg, ms, mg = self._calc_year_month(year, month, day, hour, minute)
        day_stem_idx, day_branch_idx = self._sexagenary_day(year, month, day)
        time_branch_idx = self._calculate_hour_branch(hour, minute)
        time_stem_idx = self._calculate_hour_stem(day_stem_idx + 1, time_branch_idx)

        return {
            "year_gan": HEAVENLY_STEMS[ys - 1],
            "year_ji": EARTHLY_BRANCHES[yg - 1],
            "month_gan": HEAVENLY_STEMS[ms - 1],
            "month_ji": EARTHLY_BRANCHES[mg - 1],
            "day_gan": HEAVENLY_STEMS[day_stem_idx],
            "day_ji": EARTHLY_BRANCHES[day_branch_idx],
            "time_gan": HEAVENLY_STEMS[time_stem_idx - 1],
            "time_ji": EARTHLY_BRANCHES[time_branch_idx - 1],
        }

    # ----- hd2 기반 연·월 계산 -----
    def _calc_year_month(self, year: int, month: int, day: int, hour: int, minute: int) -> Tuple[int, int, int, int]:
        row = self._calendar_row(year)
        ints = row.astype(int)

        n1 = year * 100 + month
        n2 = day * 10000 + hour * 100 + minute

        (
            b_y,
            c_y,
            d_y,
            e_y,
            f_y,
            g_y,
            h_y,
            i_y,
            j_y,
            k_y,
            l_y,
            m_y,
            n_y,
            o_y,
            p_y,
            q_y,
            r_y,
            s_y,
            t_y,
            u_y,
            v_y,
            w_y,
            x_y,
            y_y,
        ) = ints[1:]

        # Year stem
        ry = (year - 1904) % 10
        ys = ry + 1
        if n1 < d_y or (n1 == d_y and n2 < e_y):
            ys -= 1
        if ys <= 0:
            ys += 10

        # Year branch
        yg = ((year - 4) % 12) + 1
        if n1 < d_y or (n1 == d_y and n2 < e_y):
            yg -= 1
        if yg <= 0:
            yg += 12

        # Month branch boundaries
        mg = self._calc_month_branch(
            n1,
            n2,
            [
                (self._adjust_month_value(b_y, year), c_y, 11, 12),
                (self._adjust_month_value(d_y, year), e_y, 12, 1),
                (self._adjust_month_value(f_y, year), g_y, 1, 2),
                (self._adjust_month_value(h_y, year), i_y, 2, 3),
                (self._adjust_month_value(j_y, year), k_y, 3, 4),
                (self._adjust_month_value(l_y, year), m_y, 4, 5),
                (self._adjust_month_value(n_y, year), o_y, 5, 6),
                (self._adjust_month_value(p_y, year), q_y, 6, 7),
                (self._adjust_month_value(r_y, year), s_y, 7, 8),
                (self._adjust_month_value(t_y, year), u_y, 8, 9),
                (self._adjust_month_value(v_y, year), w_y, 9, 10),
                (self._adjust_month_value(x_y, year), y_y, 10, 11),
            ],
        )

        # Month stem mapping (hd2 규칙)
        if ys in (1, 6):
            ms = 3 + (mg - 1)
        elif ys in (2, 7):
            ms = 5 + (mg - 1)
        elif ys in (3, 8):
            ms = 7 + (mg - 1)
        elif ys in (4, 9):
            ms = 9 + (mg - 1)
        else:  # ys in (5, 10)
            ms = 1 + (mg - 1)
        ms = ((ms - 1) % 10) + 1

        # hd2 post-adjustment (월지는 hd2 규칙 유지, 연지는 천간 계산 기준에 맞춰 보정)
        yg = ((yg - 1) % 12) + 1
        mg = ((mg + 1) % 12) + 1

        return ys, yg, ms, mg

    def _calc_month_branch(
        self,
        n1: int,
        n2: int,
        boundaries: list[Tuple[int, int, int, int]],
    ) -> int:
        for month_start, time_boundary, before_value, after_value in boundaries:
            if n1 == month_start:
                return before_value if n2 < time_boundary else after_value
            if n1 == month_start + 100:  # safeguard, though hd2 데이터는 해당 없음
                return before_value
        raise ValidationError("달력 데이터에서 월 정보를 찾을 수 없습니다.")

    def _adjust_month_value(self, base_value: int, year: int) -> int:
        month = base_value % 100
        return year * 100 + month

    # ----- 일주 계산 -----
    def _sexagenary_day(self, year: int, month: int, day: int) -> Tuple[int, int]:
        jdn = self._julian_day(year, month, day)
        index = (jdn + 47) % 60  # 1984-02-02 = 갑자 (index 0)
        stem_idx = index % 10
        branch_idx = index % 12
        return stem_idx, branch_idx

    @staticmethod
    def _calculate_hour_branch(hour: int, minute: int) -> int:
        hour = hour % 24
        slot = ((hour + 1) // 2) + 1
        if slot > 12:
            slot -= 12
        return slot

    @staticmethod
    def _calculate_hour_stem(day_stem_index: int, hour_branch_index: int) -> int:
        start_map = {
            1: 1, 6: 1,
            2: 3, 7: 3,
            3: 5, 8: 5,
            4: 7, 9: 7,
            5: 9, 10: 9,
        }
        start = start_map.get(day_stem_index, 1)
        idx = start + (hour_branch_index - 1) * 2
        idx = ((idx - 1) % 10) + 1
        return idx

    @staticmethod
    def _julian_day(year: int, month: int, day: int) -> int:
        a = (14 - month) // 12
        y = year + 4800 - a
        m = month + 12 * a - 3
        return (
            day
            + ((153 * m) + 2) // 5
            + 365 * y
            + y // 4
            - y // 100
            + y // 400
            - 32045
        )

    def _ensure_range(self, year: int) -> None:
        if year < 2000 or year > 2010:
            raise ValidationError("지원하지 않는 연도입니다. (2000~2010)")

    def _calendar_row(self, year: int) -> np.ndarray:
        if self._calendar is None:
            if not self.calendar_file.exists():
                raise ValidationError(f"달력 데이터 파일을 찾을 수 없습니다: {self.calendar_file}")
            self._calendar = np.loadtxt(
                self.calendar_file,
                delimiter=",",
                skiprows=1,
                encoding="euc-kr",
            )
        index = year - 1904
        if index < 0 or index >= len(self._calendar):
            raise ValidationError("달력 데이터 범위를 벗어났습니다.")
        return self._calendar[index]


__all__ = ["GanjiCalculator"]


