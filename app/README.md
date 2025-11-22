# 앱 스켈레톤 구조

```
app/
  api/                 # Flask 컨트롤러 & DTO
  domain/              # 도메인 로직 (saju_core, community, celebrity)
  infrastructure/      # DB, 저장소 등 인프라
  common/              # 공통 유틸/보안/예외
  main.py              # Flask 앱 팩토리
  config.py            # 환경설정
```

상세설계서의 클래스/패키지 구조에 맞춰 최소 뼈대를 제공합니다. 각 모듈은 메서드 시그니처만 정의되어 있으며, 구현은 단계적으로 채워넣으면 됩니다.


