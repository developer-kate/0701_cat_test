# 사용할 기본 이미지 (Python 3.10이 필요하므로 이를 포함하는 이미지 사용)
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# 환경 변수 설정 (Optional, 필요에 따라 추가)
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.10
ENV PATH="/root/miniconda3/bin:${PATH}"
ENV HF_HOME="/app/cache/transformers"
ENV TRANSFORMERS_CACHE="/app/cache/transformers"

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Miniconda 설치
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /root/miniconda3 && \
    rm miniconda.sh

# Conda 환경 설정 및 활성화
RUN conda init bash
RUN conda create -n cat2 python=${PYTHON_VERSION} -y
SHELL ["conda", "run", "-n", "cat2", "/bin/bash", "-c"]

# 작업 디렉토리 설정
WORKDIR /app

# 현재 프로젝트 파일을 컨테이너로 복사
COPY . /app

# Python 종속성 설치
RUN pip install -e .

# 체크포인트 다운로드 (Conda 환경 내에서 실행)
RUN cd checkpoints && bash download_ckpts.sh && cd ..

# 컨테이너 시작 시 실행될 기본 명령어 (예시: 추론 스크립트 실행)
# 실제 사용 시 이 부분을 변경해야 합니다.
# CMD ["conda", "run", "-n", "cat2", "bash", "inference.sh"]
