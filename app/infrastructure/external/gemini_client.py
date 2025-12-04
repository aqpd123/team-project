"""
Gemini API 클라이언트
AI 기반 사주 설명 생성을 위한 Gemini API 통합
"""

from __future__ import annotations

import os
from typing import Dict, Any, Optional

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except (ImportError, ModuleNotFoundError) as e:
    GEMINI_AVAILABLE = False
    print(f"⚠️ Gemini import 실패: {e}")


class GeminiClient:
    """Gemini API를 사용하여 AI 기반 설명을 생성하는 클라이언트"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        self._initialized = False
        
        if GEMINI_AVAILABLE and self.api_key:
            try:
                genai.configure(api_key=self.api_key)
                self._initialized = True
            except Exception as e:
                print(f"⚠️ Gemini API 초기화 실패: {e}")
                self._initialized = False
        else:
            if not GEMINI_AVAILABLE:
                print("⚠️ google-generativeai 패키지가 설치되지 않았습니다.")
            if not self.api_key:
                print("⚠️ GEMINI_API_KEY 환경 변수가 설정되지 않았습니다.")
    
    def generate_compatibility_description(
        self,
        celebrity_name: str,
        celebrity_profession: str,
        scores: Dict[str, float],
        user_element: Optional[str] = None,
        celebrity_element: Optional[str] = None,
    ) -> Optional[str]:
        """
        유명인과의 궁합 설명을 AI로 생성
        
        Args:
            celebrity_name: 유명인 이름
            celebrity_profession: 유명인 직업
            scores: 궁합 점수 딕셔너리 (original, final, stress)
            user_element: 사용자 오행 (목/화/토/금/수)
            celebrity_element: 유명인 오행 (목/화/토/금/수)
        
        Returns:
            생성된 설명 문자열, 실패 시 None
        """
        if not self._initialized:
            return None
        
        try:
            # 최신 Gemini 모델 사용 (gemini-2.0-flash는 빠르고 무료)
            model = genai.GenerativeModel('gemini-2.0-flash')
            
            final_score = scores.get("final", 0.0)
            original_score = scores.get("original", 0.0)
            stress = scores.get("stress", 0.0)
            
            prompt = f"""당신은 한국 전통 사주 명리학 전문가입니다. 다음 정보를 바탕으로 유명인과의 궁합 설명을 작성해주세요.

유명인 정보:
- 이름: {celebrity_name}
- 직업: {celebrity_profession}
- 오행: {celebrity_element or "알 수 없음"}

사용자 오행: {user_element or "알 수 없음"}

궁합 점수:
- 최종 점수: {final_score:.1f}점
- 원점수: {original_score:.1f}점
- 스트레스 지수: {stress:.1f}

요구사항:
1. 친근하고 따뜻한 톤으로 작성
2. 점수에 맞는 현실적이고 긍정적인 설명
3. 구체적인 조언 포함
4. 정확히 2-3문장으로 간결하게 작성 (총 100자 이내)
5. 이모지 사용 금지
6. 반드시 100자 이하로 작성 (초과 시 잘림)

궁합 설명:"""
            
            # GenerationConfig로 출력 토큰 수 제한 (약 100자 = 30-40 토큰)
            generation_config = genai.types.GenerationConfig(
                max_output_tokens=50,  # 약 100-150자 정도
                temperature=0.7,
            )
            
            response = model.generate_content(
                prompt,
                generation_config=generation_config,
            )
            description = response.text.strip()
            
            # 응답이 너무 길면 자르기 (안전장치)
            if len(description) > 120:
                description = description[:120] + "..."
            
            return description
            
        except Exception as e:
            print(f"⚠️ Gemini API 호출 실패: {e}")
            return None
    
    def generate_insight_description(
        self,
        category: str,  # "연애", "우정", "직장" 등
        celebrity_name: str,
        scores: Dict[str, float],
        user_element: Optional[str] = None,
        celebrity_element: Optional[str] = None,
    ) -> Optional[str]:
        """
        카테고리별 인사이트 설명 생성
        
        Args:
            category: 카테고리 (연애, 우정, 직장 등)
            celebrity_name: 유명인 이름
            scores: 궁합 점수
            user_element: 사용자 오행
            celebrity_element: 유명인 오행
        
        Returns:
            생성된 설명 문자열, 실패 시 None
        """
        if not self._initialized:
            return None
        
        try:
            # 최신 Gemini 모델 사용 (gemini-2.0-flash는 빠르고 무료)
            model = genai.GenerativeModel('gemini-2.0-flash')
            
            final_score = scores.get("final", 0.0)
            
            category_prompts = {
                "연애": "연인 관계에서의 궁합",
                "우정": "친구 관계에서의 궁합",
                "직장": "직장 동료나 업무 파트너로서의 궁합",
            }
            
            category_desc = category_prompts.get(category, category)
            
            prompt = f"""당신은 한국 전통 사주 명리학 전문가입니다. 다음 정보를 바탕으로 {category_desc}에 대한 설명을 작성해주세요.

