# 0. Source code fork, clone + Basic package 
(in Ubuntu 22.04)
sudo apt update

sudo apt install python3.10 python3.10-venv python3.10-dev cmake build-essential git

# 1. Virtual environment setting
python3.10 -m venv vllm-env
source vllm-env/bin/activate

# 2. torch install with correct CUDA version
pip install --upgrade pip
pip install torch --index-url https://download.pytorch.org/whl/cu118

# 3. Python requirements 
pip install -r requirements/build.txt
pip install -r requirements/cuda.txt
pip install -r requirements/common.txt

pip install -r requirements/dev.txt
pip install -r requirements/test.txt

# 4. Build vllm
pip install .

# 5. Generation 
python examples/offline_inference/basic/generate.py --model <모델경로> --prompt "Hello, world!"