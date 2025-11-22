from typing import TypedDict, Dict, Any, List


class TraitsResponse(TypedDict):
    five: Dict[str, float]
    traits: Dict[str, float]
    flags: List[str]
    report: str


class CompatibilityResponse(TypedDict):
    original: float
    final: float
    stress: float
    details: Dict[str, Any]


