# 유명인 이미지 추가 가이드

## 1. 이미지 저장 위치

유명인 이미지를 다음 위치에 저장하세요:
```
FrontEnd/lastlast/assets/celebrities/
```

## 2. 파일명 규칙

각 유명인의 이미지 파일명은 다음과 같이 지정하세요:
- 장원영: `jang_wonyoung.jpg` (또는 `.png`)
- 김채원: `kim_chaewon.jpg`
- 민지: `minji.jpg`
- 하니: `hanni.jpg`
- 기타 유명인들도 동일한 규칙으로 저장

## 3. 이미지 파일 저장 후 해야 할 일

1. 이미지 파일을 `FrontEnd/lastlast/assets/celebrities/` 폴더에 저장
2. `pubspec.yaml`에 이미지 경로 등록 (자동으로 처리됨)
3. 백엔드 `celebrity_repository.py`의 `thumbnail` 필드 업데이트 (자동으로 처리됨)
4. Flutter 코드 수정 (자동으로 처리됨)

## 4. 현재 유명인 목록 (ID 기준)

- ID 1: 이하린
- ID 2: 김태리
- ID 3: 아이유
- ID 4: 수지
- ID 5: 제니
- ID 6: 지수
- ID 7: 로제
- ID 8: 장원영
- ID 9: 안유진
- ID 10: 가을
- ID 11: 레이
- ID 12: 리즈
- ID 13: 이서
- ID 14: 닝닝
- ID 15: 김채원
- ID 16: 민지
- ID 17: 하니

각 유명인의 이미지를 저장한 후, 파일명을 알려주시면 코드를 자동으로 업데이트하겠습니다.

