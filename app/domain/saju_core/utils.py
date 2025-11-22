from typing import Optional


def normalize_score(value: float, min_value: float = 0.0, max_value: float = 100.0) -> float:
    if max_value == min_value:
        return 0.0
    ratio = (value - min_value) / (max_value - min_value)
    return max(0.0, min(1.0, ratio))


# hd2.ipynb에서 사용하는 천간/지지 인덱스 매핑 (1-based)
HEAVENLY_STEMS = ["갑", "을", "병", "정", "무", "기", "경", "신", "임", "계"]
EARTHLY_BRANCHES = ["자", "축", "인", "묘", "진", "사", "오", "미", "신", "유", "술", "해"]


def load_h5_model_if_available(path: str) -> Optional[object]:
    """
    - TensorFlow / 파일 부재 시 None 반환
    - 성공 시 keras 모델 객체 반환
    """
    try:
        import os
        if not os.path.exists(path):
            # 프로젝트 루트 기준 상대 경로 보정 시도
            alt = os.path.join("source", os.path.basename(path))
            if os.path.exists(alt):
                path = alt
            else:
                return None
        # lazy import
        from tensorflow.keras.models import load_model  # type: ignore
        from tensorflow.keras.metrics import MeanSquaredError  # type: ignore
        return load_model(path, custom_objects={"mse": MeanSquaredError})
    except Exception:
        return None


