#!/usr/bin/env python3
"""사용 가능한 Gemini 모델 확인"""

import os
from dotenv import load_dotenv

load_dotenv()

import google.generativeai as genai

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

print("사용 가능한 모델 목록:")
for model in genai.list_models():
    if 'generateContent' in model.supported_generation_methods:
        print(f"  - {model.name}")

