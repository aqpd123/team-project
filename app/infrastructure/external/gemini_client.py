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
                "연애": {
                    "desc": "연인 관계에서의 궁합",
                    "focus": "연애, 데이트, 로맨스, 감정적 교감, 애정 표현, 연인으로서의 관계"
                },
                "우정": {
                    "desc": "친구 관계에서의 궁합",
                    "focus": "우정, 친구 관계, 일상 대화, 취미 공유, 서로의 지지, 친구로서의 관계"
                },
                "직장": {
                    "desc": "직장 동료나 업무 파트너로서의 궁합",
                    "focus": "직장, 업무, 협업, 프로젝트, 업무 효율성, 직장 동료로서의 관계"
                },
            }
            
            category_info = category_prompts.get(category, {"desc": category, "focus": category})
            category_desc = category_info["desc"]
            category_focus = category_info["focus"]
            
            prompt = f"""당신은 한국 전통 사주 명리학 전문가입니다. 다음 정보를 바탕으로 {category_desc}에 대한 설명을 작성해주세요.

중요: 반드시 {category_focus}에 집중하여 작성하세요. 일반적인 궁합 설명이 아닌, 해당 카테고리에 특화된 구체적인 내용을 작성해야 합니다.

유명인: {celebrity_name}
사용자 오행: {user_element or "알 수 없음"}
유명인 오행: {celebrity_element or "알 수 없음"}
궁합 점수: {final_score:.1f}점

필수 요구사항 (반드시 지켜야 함):
1. 카테고리 특화: 반드시 {category_focus}에 집중하여 작성
   - 연애: 데이트, 로맨스, 감정적 교감, 애정 표현 등 연애 특화 내용
   - 우정: 일상 대화, 취미 공유, 서로의 지지 등 우정 특화 내용
   - 직장: 업무 협업, 프로젝트, 업무 효율성 등 직장 특화 내용
2. 말투 통일: 모든 문장을 반드시 "~해요" 또는 "~예요" 형식으로 통일
   - 허용: "~해요", "~예요", "~되네요", "~할 수 있어요", "~이에요"
   - 금지: "~합니다", "~있습니다", "~겠네요", "~겠어요", "~아요" 등 다른 말투
3. 오행 표기: 오행을 언급할 때 반드시 한자로 표기
   - 예: "목(木)", "화(火)", "토(土)", "금(金)", "수(水)"
   - 잘못된 예: "목", "화", "토", "금", "수" (한자 없이)
4. 길이 제한: 정확히 2-4줄(문장), 총 120-160자 이내
5. 문장 완성: 반드시 완전한 문장으로 끝내기 (중간에 끊기지 않음)
6. 톤: 친근하고 따뜻한 톤
7. 내용: 해당 카테고리에 특화된 구체적이고 실용적인 조언
8. 형식: 이모지 사용 금지

올바른 예시:
- 연애: "{celebrity_name}님과는 연인으로서 감정적 교감이 잘 맞아요. 로맨틱한 데이트를 즐기며 서로의 마음을 나누면 더욱 깊은 사랑이 될 수 있어요."
- 우정: "{celebrity_name}님과는 친구로서 일상 대화가 즐거워요. 공통 취미를 함께 즐기며 서로를 지지하면 오래가는 우정이 될 수 있어요."
- 직장: "{celebrity_name}님과는 업무 파트너로서 협업이 원활해요. 서로의 강점을 살려 프로젝트를 진행하면 좋은 성과를 낼 수 있어요."

잘못된 예시 (사용 금지):
- 일반적인 궁합 설명 (카테고리 특화 없음)
- "{celebrity_name}님은 화, 당신은 목이라..." (한자 없이 오행 표기)
- "{celebrity_name}님과는 좋은 궁합입니다." (말투 불일치)

{category} 궁합 설명:"""
            
            # GenerationConfig로 출력 토큰 수 제한 (약 160자 = 50-60 토큰)
            generation_config = genai.types.GenerationConfig(
                max_output_tokens=80,  # 약 160-200자 정도 (2-4줄을 위해 여유있게)
                temperature=0.7,
            )
            
            response = model.generate_content(
                prompt,
                generation_config=generation_config,
            )
            description = response.text.strip()
            
            # 문장이 중간에 끊기지 않도록 처리 (2-4줄 유지)
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
                
                # 3. 완전한 문장들만 사용 (2-4줄 유지)
                if complete_parts:
                    # 4줄 초과 시 마지막 문장 제거
                    if len(complete_parts) > 4:
                        complete_parts = complete_parts[:4]
                    description = ''.join(complete_parts).strip()
                elif len(description) > 180:
                    # 완전한 문장을 찾지 못했지만 길이가 초과하면
                    # 마지막 공백이나 조사 위치에서 자르기
                    for i in range(min(180, len(description) - 1), max(0, len(description) - 30), -1):
                        if description[i] in [' ', '은', '는', '이', '가', '을', '를', '에', '의', '로', '으로']:
                            description = description[:i].strip()
                            break
                    else:
                        description = description[:180].strip()
            
            return description
            
        except Exception as e:
            print(f"⚠️ Gemini API 호출 실패: {e}")
            return None

    def generate_advice_tip(
        self,
        celebrity_name: str,
        scores: Dict[str, float],
        insights: Dict[str, str],
        user_element: Optional[str] = None,
        celebrity_element: Optional[str] = None,
    ) -> Optional[str]:
        """
        궁합 점수와 인사이트를 바탕으로 "사주 전반적인 관계 분석" 문단 생성

        NOTE: 기존에는 구체적인 행동 팁을 생성했지만,
        이제는 전반적인 관계 분위기와 특징을 요약하는 분석형 설명을 생성한다.

        Args:
            celebrity_name: 유명인 이름
            scores: 궁합 점수
            insights: 카테고리별 인사이트 딕셔너리
            user_element: 사용자 오행 (목/화/토/금/수)
            celebrity_element: 유명인 오행 (목/화/토/금/수)

        Returns:
            생성된 분석 문자열, 실패 시 None
        """
        if not self._initialized:
            return None
        
        try:
            model = genai.GenerativeModel('gemini-2.0-flash')
            
            final_score = scores.get("final", 0.0)
            
            # 인사이트 요약
            insights_summary = "\n".join(
                [f"- {category}: {insight}" for category, insight in insights.items()]
            )

            # 사주 전반 분석 요약 프롬프트
            prompt = f"""당신은 한국 전통 사주 명리학 전문가입니다. 
다음 정보를 바탕으로 "{celebrity_name}님과의 사주 전반 궁합 분석 요약"을 작성해주세요.

유명인: {celebrity_name}
궁합 점수: {final_score:.1f}점

카테고리별 궁합 분석:
{insights_summary}

요구사항:
1. 전반적인 관계의 분위기, 강점, 주의할 점을 균형 있게 요약할 것
2. 구체적인 행동 지시(예: ~해보세요)는 피하고, 관계의 흐름과 특징을 설명하는 분석형 문장으로 작성할 것
3. 2-3문장, 총 100-150자 이내로 작성할 것
4. 말투는 "~해요", "~예요", "~이에요" 형태의 부드러운 존댓말로 통일할 것
5. 가능하면 사주나 오행의 특징을 자연스럽게 언급해도 되지만, 너무 기술적인 용어 사용은 피할 것
6. 제목, 소제목, 불릿포인트, 마크다운(**연애** 등)은 사용하지 말고 순수한 본문 문장만 작성할 것
7. 이모지는 사용하지 말 것

사주 전반 분석 요약:"""
            
            generation_config = genai.types.GenerationConfig(
                max_output_tokens=40,  # 약 60-80자 정도
                temperature=0.7,
            )
            
            response = model.generate_content(
                prompt,
                generation_config=generation_config,
            )
            tip = response.text.strip()
            
            # 문장이 중간에 끊기지 않도록 처리 (형식 일관성 유지)
            if tip:
                import re
                
                # 마침표/느낌표/물음표로 끝나는 완전한 문장 찾기
                complete_parts = []
                parts = re.split(r'([.!?])', tip)
                
                for i in range(0, len(parts) - 1, 2):
                    if i + 1 < len(parts):
                        sentence = parts[i] + parts[i + 1]
                        complete_parts.append(sentence)
                
                # 한글 종결 어미로 끝나는 문장 찾기
                if not complete_parts:
                    for ending in ['니다', '요', '다']:
                        idx = tip.rfind(ending)
                        if idx >= 0:
                            after_ending = idx + len(ending)
                            if after_ending >= len(tip):
                                complete_parts.append(tip)
                                break
                            elif tip[after_ending] in [' ', '.', '!', '?', '\n']:
                                complete_parts.append(tip[:after_ending])
                                break
                
                # 완전한 문장만 사용 (1-2문장 유지)
                if complete_parts:
                    # 2문장 초과 시 마지막 문장 제거
                    if len(complete_parts) > 2:
                        complete_parts = complete_parts[:2]
                    tip = ''.join(complete_parts).strip()
                elif len(tip) > 90:
                    # 완전한 문장을 찾지 못했지만 길이가 초과하면
                    # 마지막 공백이나 조사 위치에서 자르기
                    for i in range(min(90, len(tip) - 1), max(0, len(tip) - 20), -1):
                        if tip[i] in [' ', '은', '는', '이', '가', '을', '를', '에', '의', '로', '으로']:
                            tip = tip[:i].strip()
                            break
                    else:
                        tip = tip[:90].strip()
                
                # 형식 일관성: 마지막 문장이 "~해요" 또는 "~할 수 있어요"로 끝나도록
                if tip and not any(tip.rstrip().endswith(ending) for ending in ['해요', '예요', '이에요', '있어요', '되네요', '할 수 있어요', '.', '!', '?']):
                    # 종결 어미가 없으면 추가
                    if '해보세요' in tip or '해보면' in tip:
                        tip = tip.rstrip() + '요.'
                    elif '할 수' in tip:
                        tip = tip.rstrip() + '요.'
                    else:
                        tip = tip.rstrip() + '요.'
            
            return tip
            
        except Exception as e:
            print(f"⚠️ Gemini API 팁 생성 실패: {e}")
            return None

    def generate_personal_analysis(
        self,
        name: Optional[str],
        character_type: Optional[str],
        five_elements: Dict[str, float],
        traits: Dict[str, float],
        flags: Optional[list] = None,
        gender: int = 0,
    ) -> Optional[str]:
        """
        개인 사주 분석용 전반 요약 생성

        - 톤, 분량, 말투는 유명인 궁합 인사이트와 동일하게 유지
        - 내용은 한 사람의 성격/기질/관계 스타일에 초점을 둔다
        """
        if not self._initialized:
            return None

        try:
            model = genai.GenerativeModel("gemini-2.0-flash")

            # 오행 비율 요약
            five_summary_parts = []
            for key in ["wood", "fire", "earth", "metal", "water"]:
                value = five_elements.get(key, 0.0)
                if value <= 0:
                    continue
                label = {
                    "wood": "목(木)",
                    "fire": "화(火)",
                    "earth": "토(土)",
                    "metal": "금(金)",
                    "water": "수(水)",
                }.get(key, key)
                score = int(round(value * 100))
                five_summary_parts.append(f"{label} {score}점")
            five_summary = ", ".join(five_summary_parts) if five_summary_parts else "정보 없음"

            # 상위 성격 특성 요약 (상위 3개, 한글 라벨 포함)
            trait_labels = {
                "passion": "열정",
                "intuition": "직감",
                "mood_swing": "감정 기복",
                "courage": "용기",
                "responsibility": "책임감",
                "conflict": "갈등 에너지",
                "charisma": "카리스마",
                "independence": "독립성",
            }
            top_traits = sorted(traits.items(), key=lambda kv: kv[1], reverse=True)[:3]
            trait_details = []
            for k, v in top_traits:
                label = trait_labels.get(k, k)
                score = int(round(v * 100))
                trait_details.append(f"{label}({score}점)")
            trait_summary = ", ".join(trait_details) if trait_details else "정보 없음"

            flags = flags or []
            flags_summary = ", ".join(flags[:3]) if flags else "없음"

            gender_label = "여성" if gender == 0 else "남성"
            name_or_you = name or "당신"
            
            # 대표 성격 유형을 한자 포함 형태로 변환
            character_type_with_hanja = {
                "wood": "목(木)",
                "fire": "화(火)",
                "earth": "토(土)",
                "metal": "금(金)",
                "water": "수(水)",
            }.get(character_type or "", character_type or "알 수 없음")

            prompt = f"""당신은 한국 전통 사주 명리학 전문가입니다. 
다음 정보를 바탕으로 사주 전반 성격과 기질, 관계 스타일을 분석해 한 문단으로 요약해주세요.

이름: {name_or_you}
성별: {gender_label}
대표 성격 유형: {character_type_with_hanja}
오행 균형: {five_summary}
주요 성격 특성 (상위 3개): {trait_summary}
특이 기운 키워드: {flags_summary}

요구사항:
1. 반드시 "주요 성격 특성 (상위 3개)"에 나열된 3가지 특성을 각각 구체적으로 언급하고 활용할 것
   - 각 특성이 일상생활, 인간관계, 업무/학습 스타일에 어떻게 드러나는지 설명할 것
2. 전반적인 성격 분위기, 강점, 주의할 점을 균형 있게 요약할 것
3. 연애·인간관계·일/공부 스타일을 자연스럽게 녹여서 설명할 것
4. 정확히 4줄 정도, 총 200-250자 이내로 작성할 것 (너무 짧거나 길지 않게)
5. 말투는 "~해요", "~예요", "~이에요" 형태의 부드러운 존댓말로 통일할 것
6. 제목, 소제목, 불릿포인트, 마크다운은 사용하지 말고 순수한 본문 문장만 작성할 것
7. 이모지는 사용하지 말 것
8. 각 문장은 완전한 문장으로 끝내고, 중간에 끊기지 않게 할 것
9. 중요: 이름이나 "~님은", "당신은" 같은 호칭을 사용하지 말 것. 바로 "~기운이 강한 사람" 또는 "~성향이 뚜렷한 사람" 같은 식으로 시작할 것 (예: "목(木) 기운이 강한 사람은..." 또는 "금(金) 성향이 뚜렷한 사람은...")

개인 사주 전반 분석 요약:"""

            generation_config = genai.types.GenerationConfig(
                max_output_tokens=150,  # 4줄 분량을 위해 증가 (약 250자)
                temperature=0.7,
            )

            response = model.generate_content(
                prompt,
                generation_config=generation_config,
            )
            text = response.text.strip()

            if text:
                import re

                complete_parts = []
                parts = re.split(r"([.!?])", text)
                for i in range(0, len(parts) - 1, 2):
                    if i + 1 < len(parts):
                        sentence = parts[i] + parts[i + 1]
                        complete_parts.append(sentence)

                if not complete_parts:
                    for ending in ["니다", "요", "다"]:
                        idx = text.rfind(ending)
                        if idx >= 0:
                            after_ending = idx + len(ending)
                            if after_ending >= len(text):
                                complete_parts.append(text)
                                break
                            elif text[after_ending] in [" ", ".", "!", "?", "\n"]:
                                complete_parts.append(text[:after_ending])
                                break

                if complete_parts:
                    # 4줄 분량이므로 최대 4-5문장까지 허용
                    if len(complete_parts) > 5:
                        complete_parts = complete_parts[:5]
                    text = "".join(complete_parts).strip()
                elif len(text) > 300:
                    # 250자 정도로 제한하되, 문장이 중간에 끊기지 않도록 처리
                    for i in range(min(300, len(text) - 1), max(0, len(text) - 30), -1):
                        if text[i] in [" ", "은", "는", "이", "가", "을", "를", "에", "의", "로", "으로"]:
                            text = text[:i].strip()
                            break
                    else:
                        text = text[:300].strip()

            return text

        except Exception as e:
            print(f"⚠️ Gemini API 개인 사주 분석 실패: {e}")
            return None
    
    def generate_compatibility_advice(
        self,
        person1_name: str,
        person2_name: str,
        scores: Dict[str, float],
        insights: Dict[str, str],
        user_element: Optional[str] = None,
        celebrity_element: Optional[str] = None,
    ) -> Optional[str]:
        """
        일반 궁합 분석을 위한 관계 발전 조언 생성
        
        Args:
            person1_name: 첫 번째 사람 이름
            person2_name: 두 번째 사람 이름
            scores: 궁합 점수
            insights: 카테고리별 인사이트 딕셔너리
            user_element: 첫 번째 사람 오행 (한자 포함, 예: "목(木)")
            celebrity_element: 두 번째 사람 오행 (한자 포함, 예: "화(火)")
        
        Returns:
            생성된 조언 문자열, 실패 시 None
        """
        if not self._initialized:
            return None
        
        try:
            model = genai.GenerativeModel('gemini-2.0-flash')
            
            final_score = scores.get("final", 0.0)
            
            # 인사이트 요약
            insights_summary = "\n".join(
                [f"- {category}: {insight}" for category, insight in insights.items()]
            )
            
            prompt = f"""당신은 한국 전통 사주 명리학 전문가입니다. 
다음 정보를 바탕으로 {person1_name}님과 {person2_name}님의 관계 발전을 위한 조언을 작성해주세요.

첫 번째 사람: {person1_name}
두 번째 사람: {person2_name}
첫 번째 사람 오행: {user_element or "알 수 없음"}
두 번째 사람 오행: {celebrity_element or "알 수 없음"}
궁합 점수: {final_score:.1f}점

카테고리별 궁합 분석:
{insights_summary}

요구사항:
1. 관계 발전을 위한 구체적이고 실용적인 조언을 제공할 것
2. 연애, 우정, 직장 등 다양한 관계 영역에서 도움이 될 수 있는 조언 포함
3. 정확히 4줄 정도, 총 200-250자 이내로 작성할 것
4. 말투는 "~해요", "~예요", "~이에요" 형태의 부드러운 존댓말로 통일할 것
5. 제목, 소제목, 불릿포인트, 마크다운은 사용하지 말고 순수한 본문 문장만 작성할 것
6. 이모지는 사용하지 말 것
7. 각 문장은 완전한 문장으로 끝내고, 중간에 끊기지 않게 할 것
8. 구체적인 행동 지시나 조언을 포함할 것 (예: "~해보세요", "~하는 것이 좋아요")

관계 발전을 위한 조언:"""
            
            generation_config = genai.types.GenerationConfig(
                max_output_tokens=150,  # 4줄 분량을 위해 증가 (약 250자)
                temperature=0.7,
            )
            
            response = model.generate_content(
                prompt,
                generation_config=generation_config,
            )
            advice = response.text.strip()
            
            # 문장이 중간에 끊기지 않도록 처리
            if advice:
                import re
                
                complete_parts = []
                parts = re.split(r'([.!?])', advice)
                
                for i in range(0, len(parts) - 1, 2):
                    if i + 1 < len(parts):
                        sentence = parts[i] + parts[i + 1]
                        complete_parts.append(sentence)
                
                if not complete_parts:
                    for ending in ['니다', '요', '다']:
                        idx = advice.rfind(ending)
                        if idx >= 0:
                            after_ending = idx + len(ending)
                            if after_ending >= len(advice):
                                complete_parts.append(advice)
                                break
                            elif advice[after_ending] in [' ', '.', '!', '?', '\n']:
                                complete_parts.append(advice[:after_ending])
                                break
                
                if complete_parts:
                    # 4줄 분량이므로 최대 5문장까지 허용
                    if len(complete_parts) > 5:
                        complete_parts = complete_parts[:5]
                    advice = ''.join(complete_parts).strip()
                elif len(advice) > 300:
                    # 250자 정도로 제한하되, 문장이 중간에 끊기지 않도록 처리
                    for i in range(min(300, len(advice) - 1), max(0, len(advice) - 30), -1):
                        if advice[i] in [' ', '은', '는', '이', '가', '을', '를', '에', '의', '로', '으로']:
                            advice = advice[:i].strip()
                            break
                    else:
                        advice = advice[:300].strip()
            
            return advice
            
        except Exception as e:
            print(f"⚠️ Gemini API 관계 발전 조언 생성 실패: {e}")
            return None


# 싱글톤 인스턴스
_gemini_client: Optional[GeminiClient] = None


def get_gemini_client() -> GeminiClient:
    """Gemini 클라이언트 싱글톤 인스턴스 반환"""
    global _gemini_client
    if _gemini_client is None:
        _gemini_client = GeminiClient()
    return _gemini_client

