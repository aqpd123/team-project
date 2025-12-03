from app.domain.saju_core.calendar_converter import GanjiCalculator

calc = GanjiCalculator()
dates = [
    (2001, 3, 15),
    (2002, 7, 30),
    (2004, 11, 5),
    (2005, 1, 20),
]

for idx, (y, m, d) in enumerate(dates, 1):
    saju = calc.calculate(y, m, d, 12, 0)
    print(idx, y, m, d, saju)

