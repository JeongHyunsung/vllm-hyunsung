import os
from vllm import LLM, SamplingParams

DOWNLOAD_DIR = "/home/hyunsung/vLLM/models"

MODEL = "TinyLlama/TinyLlama-1.1B-1T"

llm = LLM(
    model=MODEL,
    tokenizer=MODEL,           # 토크나이저 모델 맞춤
    trust_remote_code=True,    # 여러 모델에서 필요
    download_dir=DOWNLOAD_DIR, # 로컬 캐시 활용
    dtype="auto",              # GPU/모델에 맞춰 자동
    max_model_len=2048,        # 메모리 아끼기
    compilation_config=0,   # Inductor(=Triton 합성커널) off
    enforce_eager=True,     # CUDA graph/Inductor 경로 우회
)

prompts = [
    "Hello, world!",
    "Give me three bullet points about branch predictors.",
]

outs = llm.generate(prompts, SamplingParams(max_tokens=64, temperature=0.7))
for i, o in enumerate(outs):
    print(f"\n=== Prompt {i} ===\n{prompts[i]}\n---")
    print(o.outputs[0].text.strip())
