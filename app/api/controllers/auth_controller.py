from __future__ import annotations

import json
from typing import Any, Dict

from flask import Blueprint, jsonify, request
from werkzeug.security import check_password_hash, generate_password_hash

from app.common.security.auth import generate_jwt
from app.infrastructure.database.repositories.user_repository import user_repository
from app.common.schemas import (
    RegisterSchema,
    LoginSchema,
    load_json,
)
from app.common.exceptions import ValidationError

bp = Blueprint("auth", __name__, url_prefix="/auth")


def _sanitize_user(user: Dict[str, Any]) -> Dict[str, Any]:
    user = dict(user)
    user.pop("password_hash", None)
    if user.get("saju_data"):
        try:
            user["saju"] = json.loads(user.pop("saju_data"))
        except json.JSONDecodeError:
            user["saju"] = None
    else:
        user.pop("saju_data", None)
    return user


@bp.post("/register")
def register():
    try:
        payload = load_json(RegisterSchema, request.get_json(silent=True))
    except ValidationError as exc:
        return jsonify({"error": str(exc)}), 400

    if user_repository.get_by_email(payload["email"]):
        return jsonify({"error": "이미 등록된 이메일입니다."}), 409

    password_hash = generate_password_hash(payload["password"])
    saju_data = payload.get("saju")
    saju_json = json.dumps(saju_data, ensure_ascii=False) if saju_data else None

    user_id = user_repository.create(
        username=payload["username"],
        email=payload["email"],
        password_hash=password_hash,
        character_type=payload.get("character_type"),
        birth_date=None,
        gender=payload.get("gender"),
        saju_data=saju_json,
    )
    user = user_repository.get_by_id(user_id)
    return jsonify({"user": _sanitize_user(user)}), 201


@bp.post("/login")
def login():
    try:
        payload = load_json(LoginSchema, request.get_json(silent=True))
    except ValidationError as exc:
        return jsonify({"error": str(exc)}), 400

    user = user_repository.get_by_email(payload["email"])
    if not user or not check_password_hash(user["password_hash"], payload["password"]):
        return jsonify({"error": "이메일 또는 비밀번호가 올바르지 않습니다."}), 401

    token = generate_jwt({"user_id": user["user_id"], "email": user["email"]})
    return jsonify({"token": token, "user": _sanitize_user(user)})


