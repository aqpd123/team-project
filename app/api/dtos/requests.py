from typing import TypedDict, Dict, Any, Optional


class PersonalityAnalyzeRequest(TypedDict):
    saju: Dict[str, str]
    gender: int


class RegisterRequest(TypedDict, total=False):
    username: str
    email: str
    password: str
    gender: int
    character_type: str
    saju: Optional[Dict[str, str]]


class LoginRequest(TypedDict):
    email: str
    password: str


class PostCreateRequest(TypedDict):
    author_id: int
    title: str
    content: str
    board_type: Optional[str]


class CommentCreateRequest(TypedDict):
    author_id: int
    content: str


class CompatibilityCreateRequest(TypedDict):
    requester_id: int
    target_id: int
    message: Optional[str]


class CompatibilityAcceptRequest(TypedDict):
    accept: bool


class FriendRequestCreate(TypedDict):
    target_id: int
    message: Optional[str]


class FriendRespondRequest(TypedDict):
    accept: bool


