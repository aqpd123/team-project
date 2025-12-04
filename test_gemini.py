#!/usr/bin/env python3
"""Gemini API 테스트 스크립트"""

import os
from dotenv import load_dotenv

load_dotenv()

from app.infrastructure.external.gemini_client import get_gemini_client

def test_gemini():
    print("🔍 Gemini API 테스트 시작...\n")
    
    gemini = get_gemini_client()
    
    if not gemini._initialized:
        print("❌ Gemini API가 초기화되지 않았습니다.")
        print("GEMINI_API_KEY 환경 변수를 확인해주세요.")
        return
    
    print("✅ Gemini API 초기화 성공\n")
    
    # 테스트 데이터
    test_scores = {
        "original": 85.5,
        "final": 82.3,
        "stress": 12.5,
    }
    
    print("📝 궁합 설명 생성 테스트...")
    description = gemini.generate_compatibility_description(
        celebrity_name="아이유",
        celebrity_profession="가수",
        scores=test_scores,
        user_element="화",
        celebrity_element="목",
    )
    
    if description:
        print(f"✅ 생성된 설명:\n{description}\n")
    else:
        print("❌ 설명 생성 실패\n")
    
    # 인사이트 테스트
    print("📝 연애 궁합 인사이트 생성 테스트...")
    insight = gemini.generate_insight_description(
        category="연애",
        celebrity_name="아이유",
        scores=test_scores,
        user_element="화",
        celebrity_element="목",
    )
    
    if insight:
        print(f"✅ 생성된 인사이트:\n{insight}\n")
    else:
        print("❌ 인사이트 생성 실패\n")
    
    print("✅ 테스트 완료!")

if __name__ == "__main__":
    test_gemini()

