-- 쪽지 데이터베이스 확인 쿼리문

-- 1. 모든 쪽지 조회 (최신순)
SELECT 
    m.message_id,
    m.thread_key,
    m.sender_id,
    u1.username AS sender_name,
    m.recipient_id,
    u2.username AS recipient_name,
    m.content,
    m.is_read,
    m.created_at
FROM messages m
LEFT JOIN users u1 ON m.sender_id = u1.user_id
LEFT JOIN users u2 ON m.recipient_id = u2.user_id
ORDER BY m.created_at DESC;

-- 2. 특정 사용자가 보낸 쪽지 조회 (user_id를 실제 사용자 ID로 변경)
-- 예: user_id = 1인 사용자가 보낸 쪽지
SELECT 
    m.message_id,
    m.thread_key,
    m.recipient_id,
    u.username AS recipient_name,
    m.content,
    m.is_read,
    m.created_at
FROM messages m
LEFT JOIN users u ON m.recipient_id = u.user_id
WHERE m.sender_id = 1  -- 여기에 확인하고 싶은 사용자 ID 입력
ORDER BY m.created_at DESC;

-- 3. 특정 사용자가 받은 쪽지 조회 (user_id를 실제 사용자 ID로 변경)
-- 예: user_id = 1인 사용자가 받은 쪽지
SELECT 
    m.message_id,
    m.thread_key,
    m.sender_id,
    u.username AS sender_name,
    m.content,
    m.is_read,
    m.created_at
FROM messages m
LEFT JOIN users u ON m.sender_id = u.user_id
WHERE m.recipient_id = 1  -- 여기에 확인하고 싶은 사용자 ID 입력
ORDER BY m.created_at DESC;

-- 4. 특정 사용자의 모든 쪽지 (보낸 것 + 받은 것)
-- 예: user_id = 1인 사용자의 모든 쪽지
SELECT 
    m.message_id,
    m.thread_key,
    m.sender_id,
    u1.username AS sender_name,
    m.recipient_id,
    u2.username AS recipient_name,
    m.content,
    m.is_read,
    m.created_at,
    CASE 
        WHEN m.sender_id = 1 THEN '보낸 쪽지'
        ELSE '받은 쪽지'
    END AS message_type
FROM messages m
LEFT JOIN users u1 ON m.sender_id = u1.user_id
LEFT JOIN users u2 ON m.recipient_id = u2.user_id
WHERE m.sender_id = 1 OR m.recipient_id = 1  -- 여기에 확인하고 싶은 사용자 ID 입력
ORDER BY m.created_at DESC;

-- 5. thread_key별로 그룹화하여 대화 목록 확인
SELECT 
    m.thread_key,
    COUNT(*) AS message_count,
    MAX(m.created_at) AS last_message_time,
    MIN(m.created_at) AS first_message_time
FROM messages m
GROUP BY m.thread_key
ORDER BY last_message_time DESC;

-- 6. 익명 쪽지 확인 (thread_key가 'anonymous:'로 시작하는 것)
SELECT 
    m.message_id,
    m.thread_key,
    m.sender_id,
    u1.username AS sender_name,
    m.recipient_id,
    u2.username AS recipient_name,
    m.content,
    m.is_read,
    m.created_at,
    CASE 
        WHEN m.thread_key LIKE 'anonymous:%' THEN '익명 쪽지'
        ELSE '일반 쪽지'
    END AS message_type
FROM messages m
LEFT JOIN users u1 ON m.sender_id = u1.user_id
LEFT JOIN users u2 ON m.recipient_id = u2.user_id
WHERE m.thread_key LIKE 'anonymous:%'
ORDER BY m.created_at DESC;

-- 7. 읽지 않은 쪽지 개수 확인
SELECT 
    recipient_id,
    u.username AS recipient_name,
    COUNT(*) AS unread_count
FROM messages m
LEFT JOIN users u ON m.recipient_id = u.user_id
WHERE m.is_read = 0
GROUP BY recipient_id, u.username
ORDER BY unread_count DESC;

-- 8. 최근 24시간 내 쪽지 확인
SELECT 
    m.message_id,
    m.thread_key,
    m.sender_id,
    u1.username AS sender_name,
    m.recipient_id,
    u2.username AS recipient_name,
    m.content,
    m.is_read,
    m.created_at
FROM messages m
LEFT JOIN users u1 ON m.sender_id = u1.user_id
LEFT JOIN users u2 ON m.recipient_id = u2.user_id
WHERE m.created_at >= datetime('now', '-1 day')
ORDER BY m.created_at DESC;

-- 9. 쪽지 통계 (전체 개수, 읽은 것, 읽지 않은 것)
SELECT 
    COUNT(*) AS total_messages,
    SUM(CASE WHEN is_read = 1 THEN 1 ELSE 0 END) AS read_messages,
    SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END) AS unread_messages,
    COUNT(DISTINCT thread_key) AS total_threads
FROM messages;

-- 10. 특정 두 사용자 간의 대화 확인
-- 예: user_id 1과 user_id 2 간의 대화
SELECT 
    m.message_id,
    m.thread_key,
    m.sender_id,
    u1.username AS sender_name,
    m.recipient_id,
    u2.username AS recipient_name,
    m.content,
    m.is_read,
    m.created_at
FROM messages m
LEFT JOIN users u1 ON m.sender_id = u1.user_id
LEFT JOIN users u2 ON m.recipient_id = u2.user_id
WHERE (m.sender_id = 1 AND m.recipient_id = 2)  -- 여기에 확인하고 싶은 두 사용자 ID 입력
   OR (m.sender_id = 2 AND m.recipient_id = 1)
ORDER BY m.created_at ASC;


