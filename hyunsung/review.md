# Project architecturue


## P1+A1. depth 1 - documentation

|Folder/File|Role|Boundary|# Files|# Chaged|Implemented language|Priority|
|---|---|---|---|---|---|---|
|vllm/|LLM 서빙의 핵심 로직. 모델 로딩, 토크나이저, 엔진, 스케줄러, 요청 분배, 추론 파이프라인, 커스텀 레이어, attention, 샘플러, 메모리 관리 등 LLM serving의 모든 주요 기능을 포함.|LLM 추론 전체 파이프라인, 모델 실행, 커스텀 연산, 토큰 생성, 요청/응답 처리, 내부 모듈 간 데이터 흐름, 확장성 및 다양한 모델 지원.|1271|5283|Python, CUDA, C++|★★★★★|
|tests/|모든 기능에 대한 단위/통합/엔드투엔드 테스트. 주요 모듈별 정상동작, 예외처리, 성능, 회귀 테스트 등.|vllm/ 및 csrc/의 각 기능별 테스트, 벤치마크 테스트, 예제 코드 검증, CI/CD 연동 테스트, 커버리지 확보.|713|2061|Python|★★★★|
|examples/|다양한 모델/시나리오별 vLLM 사용 예제, 프롬프트 템플릿, 샘플 코드, 실전 활용법 제공.|실제 모델별 프롬프트 템플릿(jinja), 샘플 스크립트, 문서화된 사용법, 튜토리얼, 빠른 시작 가이드.|180|354|Python, Jinja|★★★|
|csrc/|CUDA/C++ 기반의 커스텀 GPU 커널, low-level 연산, PyTorch 바인딩, 고성능 연산 구현.|attention, cache, layernorm 등 핵심 연산의 CUDA 커널, C++/CUDA 헤더, Python-C++ 연동(torch_bindings), 성능 최적화 코드.|226|252|CUDA, C++, C|★★★★★|
|.buildkite/|Buildkite 기반 CI/CD 파이프라인 정의, 자동화된 빌드/테스트/배포 워크플로우.|빌드/테스트 스크립트, 환경설정, 워크플로우 정의, 자동화 트리거, 상태 체크, 배포 연동.|-|177|YAML, Shell|★★|
|benchmarks/|LLM 서빙/추론의 성능(지연시간, 처리량 등) 측정 및 비교, 벤치마크 도구 제공.|다양한 벤치마크 스크립트, 데이터셋, 성능 측정 유틸리티, 결과 분석, 구조화된 출력, 실험 자동화.|70|164|Python, Shell|★★★|
|requirements/|Python 패키지 및 빌드 의존성 관리, 환경 재현성 보장.|빌드/실행/테스트에 필요한 패키지 목록, requirements.txt, build.txt 등 환경별 의존성 파일.|18|141|Text|★★|
|docker/|다양한 하드웨어/OS 환경에서 vLLM 실행을 위한 Docker 이미지 정의.|CPU/GPU/ROCm/TPU 등 환경별 Dockerfile, 빌드 스크립트, 컨테이너화 설정, 배포 자동화.|10|66|Dockerfile, Shell|★★|
|docs/|공식 문서, API 레퍼런스, 사용법, 아키텍처, 기여 가이드, FAQ 등 프로젝트 문서화.|API 문서, 튜토리얼, 구성/설정/배포/운영 가이드, 예제, 디자인 문서, 커뮤니티/기여/보안 정책.|209|64|Markdown, Python|★★★|
|.github/|GitHub Actions 워크플로우, 이슈/PR 템플릿, 코드오브컨덕트 등 GitHub 플랫폼 설정.|자동화 워크플로우, PR/이슈 템플릿, 행동강령, 보안 정책, 커뮤니티 가이드라인.|-|48|YAML, Markdown|★|
|tools/|개발/운영/분석을 위한 보조 스크립트 및 유틸리티 도구 모음.|데이터 변환, 로그 분석, 자동화, 배포, 실험, 코드 포맷팅, 환경 설정 등 다양한 유틸리티.|28|38|Python, Shell|★★|
|cmake/|CMake 기반 빌드 시스템 설정, 외부 라이브러리 관리, 플랫폼별 빌드 옵션.|CMakeLists, 빌드 유틸리티, 외부 프로젝트 의존성, 빌드 환경 자동화, HIPIFY 등.|5|21|CMake, Python|★★|
|hyunsung/|사용자(JeongHyunsung) 커스텀 코드, 실험, 분석, 리뷰, 개인 연구 결과물.|실험적 코드, 분석 노트, 리뷰 문서, 개인용 스크립트, 프로젝트 맞춤형 확장.|14|-|Python, Markdown|★|
|artifacts/|자동화 파이프라인, 벤치마크, 분석 등에서 생성된 산출물 및 결과 파일 저장.|로그, 리포트, 통계, 벤치마크 결과, 임시 파일 등 자동 생성 산출물.|4|-|Text|-|
|logs/|실행/테스트/운영 중 생성되는 로그 파일 저장.|시스템/애플리케이션 로그, 에러/디버그/운영 기록, 분석용 로그 데이터.|1|-|Text|-|

