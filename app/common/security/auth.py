from __future__ import annotations

import os
import time
from functools import wraps
from typing import Callable, Dict, Any, Optional, TypeVar, cast

import jwt
from flask import current_app, request, g, jsonify
from jwt import ExpiredSignatureError, InvalidTokenError

from app.common.exceptions import AuthenticationError

Handler = TypeVar("Handler", bound=Callable[..., Any])


def _secret_key() -> str:
    secret = current_app.config.get("SECRET_KEY") or os.getenv("SECRET_KEY")
    if not secret:
        raise RuntimeError("SECRET_KEY 설정이 필요합니다.")
    return secret


def generate_jwt(payload: Dict[str, Any], expires_in: int = 2592000) -> str:  # 기본 30일 (2592000초)
    now = int(time.time())
    claims = payload.copy()
    claims.setdefault("iat", now)
    claims.setdefault("exp", now + expires_in)
    return jwt.encode(claims, _secret_key(), algorithm="HS256")


def verify_jwt(token: str) -> Dict[str, Any]:
    try:
        return cast(Dict[str, Any], jwt.decode(token, _secret_key(), algorithms=["HS256"]))
    except ExpiredSignatureError as exc:
        raise AuthenticationError("토큰이 만료되었습니다.") from exc
    except InvalidTokenError as exc:
        raise AuthenticationError("유효하지 않은 토큰입니다.") from exc


def _extract_token() -> str:
    auth_header = request.headers.get("Authorization", "")
    if auth_header.startswith("Bearer "):
        return auth_header.removeprefix("Bearer ").strip()
    raise AuthenticationError("Authorization 헤더가 필요합니다.")


def require_auth(optional: bool = False) -> Callable[[Handler], Handler]:
    def decorator(func: Handler) -> Handler:
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                token = _extract_token()
                claims = verify_jwt(token)
                g.current_user = claims
            except AuthenticationError as exc:
                if optional:
                    g.current_user = None
                else:
                    return jsonify({"error": str(exc)}), 401
            return func(*args, **kwargs)

        return cast(Handler, wrapper)

    return decorator


def get_current_user() -> Dict[str, Any]:
    user = getattr(g, "current_user", None)
    if not user:
        raise AuthenticationError("인증 정보가 없습니다.")
    return user


