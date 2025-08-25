# 0. Variables
`
PY_VER="3.12"                 # uv로 만들 파이썬 버전
CUDA_VER="11.8"               # 시스템에 설치할 CUDA Toolkit 버전
CUDA_HOME="/usr/local/cuda-11.8"
ARCH_LIST="8.6"               # 예: Ampere(30xx)=8.6, Turing(20xx)=7.5, Pascal(1080)=6.1 등
JOBS="${JOBS:-4}"             # 빌드 병렬도 (WSL OOM 방지 위해 낮게)
VENV_DIR="${VENV_DIR:-.venv}" # uv venv 위치
REPO_DIR="${REPO_DIR:-$HOME/vLLM}"  # vLLM 소스 위치 (이미 클론해뒀으면 경로만 맞추기)
`

# 1. Basic package 
`
sudo apt-get update
sudo apt-get install -y build-essential git curl wget cmake ninja-build ccache \
    python3 python3-venv python3-dev
`

# 2. UV installation
`
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
`

# 3. Vllm source preparation
`
if [[ ! -d "$REPO_DIR" ]]; then
  git clone https://github.com/vllm-project/vllm.git "$REPO_DIR"
fi
cd "$REPO_DIR"
`

# 4. CUDA installation
`
wget -qO cuda-keyring.deb \
  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb || true
sudo dpkg -i cuda-keyring.deb || true
sudo apt-get update
sudo apt-get install -y "cuda-toolkit-$(echo ${CUDA_VER} | tr -d '.')"
`

# 5. Environment variables 
if ! grep -q "CUDA_HOME=${CUDA_HOME}" "$HOME/.bashrc"; then
  {
    echo "export CUDA_HOME=${CUDA_HOME}"
    echo 'export PATH=$CUDA_HOME/bin:$PATH'
    echo 'export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH'
  } >> "$HOME/.bashrc"
fi
export CUDA_HOME PATH LD_LIBRARY_PATH

# 6. UV virtual environment 
`
uv venv --python "${PY_VER}" --seed "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"
`

# 7. Torch installation
`
pip install --upgrade pip wheel
pip install "torch==2.7.1+cu118" "torchvision==0.22.0+cu118" "torchaudio==2.7.1+cu118" \
  --index-url https://download.pytorch.org/whl/cu118

python - <<'PY'
import torch
print("Torch:", torch.__version__, "CUDA:", torch.version.cuda, "is_available:", torch.cuda.is_available())
PY
`

# 8. Preset config -> build 
`
export MAX_JOBS="${JOBS}"
export CMAKE_BUILD_PARALLEL_LEVEL="${JOBS}"
export TORCH_CUDA_ARCH_LIST="${ARCH_LIST}"

python tools/generate_cmake_presets.py <<EOF
EOF

cmake --version   # 3.27+ 권장 (낮으면: uv pip install 'cmake>=3.27')
cmake --preset release

cmake --build --preset release --target install -j "${JOBS}"
`

# 9. pip install 
`
export VLLM_USE_PRECOMPILED=0
uv pip install -r requirements/build.txt --extra-index-url https://download.pytorch.org/whl/cu118
uv pip install -e .
`

# 10. verification
`
python - <<'PY'
import vllm, torch, inspect
print("torch.cuda:", torch.version.cuda)
import vllm._C as core
print("vllm core so:", inspect.getfile(core))
print("OK: vLLM core loaded.")
PY
`