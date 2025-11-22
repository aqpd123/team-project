from flask import Flask

from .config import Config, get_config
from .infrastructure.database.db import db


def create_app(config_class: type[Config] | None = None) -> Flask:
    app = Flask(__name__)
    config_obj = config_class or get_config()
    app.config.from_object(config_obj)

    # Initialize database (MySQL 또는 설정된 DB URL)
    db.init_app(app.config.get("DATABASE_URL"))

    # Register blueprints
    from .api.controllers.saju_controller import bp as saju_bp
    from .api.controllers.celebrity_controller import bp as celebrity_bp
    from .api.controllers.auth_controller import bp as auth_bp
    from .api.controllers.user_controller import bp as user_bp
    from .api.controllers.post_controller import bp as post_bp
    from .api.controllers.compatibility_controller import bp as compatibility_bp
    from .api.controllers.friend_controller import bp as friend_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(post_bp)
    app.register_blueprint(compatibility_bp)
    app.register_blueprint(friend_bp)
    app.register_blueprint(saju_bp)
    app.register_blueprint(celebrity_bp)

    return app


