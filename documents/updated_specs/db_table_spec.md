# 데이터베이스 테이블 명세 (실제 구현 기반)

본 문서는 실제 구현된 데이터베이스 스키마를 기준으로 각 테이블의 컬럼, 타입, 길이, 제약조건, 설명을 정리한 표입니다.

## USERS (User)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| user_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 사용자 고유 ID |
| username | VARCHAR | 50 | UNIQUE, NOT NULL | 사용자명 |
| email | VARCHAR | 120 | UNIQUE, NOT NULL | 이메일 |
| password_hash | VARCHAR | 255 | NOT NULL | 비밀번호 해시 |
| character_type | VARCHAR | 10 | - | 오행 캐릭터 타입(wood/fire/earth/metal/water) |
| birth_date | DATETIME | - | - | 생년월일 |
| gender | INT | - | - | 성별(0=여자, 1=남자) |
| saju_data | TEXT | - | - | 사주 데이터(JSON/TEXT) |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |

## POSTS (Post)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| post_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 게시글 ID |
| author_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 작성자 ID |
| title | VARCHAR | 150 | NOT NULL | 제목 |
| content | TEXT | - | NOT NULL | 내용 |
| board_type | VARCHAR | 50 | - | 게시판 타입 |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |
| updated_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP | 수정 시각 |
| view_count | INT | - | DEFAULT 0 | 조회수 |
| like_count | INT | - | DEFAULT 0 | 좋아요 수 |

## COMMENTS (Comment)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| comment_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 댓글 ID |
| post_id | INT | - | FOREIGN KEY → POSTS(post_id), NOT NULL | 게시글 ID |
| author_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 작성자 ID |
| content | TEXT | - | NOT NULL | 댓글 내용 |
| anonymous_number | INT | - | - | 게시물 단위로 순차적으로 부여되는 익명 번호 |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |
| updated_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP | 수정 시각 |

## POST_LIKES (PostLike)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| like_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 좋아요 ID |
| post_id | INT | - | FOREIGN KEY → POSTS(post_id), NOT NULL | 게시글 ID |
| user_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 사용자 ID |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |
| (post_id, user_id) | - | - | UNIQUE | 게시글-사용자 조합 유니크 제약 |

## COMPATIBILITY_REQUESTS (CompatibilityRequest)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| request_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 궁합 요청 ID |
| requester_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 요청자 ID |
| target_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 대상자 ID |
| status | VARCHAR | 20 | DEFAULT 'pending' | 요청 상태(pending/accepted/rejected) |
| request_message | TEXT | - | - | 요청 메시지 |
| result_original | FLOAT | - | - | 원본 알고리즘 점수 |
| result_final | FLOAT | - | - | 가중/보정 적용 최종 점수 |
| stress | FLOAT | - | - | 관계 스트레스 지표 |
| compatibility_result | TEXT | - | - | 결과 JSON/설명 |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |
| responded_at | DATETIME | - | - | 응답 시각(수락/거절) |

## FRIENDSHIPS (Friendship)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| friendship_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 친구 관계 ID |
| requester_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 요청자 ID |
| addressee_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 수신자 ID |
| status | VARCHAR | 20 | NOT NULL, DEFAULT 'pending' | 관계 상태(pending/accepted/rejected/cancelled/deleted) |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |
| responded_at | DATETIME | - | - | 응답 시각 |
| (requester_id, addressee_id) | - | - | UNIQUE | 요청자-수신자 조합 유니크 제약 |

## CELEBRITIES (Celebrity)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| celebrity_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 유명인 ID |
| name | VARCHAR | 120 | NOT NULL | 이름 |
| birth_date | DATETIME | - | - | 생년월일 |
| character_type | VARCHAR | 10 | - | 오행 캐릭터 타입 |
| saju_data | TEXT | - | - | 사주 데이터(JSON/TEXT) |
| profile_image_url | VARCHAR | 255 | - | 프로필 이미지 URL |

**참고**: 실제 Celebrity 모델에는 `description`, `category`, `gender`, `thumbnail` 필드가 있지만, 데이터베이스 테이블에는 저장되지 않고 애플리케이션 레벨에서 관리됩니다.

## CHARACTER_INFO (CharacterInfo)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| character_type | VARCHAR | 10 | PRIMARY KEY, NOT NULL | 캐릭터 타입 키(목/화/토/금/수) |
| name | VARCHAR | 50 | - | 캐릭터 이름 |
| description | TEXT | - | - | 캐릭터 설명 |

## COMPATIBILITY_RESULTS (CompatibilityResult)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| result_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 결과 ID |
| type_1 | VARCHAR | 10 | NOT NULL | 캐릭터/타입 1 |
| type_2 | VARCHAR | 10 | NOT NULL | 캐릭터/타입 2 |
| content | TEXT | - | - | 타입 조합 설명 |
| score | FLOAT | - | - | 권장 점수(룰 기반) |
| (type_1, type_2) | - | - | UNIQUE | 타입 조합 유니크 제약 |

## NOTIFICATIONS (Notification)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| notification_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 알림 ID |
| user_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 수신자 사용자 ID |
| type | VARCHAR | 50 | NOT NULL | 알림 유형(예: post_created, comment_created, compatibility_requested 등) |
| payload | TEXT | - | - | 알림 데이터(JSON/TEXT) |
| is_read | BOOLEAN | - | DEFAULT FALSE | 읽음 여부 |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |

## MESSAGES (Message)

| 컬럼명 | 데이터 타입 | 길이 | 제약 조건 | 설명 |
|---|---|---|---|---|
| message_id | INT | - | PRIMARY KEY, NOT NULL, AUTO_INCREMENT | 쪽지 ID |
| thread_key | VARCHAR | 50 | NOT NULL, INDEX | 대화 스레드 키 (sender_id와 recipient_id를 정렬하여 생성) |
| sender_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 발신자 ID |
| recipient_id | INT | - | FOREIGN KEY → USERS(user_id), NOT NULL | 수신자 ID |
| content | TEXT | - | NOT NULL | 쪽지 내용 |
| is_read | BOOLEAN | - | DEFAULT FALSE | 읽음 여부 |
| created_at | DATETIME | - | DEFAULT CURRENT_TIMESTAMP | 생성 시각 |

---

## 참고사항

- VARCHAR 길이는 실제 구현에 맞춰 설정되었습니다.
- `saju_data`, `compatibility_result`, `payload`, `content` 등 문서/구조화 데이터는 TEXT 타입을 사용합니다.
- 시간 기본값은 `CURRENT_TIMESTAMP`를 사용합니다 (MySQL/SQLite 공통).
- `updated_at` 컬럼은 `ON UPDATE CURRENT_TIMESTAMP`를 사용하여 자동 업데이트됩니다.
- 실제 구현에서는 SQLAlchemy ORM을 사용하며, 위 스키마는 SQLAlchemy Table 정의를 기반으로 작성되었습니다.