### Summary 
- Highly production-oriented project with strong CI/CD, testing, multi-model, multiple entrypoint 

- Core 1 : LLM inference core with Scheduling engine and FastAPI provider (vllm/)
    - A. ** FRONTEND (Service level) **
    - FastAPI serving, (entrypoints/)
    - Experiment examples (examples/)
    - Metric evaluation, dataset holding (benchmarks/)

    - B. ** LLM serving (Request level) ** 
    - LLM engine, Request scheduling, metrics/protocol, multiprocessing (engine/)
    - Low-level scheduler, KV block related memory handling (core/)
    - model loading, tokenizer (model_executor/, engine/)
    - Data structure (sequence.py, sampling_params.py, outputs.py, tasks.py)
    
    - C. ** LLM Inference (Sequence/Deconding level) **
    - Model execution, layer call, decoding (model_executor.py, beam_search.py)
    - Model layers(Attention, MLP, LayerNorm ...), Diverse Attention algorithms (layers/, attention/)
    - performance analysis (profiler/)
    - Others (transformers_utils/, triton_utils/, lora/, plugins/)
    
    - D. ** Custom Attention (Algorithm level, SW) **
    - Custom attention implementation/selection/backend/utilities (attention/)
    - FlashAttention (vllm_flash_attn/)
    - Compilation: graph optimization (compilation/)


- Core 2 : Custom CUDA kernel (scrc/)
    - E. ** CUDA kernel (HW level) ** 
    - Custom attention CUDA kernel (pagedattention, flashattention, ...) (attention/)
    - KV cache handling (cache_kernels.cu)
    - LayerNorm/activation kernel (layernorm/activation_kernels.cu)
    - Memory allocation, block management (cumem_allocator.cpp)
    - Pytorch bindings, export (torch_bindings.cpp)


## P2+A2. depth >1 - documentation


### vllm/

