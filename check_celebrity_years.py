from app.domain.saju_core.calendar_converter import GanjiCalculator

calc = GanjiCalculator()

# 2000~2010 범위의 다양한 날짜로 사주 계산
dates = [
    (2000, 5, 10),   # 2000년
    (2001, 3, 15),   # 2001년
    (2002, 7, 30),   # 2002년
    (2003, 9, 20),   # 2003년
    (2004, 11, 5),   # 2004년
    (2005, 1, 20),   # 2005년
    (2006, 6, 12),   # 2006년
    (2007, 8, 25),   # 2007년
    (2008, 2, 14),   # 2008년
    (2009, 10, 3),   # 2009년
    (2010, 12, 31),  # 2010년
]

print("2000~2010 범위 사주 계산 결과:")
for i, (y, m, d) in enumerate(dates, 1):
    saju = calc.calculate(y, m, d, 12, 0)
    print(f"{i}. {y}년 {m}월 {d}일: {saju}")

