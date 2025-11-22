from __future__ import annotations

from typing import Any, Dict, List, Type

from marshmallow import (
    Schema,
    fields,
    validate,
    ValidationError as MarshmallowValidationError,
    EXCLUDE,
)

from app.common.exceptions import ValidationError


class BaseSchema(Schema):
    class Meta:
        unknown = EXCLUDE


class SajuSchema(BaseSchema):
    year_gan = fields.Str(required=True, validate=validate.Length(min=1))
    year_ji = fields.Str(required=True, validate=validate.Length(min=1))
    month_gan = fields.Str(required=True, validate=validate.Length(min=1))
    month_ji = fields.Str(required=True, validate=validate.Length(min=1))
    day_gan = fields.Str(required=True, validate=validate.Length(min=1))
    day_ji = fields.Str(required=True, validate=validate.Length(min=1))
    time_gan = fields.Str(validate=validate.Length(min=1))
    time_ji = fields.Str(validate=validate.Length(min=1))


class RegisterSchema(BaseSchema):
    username = fields.Str(required=True, validate=validate.Length(min=2, max=50))
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=6))
    gender = fields.Int(validate=validate.OneOf([0, 1]))
    character_type = fields.Str(validate=validate.Length(min=1))
    saju = fields.Nested(SajuSchema)


class LoginSchema(BaseSchema):
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=1))


class PostCreateSchema(BaseSchema):
    title = fields.Str(required=True, validate=validate.Length(min=1, max=255))
    content = fields.Str(required=True, validate=validate.Length(min=1))
    board_type = fields.Str(validate=validate.Length(min=1))
    author_id = fields.Int()


class CommentCreateSchema(BaseSchema):
    content = fields.Str(required=True, validate=validate.Length(min=1))
    author_id = fields.Int()


class CompatibilityRequestSchema(BaseSchema):
    requester_id = fields.Int()
    target_id = fields.Int(required=True)
    message = fields.Str(validate=validate.Length(min=1))


class CompatibilityRespondSchema(BaseSchema):
    accept = fields.Bool(required=True)


class FriendRequestSchema(BaseSchema):
    target_id = fields.Int(required=True)
    message = fields.Str(validate=validate.Length(min=1))


class FriendRespondSchema(BaseSchema):
    accept = fields.Bool(required=True)


class SajuTraitsSchema(BaseSchema):
    saju = fields.Nested(SajuSchema, required=True)
    gender = fields.Int(load_default=0, validate=validate.OneOf([0, 1]))


class SajuCompatibilitySchema(BaseSchema):
    saju1 = fields.Nested(SajuSchema, required=True)
    saju2 = fields.Nested(SajuSchema, required=True)
    gender1 = fields.Int(load_default=0, validate=validate.OneOf([0, 1]))
    gender2 = fields.Int(load_default=0, validate=validate.OneOf([0, 1]))


class CelebrityCompatibilitySchema(BaseSchema):
    saju = fields.Nested(SajuSchema, required=True)
    gender = fields.Int(load_default=0, validate=validate.OneOf([0, 1]))


def _flatten_errors(messages: Dict[str, Any], prefix: str = "") -> List[str]:
    errors: List[str] = []
    for key, value in messages.items():
        full_key = f"{prefix}.{key}" if prefix else key
        if isinstance(value, dict):
            errors.extend(_flatten_errors(value, full_key))
        elif isinstance(value, list):
            joined = ", ".join(str(v) for v in value)
            errors.append(f"{full_key}: {joined}")
        else:
            errors.append(f"{full_key}: {value}")
    return errors


def load_json(schema_cls: Type[Schema], payload: Dict[str, Any] | None) -> Dict[str, Any]:
    schema = schema_cls()
    try:
        return schema.load(payload or {})
    except MarshmallowValidationError as exc:
        messages = _flatten_errors(exc.messages)
        raise ValidationError("; ".join(messages))

