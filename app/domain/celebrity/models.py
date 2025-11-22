from dataclasses import dataclass, asdict
from typing import Dict


@dataclass(frozen=True)
class Celebrity:
    id: int
    name: str
    description: str
    category: str
    gender: int
    saju: Dict[str, str]
    thumbnail: str = ""

    def to_dict(self) -> Dict[str, str]:
        data = asdict(self)
        return data