유명인: {celebrity_name}
사용자 오행: {user_element or "알 수 없음"}
유명인 오행: {celebrity_element or "알 수 없음"}
궁합 점수: {final_score:.1f}점

필수 요구사항 (반드시 지켜야 함):
1. 말투 통일: 모든 문장을 반드시 "~해요" 또는 "~예요" 형식으로 통일
   - 허용: "~해요", "~예요", "~되네요", "~할 수 있어요", "~이에요"
   - 금지: "~합니다", "~있습니다", "~겠네요", "~겠어요", "~아요" 등 다른 말투
2. 길이 제한: 정확히 2-3문장, 총 100-120자 이내
3. 문장 완성: 반드시 완전한 문장으로 끝내기 (중간에 끊기지 않음)
   - 각 문장은 반드시 "~해요", "~예요", "~이에요" 등으로 끝나야 함
4. 톤: 친근하고 따뜻한 톤
5. 내용: 구체적이고 실용적인 조언
6. 형식: 이모지 사용 금지

올바른 예시:
"{celebrity_name}님과는 좋은 궁합이에요. 서로를 이해하고 존중하면 더욱 좋은 관계가 될 수 있어요."

잘못된 예시 (사용 금지):
- "{celebrity_name}님과는 좋은 궁합입니다." (말투 불일치: ~입니다 사용)
- "{celebrity_name}님과는 좋은 궁합이겠네요." (말투 불일치: ~겠네요 사용)
- "{celebrity_name}님과는 좋은 궁합이에요. 서로를 이해하고..." (끊김)

{category} 궁합 설명:"""
            
            # GenerationConfig로 출력 토큰 수 제한 (약 120자 = 40-50 토큰)
            generation_config = genai.types.GenerationConfig(
                max_output_tokens=60,  # 약 120-150자 정도 (완전한 문장을 위해 여유있게)
                temperature=0.7,
            )
            
            response = model.generate_content(
                prompt,
                generation_config=generation_config,
            )
            description = response.text.strip()
            
            # 문장이 중간에 끊기지 않도록 처리
            if description:
                import re
                
                # 1. 마침표/느낌표/물음표로 끝나는 완전한 문장 찾기
                complete_parts = []
                parts = re.split(r'([.!?])', description)
                
                for i in range(0, len(parts) - 1, 2):
                    if i + 1 < len(parts):
                        sentence = parts[i] + parts[i + 1]
                        complete_parts.append(sentence)
                
                # 2. 한글 종결 어미로 끝나는 문장 찾기 (우선순위: 니다 > 요 > 다)
                if not complete_parts:
                    for ending in ['니다', '요', '다']:
                        # 문자열 끝에서부터 종결 어미 찾기
                        idx = description.rfind(ending)
                        if idx >= 0:
                            # 종결 어미가 문장 끝에 있는지 확인
                            after_ending = idx + len(ending)
                            if after_ending >= len(description):
                                # 문장 끝에 종결 어미가 있음
                                complete_parts.append(description)
                                break
                            elif description[after_ending] in [' ', '.', '!', '?', '\n']:
                                # 종결 어미 뒤에 공백이나 구두점이 있음
                                complete_parts.append(description[:after_ending])
                                break
                
                # 3. 완전한 문장들만 사용
                if complete_parts:
                    description = ''.join(complete_parts).strip()
                elif len(description) > 130:
                    # 완전한 문장을 찾지 못했지만 길이가 초과하면
                    # 마지막 공백이나 조사 위치에서 자르기
                    for i in range(min(130, len(description) - 1), max(0, len(description) - 30), -1):
                        if description[i] in [' ', '은', '는', '이', '가', '을', '를', '에', '의', '로', '으로']:
                            description = description[:i].strip()
                            break
                    else:
                        description = description[:130].strip()
            
            return description
            
        except Exception as e:
            print(f"⚠️ Gemini API 호출 실패: {e}")
            return None


# 싱글톤 인스턴스
_gemini_client: Optional[GeminiClient] = None


def get_gemini_client() -> GeminiClient:
    """Gemini 클라이언트 싱글톤 인스턴스 반환"""
    global _gemini_client
    if _gemini_client is None:
        _gemini_client = GeminiClient()
    return _gemini_client