|Folder/File|Role|Boundary|Implemented language|Priority|
|---|---|---|---|---|
|__init__.py|vllm 패키지 초기화 및 네임스페이스 관리|vllm 전체 모듈의 패키지화, 하위 모듈 임포트, 전역 네임스페이스 제공|Python|★|
|_custom_ops.py|커스텀 연산자 정의 및 바인딩|PyTorch 등에서 사용되는 특수 연산자/커널의 Python 래퍼 및 바인딩, 성능 최적화 목적|Python|★★|
|_ipex_ops.py|Intel IPEX 연산자 지원|Intel PyTorch Extension(IPEX) 연산자 래핑 및 최적화, Intel 하드웨어 특화 연산 지원|Python|★|
|beam_search.py|빔서치 알고리즘 구현|LLM 디코딩 시 다양한 후보 시퀀스를 탐색하는 빔서치 알고리즘 구현, 토큰 생성 전략|Python|★★★|
|collect_env.py|환경 정보 수집 및 진단|시스템, CUDA, 라이브러리, 패키지 버전 등 실행 환경 정보 자동 수집 및 진단 리포트 생성|Python|★|
|connections.py|네트워크 연결 및 통신 관리|서버-클라이언트, 분산 노드 간 연결 및 통신 세션 관리, 연결 상태 추적|Python|★★|
|env_override.py|환경 변수 오버라이드|런타임 중 환경 변수 동적 변경 및 복원, 실험/테스트 환경 분리|Python|★|
|envs.py|환경 변수 상수 및 관리|프로젝트 전역에서 사용하는 환경 변수 상수 정의 및 관리|Python|★|
|forward_context.py|추론 컨텍스트 관리|모델 추론 시 입력/출력, 상태, 캐시 등 컨텍스트 정보 관리 및 전달|Python|★★|
|logger.py|로깅 유틸리티|로깅 포맷, 레벨, 핸들러 등 로깅 시스템 설정 및 로그 출력|Python|★|
|logits_process.py|로짓 후처리|모델 출력 로짓에 대한 후처리(softmax, top-k, top-p 등) 및 샘플링 전처리|Python|★★|
|outputs.py|출력 데이터 구조 및 관리|모델 추론 결과(토큰, 점수 등) 구조체/클래스 정의 및 후처리|Python|★★|
|pooling_params.py|풀링 파라미터 관리|다양한 풀링 연산(average, max 등)에 필요한 파라미터 정의 및 관리|Python|★|
|py.typed|타입 힌트 지원 파일|PEP 561 기반 타입 힌트 제공, 타입 체크 툴 호환성 보장|Text|★|
|sampling_params.py|샘플링 파라미터 관리|LLM 샘플링(temperature, top-k, top-p 등) 관련 파라미터 구조체 및 검증|Python|★★|
|scalar_type.py|스칼라 타입 정의|모델 연산에 사용되는 데이터 타입(enum, 상수 등) 정의|Python|★|
|scripts.py|스크립트 유틸리티|실행, 관리, 배포 등 다양한 관리용 스크립트 함수/클래스|Python|★|
|sequence.py|시퀀스 데이터 구조 및 관리|토큰 시퀀스, 상태, 히스토리 등 시퀀스 관련 데이터 구조 및 관리|Python|★★|
|tasks.py|태스크 관리|서빙/추론 태스크(작업) 정의, 태스크 큐 관리|Python|★★|
|test_utils.py|테스트 유틸리티|테스트 자동화, 목(mock) 데이터, 검증 함수 등 테스트 지원|Python|★|
|tracing.py|트레이싱 및 성능 분석|실행 경로, 함수 호출, 성능 병목 등 트레이싱 및 분석 도구|Python|★★|
|version.py|버전 정보|vllm 패키지 버전 상수, 배포 버전 관리|Python|★|
|adapter_commons/|어댑터 공통 모듈|어댑터 레이어, 다양한 모델 구조, 요청/응답, 워커 관리 등 어댑터 관련 공통 기능|Python|★★|
|assets/|멀티모달 자산 처리|오디오, 이미지, 비디오 등 멀티모달 입력 데이터 전처리/후처리 및 관리|Python|★★|
|attention/|Attention 관련 모듈|다양한 attention 메커니즘(커스텀, 백엔드, 연산, 최적화) 구현 및 공통 유틸리티|Python|★★★★★|
|benchmarks/|벤치마크 도구|LLM 서빙/추론 성능 측정, 데이터셋 관리, 벤치마크 자동화 스크립트|Python|★★★|
|compilation/|컴파일/그래프 최적화|커스텀 컴파일러, 그래프 변환/최적화 패스, 연산 퓨전, 인덕터 등|Python|★★★★|
|config/|설정 관리|캐시, 컴파일, 병렬화, 스케줄러 등 LLM 서빙 전역 설정 및 파라미터 관리|Python|★★★|
|core/|코어 메모리/스케줄러|메모리 블록, 캐시, 스케줄러, 자원 관리 등 LLM 서빙의 핵심 인프라|Python|★★★★|
|device_allocator/|디바이스 메모리 할당|GPU 메모리 할당, 해제, 최적화 등 디바이스 자원 관리|Python|★★★|
|distributed/|분산 처리|분산 통신, 병렬 상태, 이벤트, 노드 간 데이터 동기화 등 분산 환경 지원|Python|★★★★|
|engine/|엔진/서빙 파이프라인|LLM 엔진, 요청 스케줄링, 비동기 처리, 프로토콜, 메트릭 등 서빙 파이프라인 핵심|Python|★★★★★|
|entrypoints/|엔트리포인트/서버|API 서버, 런처, CLI, 인증, 서버 실행 진입점, 외부 연동|Python|★★★★|
|executor/|실행기/실행 환경|실행기, 실행 환경, 워커 프로세스 관리, 분산 실행 지원|Python|★★★★|
|inputs/|입력 데이터 구조|입력 데이터 구조체, 파싱, 유효성 검사 등 입력 처리|Python|★★|
|logging_utils/|로깅 보조 모듈|고급 로깅, 포맷팅, 로그 필터링 등 부가 로깅 기능|Python|★|
|lora/|LoRA 관련 모듈|LoRA 어댑터, 파인튜닝, 파라미터 효율화 등 LoRA 관련 기능|Python|★★★|
|model_executor/|모델 실행기|모델 실행, 레이어, 커스텀 연산, attention, 샘플러 등 LLM 실행 핵심|Python|★★★★★|
|multimodal/|멀티모달 처리|텍스트, 이미지, 오디오 등 멀티모달 입력/출력 지원 및 처리|Python|★★★|
|platforms/|플랫폼별 지원|특정 하드웨어/운영체제/클라우드 등 플랫폼별 특화 지원|Python|★|
|plugins/|플러그인 시스템|확장 플러그인, 외부 서비스/모듈 연동, 커스텀 확장 지원|Python|★★|
|profiler/|프로파일링 도구|성능 분석, 실행 시간 측정, 병목 탐지 등 프로파일링 도구|Python|★★|
|ray/|Ray 분산 지원|Ray 기반 분산 처리, 클러스터 관리, 분산 태스크 실행|Python|★★|
|reasoning/|추론/추리 모듈|고급 reasoning, chain-of-thought, 논리적 추론 등|Python|★★|
|third_party/|외부 라이브러리|외부 코드, 서드파티 라이브러리, 외부 연동 모듈|Python|★|
|transformers_utils/|Transformers 유틸|HuggingFace transformers 연동, 변환, 커스텀 유틸리티|Python|★★★|
|triton_utils/|Triton 유틸|Triton 커널/연산 지원, 커스텀 연산, 최적화|Python|★★|
|usage/|사용법 예제/도구|사용법, 튜토리얼, 샘플 코드, 실전 활용 예시|Python|★★|
|utils/|공통 유틸리티|공통 함수, 헬퍼, 상수, 반복되는 로직 모듈화|Python|★★★|
|v1/|v1 API/구현|이전 버전 API/코드, 레거시 지원|Python|★|
|vllm_flash_attn/|FlashAttention 모듈|FlashAttention 커널, 연산, 최적화, 커스텀 구현|Python|★★★|
|worker/|워커 관리|서빙 워커, 분산 워커, 작업 분배, 상태 관리 등|Python|★★★|

