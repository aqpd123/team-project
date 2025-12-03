from typing import Optional, Dict, Any

from sqlalchemy import text

from app.infrastructure.database.db import db


class UserRepository:
    def __init__(self, database=db) -> None:
        self.database = database

    def create(
        self,
        username: str,
        email: str,
        password_hash: str,
        character_type: str | None = None,
        birth_date: str | None = None,
        gender: int | None = None,
        saju_data: str | None = None,
    ) -> int:
        with self.database.session() as session:
            result = session.execute(
                text(
                    """
                    INSERT INTO users (username, email, password_hash, character_type, birth_date, gender, saju_data)
                    VALUES (:username, :email, :password_hash, :character_type, :birth_date, :gender, :saju_data)
                    """
                ),
                {
                    "username": username,
                    "email": email,
                    "password_hash": password_hash,
                    "character_type": character_type,
                    "birth_date": birth_date,
                    "gender": gender,
                    "saju_data": saju_data,
                },
            )
            return int(result.lastrowid)

    def get_by_id(self, user_id: int) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text("SELECT * FROM users WHERE user_id = :user_id"),
                {"user_id": user_id},
            ).mappings().first()
            return dict(row) if row else None

    def get_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        with self.database.session() as session:
            row = session.execute(
                text("SELECT * FROM users WHERE email = :email"),
                {"email": email},
            ).mappings().first()
            return dict(row) if row else None

    def list(self, page: int = 1, page_size: int = 20) -> list[Dict[str, Any]]:
        offset = max(page - 1, 0) * page_size
        with self.database.session() as session:
            rows = session.execute(
                text(
                    """
                    SELECT * FROM users
                    ORDER BY created_at DESC
                    LIMIT :limit OFFSET :offset
                    """
                ),
                {"limit": page_size, "offset": offset},
            ).mappings().all()
            return [dict(row) for row in rows]

    def update_saju_info(
        self,
        user_id: int,
        character_type: str | None = None,
        birth_date: str | None = None,
        gender: int | None = None,
        saju_data: str | None = None,
    ) -> None:
        """사용자의 사주 정보 업데이트"""
        updates = []
        params = {"user_id": user_id}
        
        if character_type is not None:
            updates.append("character_type = :character_type")
            params["character_type"] = character_type
        
        if birth_date is not None:
            updates.append("birth_date = :birth_date")
            params["birth_date"] = birth_date
        
        if gender is not None:
            updates.append("gender = :gender")
            params["gender"] = gender
        
        if saju_data is not None:
            updates.append("saju_data = :saju_data")
            params["saju_data"] = saju_data
        
        if not updates:
            return  # 업데이트할 항목이 없으면 종료
        
        with self.database.session() as session:
            session.execute(
                text(
                    f"""
                    UPDATE users
                    SET {', '.join(updates)}
                    WHERE user_id = :user_id
                    """
                ),
                params,
            )


user_repository = UserRepository()
