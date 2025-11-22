# 데이터베이스 테이블 명세

본 문서는 현재 `DB table.puml`에 정의된 스키마를 기준으로 각 테이블의 컬럼, 타입, 길이, 제약조건, 설명을 정리한 표입니다. 길이는 명시되지 않은 경우 `-`로 표기했습니다.

## USERS (User)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| user_id | INT | - | PRIMARY KEY, NOT NULL | 사용자 고유 ID |
| username | VARCHAR | - | UNIQUE, NOT NULL | 사용자명 |
| email | VARCHAR | - | UNIQUE, NOT NULL | 이메일 |
| password_hash | VARCHAR | - | NOT NULL | 비밀번호 해시 |
| character_type | VARCHAR | - | - | 오행 캐릭터 타입(목/화/토/금/수) |
| birth_date | DATE | - | - | 생년월일 |
| gender | INT | - | - | 성별(0/1 등 규약) |
| saju_data | TEXT | - | - | 사주 데이터(JSON/TEXT) |

## POSTS (Post)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| post_id | INT | - | PRIMARY KEY, NOT NULL | 게시글 ID |
| author_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 작성자 ID |
| title | VARCHAR | - | NOT NULL | 제목 |
| content | TEXT | - | NOT NULL | 내용 |
| board_type | VARCHAR | - | - | 게시판 타입 |
| created_at | DATETIME | - | DEFAULT NOW | 생성 시각 |
| updated_at | DATETIME | - | - | 수정 시각 |
| view_count | INT | - | DEFAULT 0 | 조회수 |
| like_count | INT | - | DEFAULT 0 | 좋아요 수 |

## COMMENTS (Comment)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| comment_id | INT | - | PRIMARY KEY, NOT NULL | 댓글 ID |
| post_id | INT | - | FOREIGN KEY → POSTS(post_id), NOT NULL | 게시글 ID |
| author_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 작성자 ID |
| content | TEXT | - | NOT NULL | 댓글 내용 |
| created_at | DATETIME | - | DEFAULT NOW | 생성 시각 |
| updated_at | DATETIME | - | - | 수정 시각 |

## COMPATIBILITY_REQUESTS (CompatibilityRequest)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| request_id | INT | - | PRIMARY KEY, NOT NULL | 궁합 요청 ID |
| requester_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 요청자 ID |
| target_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 대상자 ID |
| status | VARCHAR | - | DEFAULT 'pending' | 요청 상태(pending/accepted/rejected) |
| result_original | FLOAT | - | - | 원본 알고리즘 점수 |
| result_final | FLOAT | - | - | 가중/보정 적용 최종 점수 |
| stress | FLOAT | - | - | 관계 스트레스 지표 |
| compatibility_result | TEXT | - | - | 결과 JSON/설명 |
| created_at | DATETIME | - | DEFAULT NOW | 생성 시각 |
| responded_at | DATETIME | - | - | 응답 시각(수락/거절) |

## CELEBRITIES (Celebrity)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| celebrity_id | INT | - | PRIMARY KEY, NOT NULL | 유명인 ID |
| name | VARCHAR | - | NOT NULL | 이름 |
| birth_date | DATETIME | - | - | 생년월일 |
| character_type | VARCHAR | - | - | 오행 캐릭터 타입 |
| saju_data | TEXT | - | - | 사주 데이터(JSON/TEXT) |
| profile_image_url | VARCHAR | - | - | 프로필 이미지 URL |

## CHARACTER_INFO (CharacterInfo)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| character_type | VARCHAR | - | PRIMARY KEY, NOT NULL | 캐릭터 타입 키(목/화/토/금/수) |
| name | VARCHAR | - | - | 캐릭터 이름 |
| description | TEXT | - | - | 캐릭터 설명 |

## COMPATIBILITY_RESULTS (CompatibilityResult)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| result_id | INT | - | PRIMARY KEY, NOT NULL | 결과 사전(ID) |
| type_1 | VARCHAR | - | NOT NULL | 캐릭터/타입 1 |
| type_2 | VARCHAR | - | NOT NULL | 캐릭터/타입 2 |
| content | TEXT | - | - | 타입 조합 설명 |
| score | FLOAT | - | - | 권장 점수(룰 기반) |
| (type_1, type_2) | - | - | UNIQUE | 타입 조합 유니크 제약 |

## NOTIFICATIONS (Notification)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| notification_id | INT | - | PRIMARY KEY, NOT NULL | 알림 ID |
| user_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 수신자 사용자 ID |
| type | VARCHAR | - | NOT NULL | 알림 유형(예: request.accept 등) |
| payload | TEXT | - | - | 알림 데이터(JSON/TEXT) |
| is_read | BOOLEAN | - | DEFAULT FALSE | 읽음 여부 |
| created_at | DATETIME | - | DEFAULT NOW | 생성 시각 |

---

참고:
- VARCHAR 길이는 구현 DBMS에 맞춰 `username/email/title` 등에 적절히 부여하시기 바랍니다(예: 50/100/150 등). 
- `saju_data`, `compatibility_result`, `payload`, `content` 등 문서/구조화 데이터는 TEXT 또는 JSON 타입 사용을 권장합니다(DBMS 지원 시 JSON 권장).
- 시간 기본값(NOW/현재시각) 표현은 사용하는 DBMS에 맞게 설정하세요(MySQL: `CURRENT_TIMESTAMP`, SQLite: `CURRENT_TIMESTAMP` 등).