### csrc/

|Folder/File|Role|Boundary|Implemented language|Priority|
|---|---|---|---|---|
|attention/|Attention 관련 CUDA 커널 및 헤더|PagedAttention, FlashAttention 등 다양한 attention 알고리즘의 CUDA 커널(`attention_kernels.cu`, `flash_attention.cu`), 템플릿/유틸리티 헤더(`*.h`, `*.cuh`), 공통 함수, 실험적 커널|CUDA, C++|★★★★★|
|activation/|Activation 함수 서브모듈|GELU, ReLU 등 활성화 함수의 다양한 CUDA 커널, 헤더, 실험적 구현, 공통 유틸리티|CUDA, C++|★★★|
|layernorm/|LayerNorm 서브모듈|LayerNorm 연산의 다양한 CUDA 커널, 헤더, 실험적 구현, 공통 유틸리티|CUDA, C++|★★★|
|kv_cache/|KV 캐시 서브모듈|KV 캐시 연산, 블록 관리, 관련 커널/헤더, 캐시 최적화 알고리즘|CUDA, C++|★★★★|
|block_space_manager/|블록 공간 관리|KV 캐시 등에서 블록 단위 메모리 공간 관리, 할당/해제 알고리즘, 헤더/구현|C++|★★★|
|sampler/|샘플링 커널|토큰 샘플링, 확률 분포 관련 CUDA 커널 및 C++ 코드, 샘플링 알고리즘|CUDA, C++|★★★|
|utils/|공통 유틸리티|공통 함수, 매크로, 반복되는 로직, 커널/호스트 코드에서 재사용되는 유틸리티|C++|★★|
|third_party/|외부 라이브러리|외부 오픈소스 커널, 라이브러리 코드, 외부 구현체 포함|C++, CUDA|★|
|test/|커널 테스트|CUDA/C++ 커널 단위 테스트 코드, 벤치마크, 검증 스크립트|C++, CUDA|★|
|activation_kernels.cu|Activation 커널 메인|GELU, ReLU 등 활성화 함수의 메인 CUDA 커널 구현|CUDA|★★★|
|layernorm_kernels.cu|LayerNorm 커널 메인|LayerNorm 연산의 메인 CUDA 커널 구현|CUDA|★★★|
|cache_kernels.cu|KV 캐시 연산 커널|KV 캐시 블록 복사, 업데이트, 압축 등 캐시 관련 커스텀 CUDA 커널|CUDA|★★★★★|
|cumem_allocator.cpp|GPU 메모리 할당기|커스텀 GPU 메모리 할당/해제, 블록 관리, 성능 최적화, 메모리 풀 구현|C++|★★★★|
|torch_bindings.cpp|PyTorch 바인딩|CUDA/C++ 커널을 Python에서 사용할 수 있도록 PyTorch와 바인딩 (pybind11 등 사용)|C++|★★★★★|
|cuda_compat.h|CUDA 호환성 헤더|CUDA 버전별 호환성, 매크로, 유틸리티 함수 정의, 플랫폼별 분기|C/C++|★★|
|utils.cmake|CMake 유틸리티|CUDA/C++ 커널 빌드 설정, 컴파일 옵션, 외부 라이브러리 연동, 빌드 자동화|CMake|★★|
|CMakeLists.txt|빌드 스크립트|csrc 전체 CUDA/C++ 커널 빌드 및 설치 스크립트, 빌드 타겟 정의|CMake|★★|
|*.h, *.cuh|헤더/인터페이스|각 커널/모듈의 함수 선언, 템플릿, 데이터 구조 정의, 공통 인터페이스|C/C++|★★|



