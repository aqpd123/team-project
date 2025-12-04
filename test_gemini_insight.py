#!/usr/bin/env python3
"""Gemini 인사이트 생성 테스트"""

import os
from dotenv import load_dotenv

load_dotenv()

from app.infrastructure.external.gemini_client import get_gemini_client

def test_insights():
    print("🔍 Gemini 인사이트 생성 테스트...\n")
    
    gemini = get_gemini_client()
    
    if not gemini._initialized:
        print("❌ Gemini API가 초기화되지 않았습니다.")
        return
    
    test_scores = {"final": 75.0, "original": 80.0, "stress": 15.0}
    
    categories = ["연애", "우정", "직장"]
    
    for category in categories:
        print(f"\n📝 {category} 궁합 인사이트 생성 테스트...")
        insight = gemini.generate_insight_description(
            category=category,
            celebrity_name="이하린",
            scores=test_scores,
            user_element="금",
            celebrity_element="화",
        )
        
        if insight:
            print(f"✅ 생성된 인사이트:")
            print(f"   {insight}")
            print(f"   길이: {len(insight)}자")
            print(f"   끝 문자: [{insight[-5:]}]")
        else:
            print("❌ 인사이트 생성 실패")
    
    print("\n✅ 테스트 완료!")

if __name__ == "__main__":
    test_insights()

