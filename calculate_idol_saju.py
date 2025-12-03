from app.domain.saju_core.calendar_converter import GanjiCalculator

calc = GanjiCalculator()

# 아이브 멤버 생년월일 (2000~2010 범위)
ive_members = [
    ("안유진", 2003, 9, 1),
    ("가을", 2002, 9, 24),
    ("레이", 2004, 2, 3),
    ("장원영", 2004, 8, 31),
    ("리즈", 2004, 11, 21),
    ("이서", 2007, 2, 21),
]

# 에스파 멤버 생년월일 (2000~2010 범위)
aespa_members = [
    ("카리나", 2000, 4, 11),
    ("지젤", 2000, 10, 30),
    ("윈터", 2001, 1, 1),
    ("닝닝", 2002, 10, 23),
]

print("=== 아이브 (IVE) 멤버 사주 ===")
for name, y, m, d in ive_members:
    saju = calc.calculate(y, m, d, 12, 0)
    print(f"{name} ({y}년 {m}월 {d}일): {saju}")

print("\n=== 에스파 (aespa) 멤버 사주 ===")
for name, y, m, d in aespa_members:
    saju = calc.calculate(y, m, d, 12, 0)
    print(f"{name} ({y}년 {m}월 {d}일): {saju}")