## P3. file-level - Class documentation

vllm/engine/llm_engine -> vllm/engine/scheduler -> vllm/core/

vllm/model_executor/model_executor.py -> vllm/model_executor/layers/ -> vllm/attention/

vllm/compilation

csrc/attention/attention_kernels.cu -> csrc/attention/flash_attention.cu -> torch_bindings.cpp

### Overall flow 
1. Entrypoint (frontend, service level)
- vllm/entrypoints/api_server.py 에서 fastAPI 서버 실행
- 유저가 /generate 등 endpoint 로 POST 요청, 서버는 내부적으로 AsyncLLMEngine 에게 요청 전달 
- vllm/entrypoints/llm.py 도 llmEngine 에게 요청 전달

2. Engine (request level)
- vllm/engine/async_llm_engine.py 에서 LLM engine 정의
- AsyncLLMEngine.generate 호출 req tracker 에 기록, 비동기 generator 반환
- 매 step 마다 scheduler 는 req tracker 를 참조, 스케줄링 결과에 따라 실행 가능한 배치로 묶어 executor 에 전달.

3. Executor (sequence level) 
- vllm/executor/executor_base.py 에서 vllm/model_executor/ 에 정의된 layer 들을 이용하여 실제 모델 inference 실행
- vllm/attention/ 에 attention 관련 layer, backend option 이 구현되어 있음. 
- 각 layer 의 구현은 vllm/_custom_ops.py 의 custom CUDA kernel을 이용함

4. CUDA kernel, binding (operation level) 
- csrc/ 에서 CUDA kernel 구현, torch_bindings.cpp 에서 binding
- python 에서 paged_attention_v1 호출하면, 분기하여 적절한 paged_attention_kernel 을 넘겨줌.
- 각 kernel 은 병렬화된 CUDA 코드로 구현됨

### csrc/attention/paged_attention_v1.cu
### csrc/attention/attention_kernels.cuh

# Key experiments (with small size) 




# DCA experiments (with evaluation)
