from sqlalchemy import (
    MetaData,
    Table,
    Column,
    Integer,
    String,
    Text,
    Float,
    DateTime,
    Boolean,
    ForeignKey,
    UniqueConstraint,
)
from sqlalchemy.sql import func

metadata = MetaData()

users = Table(
    "users",
    metadata,
    Column("user_id", Integer, primary_key=True, autoincrement=True),
    Column("username", String(50), nullable=False, unique=True),
    Column("email", String(120), nullable=False, unique=True),
    Column("password_hash", String(255), nullable=False),
    Column("character_type", String(10)),
    Column("birth_date", DateTime),
    Column("gender", Integer),
    Column("saju_data", Text),
    Column("created_at", DateTime, server_default=func.now()),
)

posts = Table(
    "posts",
    metadata,
    Column("post_id", Integer, primary_key=True, autoincrement=True),
    Column("author_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("title", String(150), nullable=False),
    Column("content", Text, nullable=False),
    Column("board_type", String(50)),
    Column("created_at", DateTime, server_default=func.now()),
    Column("updated_at", DateTime, server_default=func.now(), onupdate=func.now()),
    Column("view_count", Integer, server_default="0"),
    Column("like_count", Integer, server_default="0"),
)

comments = Table(
    "comments",
    metadata,
    Column("comment_id", Integer, primary_key=True, autoincrement=True),
    Column("post_id", Integer, ForeignKey("posts.post_id"), nullable=False),
    Column("author_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("content", Text, nullable=False),
    Column("created_at", DateTime, server_default=func.now()),
    Column("updated_at", DateTime, server_default=func.now(), onupdate=func.now()),
)

compatibility_requests = Table(
    "compatibility_requests",
    metadata,
    Column("request_id", Integer, primary_key=True, autoincrement=True),
    Column("requester_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("target_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("status", String(20), server_default="pending"),
    Column("request_message", Text),
    Column("result_original", Float),
    Column("result_final", Float),
    Column("stress", Float),
    Column("compatibility_result", Text),
    Column("created_at", DateTime, server_default=func.now()),
    Column("responded_at", DateTime),
)

friendships = Table(
    "friendships",
    metadata,
    Column("friendship_id", Integer, primary_key=True, autoincrement=True),
    Column("requester_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("addressee_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("status", String(20), nullable=False, server_default="pending"),
    Column("created_at", DateTime, server_default=func.now()),
    Column("responded_at", DateTime),
    UniqueConstraint("requester_id", "addressee_id", name="ux_friend_pair"),
)

celebrities = Table(
    "celebrities",
    metadata,
    Column("celebrity_id", Integer, primary_key=True, autoincrement=True),
    Column("name", String(120), nullable=False),
    Column("birth_date", DateTime),
    Column("character_type", String(10)),
    Column("saju_data", Text),
    Column("profile_image_url", String(255)),
)

character_info = Table(
    "character_info",
    metadata,
    Column("character_type", String(10), primary_key=True),
    Column("name", String(50)),
    Column("description", Text),
)

compatibility_results = Table(
    "compatibility_results",
    metadata,
    Column("result_id", Integer, primary_key=True, autoincrement=True),
    Column("type_1", String(10), nullable=False),
    Column("type_2", String(10), nullable=False),
    Column("content", Text),
    Column("score", Float),
    UniqueConstraint("type_1", "type_2", name="ux_type_pair"),
)

notifications = Table(
    "notifications",
    metadata,
    Column("notification_id", Integer, primary_key=True, autoincrement=True),
    Column("user_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("type", String(50), nullable=False),
    Column("payload", Text),
    Column("is_read", Boolean, server_default="0"),
    Column("created_at", DateTime, server_default=func.now()),
)

messages = Table(
    "messages",
    metadata,
    Column("message_id", Integer, primary_key=True, autoincrement=True),
    Column("thread_key", String(50), nullable=False, index=True),
    Column("sender_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("recipient_id", Integer, ForeignKey("users.user_id"), nullable=False),
    Column("content", Text, nullable=False),
    Column("is_read", Boolean, server_default="0"),
    Column("created_at", DateTime, server_default=func.now()),
)


def create_all(engine) -> None:
    metadata.create_all(engine, checkfirst=True)
