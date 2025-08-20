# Distant observation

## 0. Setting 
`
set -euo pipefail
OUT="artifacts/overview_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT" logs
`

## S1. depth 1 - overview
`
(cloc . || tokei) > "$OUT/cloc.txt"
`

`
fd -td -d 2 | while read d; do
  cnt=$(fd -t f -d 3 -E .git "$d" | wc -l)
  printf "%6d  %s\n" "$cnt" "$d"
done | sort -nr > "$OUT/level1_file_counts.txt"
`

## S2. depth 1 - recent change
`
git log --since="90 days ago" --name-only --pretty= |
  grep -vE '(^$|\.md$|\.png$|\.jpg$|\.svg$)' |
  awk -F/ 'NF>1{print $1}' | sort | uniq -c | sort -nr > "$OUT/churn_90d_by_top1.txt"
`

## P1+A1. depth 1 - documentation
|Folder/File|Role|Boundary|# Files|# Chaged|Implemented language|Priority|
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
- briefly document all folders/files


# Close Look

## P2+A2. depth >1 - documentation
|Folder/File|Role|Boundary|Implemented language|Priority| 
- briefly document all folders/files

## P3. file-level - Class documentation

Role, Boundary, Data structure(memory usage), methods(time/space Complexity) 

# Flow analysis 

Sequence(generalized full pipeline), FlowXComponent matrix
 


