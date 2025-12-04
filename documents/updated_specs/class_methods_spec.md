# 클래스/메서드 명세서 (실제 구현 기반)

본 문서는 실제 구현된 코드를 기반으로 작성된 클래스 및 메서드 명세서입니다.

---

## 1) saju_core 패키지

### 1.1 SajuCalculator
| ID | 메서드(시그니처 요약) | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_001 | get_birth_data(year, month, day, hour=12, minute=0) | Dict[str,Any] | 입력 날짜와 시간을 검증·변환하여 연/월/일의 천간·지지를 계산해 사주 딕셔너리로 반환 (lunar 정보 포함 가능) |
| SAJU_CSU_002 | calculate_personal_traits(saju) | Dict[str,Any] | 사주 기반 오행 분포, 8가지 성격 특성 점수, 리포트를 포함한 딕셔너리 반환 |
| SAJU_CSU_003 | calculate_compatibility(saju1, saju2, gender1, gender2) | Dict[str,float] | 두 사주의 궁합 점수(original/final/stress) 계산 |
| SAJU_CSU_004 | determine_character_type(saju) | str | 오행 분포로 대표 캐릭터(wood/fire/earth/metal/water) 결정 |
| SAJU_CSU_005 | calculate_personality_flags_hd2(saju, gender=0) | Dict[str,Any] | hd2 원본 규칙을 자기-자기 비교로 적용해 성향 플래그와 sal 원시값 추출(보조 지표) |
| SAJU_CSU_006 | analyze_personality(saju, gender=0) | Dict[str,Any] | 오행 분포, 8특성, hd2 플래그, 요약 리포트를 통합 반환 |

### 1.2 DataValidator
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_101 | validate_birth_date(year, month, day) | void | 날짜 형식·범위를 검증(2000~2010), 오류 시 예외 발생 |
| SAJU_CSU_102 | validate_saju_data(saju) | void | 사주 필수 키 존재·형식 검증 (천간/지지 유효성 확인) |

### 1.3 PersonalityAnalyzer
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_201 | analyze_five_elements(saju) | Dict[str,float] | 6요소(연/월/일의 천간·지지)에서 오행 빈도 산출·정규화 (wood/fire/earth/metal/water) |
| SAJU_CSU_202 | calculate_8_traits(saju) | Dict[str,float] | 오행 분포를 가중합해 8가지 성격 특성 점수 계산 |
| SAJU_CSU_203 | generate_personality_report(traits) | str | 8특성 점수를 정렬하여 상위 3개를 문자열로 반환 |

**8가지 성격 특성 (실제 구현)**:
- `passion`: 0.7 × fire + 0.3 × wood
- `intuition`: 0.6 × water + 0.4 × wood
- `mood_swing`: 0.5 × water + 0.5 × fire
- `courage`: 0.6 × fire + 0.4 × metal
- `responsibility`: 0.6 × earth + 0.4 × metal
- `conflict`: 0.6 × metal + 0.4 × wood
- `charisma`: 0.7 × fire + 0.3 × earth
- `independence`: 0.6 × metal + 0.4 × water

### 1.4 CharacterSystem
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| SAJU_CSU_301 | determine(five_elements_scores) | str | 오행 점수 딕셔너리에서 최댓값을 가진 오행(wood/fire/earth/metal/water) 반환 |

---

## 2) community 패키지

**참고**: UserService는 실제 구현에서 존재하지 않으며, 인증 관련 로직은 `auth_controller`에서 직접 `user_repository`를 사용하여 처리합니다.

### 2.1 CommunityService (구 BoardService)
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_101 | create_post(author_id, title, content, board_type) | int | 게시글 생성·저장 및 post_id 반환 |
| COM_CSU_102 | get_post(post_id, user_id) | Dict[str,Any] | 게시글 단건 조회 (댓글 목록, 좋아요 여부 포함) |
| COM_CSU_103 | list_posts(page, page_size) | List[Dict[str,Any]] | 게시글 목록 페이지네이션 조회(최신순) |
| COM_CSU_104 | list_my_posts(author_id, page, page_size) | List[Dict[str,Any]] | 특정 작성자의 게시글 목록 조회 |
| COM_CSU_105 | add_comment(post_id, author_id, content) | int | 댓글 추가 및 comment_id 반환 (anonymous_number 자동 계산) |
| COM_CSU_106 | toggle_like(post_id, user_id) | tuple[bool, int] | 좋아요 토글 (is_liked, like_count 반환) |
| COM_CSU_107 | update_post(post_id, user_id, title, content) | void | 게시글 수정 (작성자만 가능) |
| COM_CSU_108 | delete_post(post_id, user_id) | void | 게시글 삭제 (작성자만 가능) |

### 2.2 CompatibilityService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_201 | request_compatibility(requester_id, target_id, message) | int | 궁합 확인 요청 생성(status=pending), 친구 관계 검증 포함 |
| COM_CSU_202 | accept_compatibility(request_id, actor_id, accept) | Optional[Dict[str,Any]] | 요청 수락/거절 처리, 수락 시 두 사주 조회 후 궁합 계산·저장, 결과 반환 |
| COM_CSU_203 | get_request(request_id) | Dict[str,Any] | 궁합 요청 단건 조회 |
| COM_CSU_204 | calculate_for_users(user_id_1, user_id_2) | Dict[str,float] | 두 사용자의 궁합 직접 계산 |

### 2.3 FriendService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_301 | create_friendship_request(requester_id, addressee_id) | int | 친구 요청 생성 |
| COM_CSU_302 | respond_to_request(friendship_id, actor_id, accept) | Dict[str,Any] | 친구 요청 수락/거절 |
| COM_CSU_303 | list_friendships(user_id, status) | List[Dict[str,Any]] | 친구 관계 목록 조회 |
| COM_CSU_304 | delete_friendship(friendship_id, actor_id) | void | 친구 관계 삭제 |

### 2.4 MessageService
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| COM_CSU_401 | send_message(sender_id, recipient_id, content) | int | 쪽지 전송 및 message_id 반환 |
| COM_CSU_402 | get_threads(user_id, limit, offset) | List[Dict[str,Any]] | 최근 대화 목록 조회 |
| COM_CSU_403 | get_conversation(user_id, peer_id, limit, before_id) | List[Dict[str,Any]] | 특정 사용자와의 대화 조회 |
| COM_CSU_404 | mark_as_read(user_id, peer_id) | void | 대화 읽음 처리 |

---

## 3) celebrity 패키지

### 3.1 CelebrityService (구 CelebrityCompatibilityService)
| ID | 메서드 | 반환 | 설명 |
|---|---|---|---|
| CEL_CSU_001 | list_celebrities(keyword) | List[Dict[str,Any]] | 유명인 목록 조회 (키워드 검색 지원) |
| CEL_CSU_002 | get_celebrity(celebrity_id) | Dict[str,Any] | ID로 유명인 단건 조회 |
| CEL_CSU_003 | calculate_with_celebrity(user_saju, celebrity_id, user_gender, use_ai) | Dict[str,Any] | 사용자 사주와 유명인의 사주로 궁합 계산 (AI 인사이트 포함 가능) |
| CEL_CSU_004 | get_compatibility_description(scores) | str | 궁합 점수 기반 설명 문자열 생성 |

---

## 4) 참고
- 본 명세는 실제 구현된 코드를 기반으로 작성되었습니다.
- 예외/검증 규칙, 내부 알고리즘 가중치 등 세부 구현은 실제 코드를 참고하세요.
- API 엔드포인트는 `api_spec.md`를 참고하세요.

