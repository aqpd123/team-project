-- ============================================
-- 사주 데이터베이스 테스트 쿼리 모음
-- ============================================
-- 사용법: SQLite 명령줄 또는 DB Browser for SQLite에서 실행
-- 데이터베이스 파일: app.db (프로젝트 루트)
-- ============================================

-- 1. 모든 사용자의 기본 정보 및 사주 데이터 존재 여부 확인
SELECT 
    user_id,
    username,
    email,
    character_type,
    birth_date,
    gender,
    CASE 
        WHEN saju_data IS NULL THEN 'NULL (사주 데이터 없음)'
        WHEN saju_data = '' THEN '빈 문자열'
        ELSE '데이터 있음 (' || LENGTH(saju_data) || ' bytes)'
    END AS saju_status,
    created_at
FROM users
ORDER BY user_id;

-- 2. 사주 데이터가 있는 사용자만 조회
SELECT 
    user_id,
    username,
    email,
    character_type,
    saju_data,
    created_at
FROM users
WHERE saju_data IS NOT NULL 
  AND saju_data != ''
ORDER BY user_id;

-- 3. 사주 데이터가 없는 사용자 조회
SELECT 
    user_id,
    username,
    email,
    character_type,
    created_at
FROM users
WHERE saju_data IS NULL 
   OR saju_data = ''
ORDER BY user_id;

-- 4. 특정 사용자 ID의 사주 데이터 상세 확인
-- (user_id를 실제 사용자 ID로 변경하여 사용)
SELECT 
    user_id,
    username,
    email,
    character_type,
    birth_date,
    gender,
    saju_data,
    LENGTH(saju_data) AS saju_data_length,
    created_at
FROM users
WHERE user_id = 1;  -- 여기에 확인할 사용자 ID 입력

-- 5. 사주 데이터의 JSON 구조 확인 (JSON이 유효한지 검증)
SELECT 
    user_id,
    username,
    saju_data,
    CASE 
        WHEN saju_data IS NULL THEN 'NULL'
        WHEN saju_data = '' THEN 'Empty'
        WHEN saju_data LIKE '{%' THEN 'JSON 형식으로 보임'
        ELSE 'JSON 형식 아님'
    END AS json_format_check
FROM users
WHERE saju_data IS NOT NULL 
  AND saju_data != '';

-- 6. 최근 가입한 사용자 중 사주 데이터가 있는 사용자
SELECT 
    user_id,
    username,
    email,
    character_type,
    CASE 
        WHEN saju_data IS NOT NULL AND saju_data != '' THEN '있음'
        ELSE '없음'
    END AS has_saju,
    created_at
FROM users
ORDER BY created_at DESC
LIMIT 10;

-- 7. 사용자별 사주 데이터 통계
SELECT 
    COUNT(*) AS total_users,
    COUNT(CASE WHEN saju_data IS NOT NULL AND saju_data != '' THEN 1 END) AS users_with_saju,
    COUNT(CASE WHEN saju_data IS NULL OR saju_data = '' THEN 1 END) AS users_without_saju,
    ROUND(COUNT(CASE WHEN saju_data IS NOT NULL AND saju_data != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS saju_percentage
FROM users;

-- 8. 사주 데이터의 평균 크기 및 최대/최소 크기
SELECT 
    COUNT(*) AS total_with_saju,
    AVG(LENGTH(saju_data)) AS avg_size_bytes,
    MIN(LENGTH(saju_data)) AS min_size_bytes,
    MAX(LENGTH(saju_data)) AS max_size_bytes
FROM users
WHERE saju_data IS NOT NULL 
  AND saju_data != '';

-- 9. 특정 이메일로 사용자 및 사주 데이터 확인
-- (email을 실제 이메일로 변경하여 사용)
SELECT 
    user_id,
    username,
    email,
    character_type,
    saju_data,
    created_at
FROM users
WHERE email = 'test@example.com';  -- 여기에 확인할 이메일 입력

-- 10. 사주 데이터 업데이트 테스트 (주의: 실제 데이터에 영향)
-- UPDATE users 
-- SET saju_data = '{"year_gan":"갑","year_ji":"자","month_gan":"을","month_ji":"축","day_gan":"병","day_ji":"인","time_gan":"정","time_ji":"묘"}'
-- WHERE user_id = 1;  -- 테스트용이므로 주석 처리

-- ============================================
-- 실행 방법:
-- ============================================
-- 1. SQLite 명령줄:
--    sqlite3 app.db < test_saju_db_queries.sql
--
-- 2. DB Browser for SQLite:
--    - File > Open Database > app.db 선택
--    - Execute SQL 탭에서 쿼리 실행
--
-- 3. Python 스크립트:
--    import sqlite3
--    conn = sqlite3.connect('app.db')
--    cursor = conn.cursor()
--    cursor.execute("SELECT * FROM users WHERE saju_data IS NOT NULL")
--    print(cursor.fetchall())
-- ============================================

