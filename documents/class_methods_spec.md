# 클래스/메서드 명세서 (다이어그램 기반 CSU)

본 문서는 `class_saju_core.puml`, `class_community.puml`, `class_celebrity.puml`에 표기된 메서드만을 대상으로, 구현자가 바로 사용할 수 있도록 간결한 역할 설명과 입출력 요약을 제공합니다.

---

## 1) saju_core 패키지

### 1.1 SajuCalculator
| ID | 메서드(시그니처 요약) | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_001 | get_birth_data(year, month, day) | Dict[str,str] | 입력 날짜를 검증·변환하여 연/월/일의 천간·지지를 계산해 사주 딕셔너리로 반환 |
| SAJU_CSU_002 | calculate_personal_traits(saju) | Dict[str,float] | 사주 기반 8가지 성격 특성 점수 계산 |
| SAJU_CSU_003 | calculate_compatibility(saju1, saju2, gender1, gender2) | Dict[str,float] | 두 사주의 궁합 점수(original/final/stress) 계산 |
| SAJU_CSU_004 | determine_character_type(saju) | str | 오행 분포로 대표 캐릭터(목/화/토/금/수) 결정 |
| SAJU_CSU_005 | calculate_personality_flags_hd2(saju, gender=0) | Dict[str,Any] | hd2 원본 규칙을 자기-자기 비교로 적용해 성향 플래그와 sal 원시값 추출(보조 지표) |
| SAJU_CSU_006 | analyze_personality(saju, gender=0) | Dict[str,Any] | 오행 분포, 8특성, hd2 플래그, 요약 리포트를 통합 반환 |

### 1.2 DataValidator
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_101 | validate_birth_date(year, month, day) | void | 날짜 형식·범위를 검증, 오류 시 예외 발생 |
| SAJU_CSU_102 | validate_saju_data(saju) | void | 사주 필수 키 존재·형식 검증 |

### 1.3 PersonalityAnalyzer
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_201 | analyze_five_elements(saju) | Dict[str,float] | 6요소(연/월/일의 천간·지지)에서 오행 빈도 산출·정규화 |
| SAJU_CSU_202 | calculate_8_traits(saju) | Dict[str,float] | 오행 분포를 가중합해 8가지 성격 특성 점수 계산 |

### 1.4 CharacterSystem
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_301 | get_character_info(type) | Dict[str,str] | 오행 캐릭터 이름/설명 조회 |
| SAJU_CSU_302 | get_personality_description(traits) | str | 8특성 점수 기반 사용자 친화 설명 생성 |

---

## 2) community 패키지

### 2.1 UserService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_001 | register_user(username, email, password) | User | 사용자 등록, 기본 캐릭터 타입/프로필 초기화 포함 |
| COM_CSU_002 | login_user(username, password) | Optional[User] | 자격 증명 확인 후 사용자 반환(실패 시 None) |

### 2.2 BoardService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_101 | create_post(user_id, title, content, board_type) | Post | 게시글 생성·저장 및 반환 |
| COM_CSU_102 | get_posts(board_type, page, limit) | List[Post] | 게시판별 게시글 목록 페이지네이션 조회(최신순) |

### 2.3 CompatibilityService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_201 | create_request(requester_id, target_id) | CompatibilityRequest | 궁합 확인 요청 생성(status=pending) |
| COM_CSU_202 | accept_request(request_id, target_id) | Optional[Dict[str,float]] | 요청 수락 처리, 두 사주 조회 후 궁합 계산·저장, 결과 반환 |

---

## 3) celebrity 패키지

### 3.1 CelebrityCompatibilityService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| CEL_CSU_001 | get_celebrity_list(page, limit) | List[Celebrity] | 유명인 목록 페이지네이션 조회 |
| CEL_CSU_002 | get_celebrity_by_id(id) | Optional[Celebrity] | ID로 유명인 단건 조회 |
| CEL_CSU_003 | calculate_compatibility(user_saju, celebrity_id) | Dict[str,float] | 사용자 사주와 유명인의 사주로 궁합 계산 |

---

## 4) 참고
- 본 명세의 파라미터/반환 타입은 다이어그램의 표기 및 기존 상세 명세(class_specification.md)를 따른 요약형입니다.
- 예외/검증 규칙, 내부 알고리즘 가중치 등 세부 구현은 `class_specification.md`와 `class_diagram_description.md`, `api_spec.md`를 함께 참고하세요.


