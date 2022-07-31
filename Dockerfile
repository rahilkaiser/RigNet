ARG CUDA_BASE_VERSION=11.0
FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

# install apt dependencies
RUN apt-get update && apt-get install -y \
	git \
	vim \
	wget \
	software-properties-common \
	curl \
	libglu1-mesa-dev freeglut3-dev mesa-common-dev libosmesa6-dev

# install newest cmake version
RUN apt-get purge cmake && cd ~ && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar -xvf cmake-3.14.5.tar.gz
RUN cd ~/cmake-3.14.5 && ./bootstrap && make -j6 && make install

RUN chsh -s /bin/bash
RUN apt-get install -y libgl1-mesa-glx \
    libegl1-mesa \
    libxrandr2 \
    libxrandr2 \
    libxss1 \
    libxcursor1 \
    libxcomposite1 \
    libasound2 \
    libxi6 \
    libxtst6 \
    libxmu6 \
    libnvidia-gl-440 \
    python3-rtree
    
#Install Anaconda 
RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
RUN bash Anaconda3-2020.02-Linux-x86_64.sh -b
ENV PATH=/root/anaconda3/bin:${PATH} 

SHELL ["/bin/bash", "-c"]
RUN source /root/.bashrc

RUN conda update -y conda
RUN conda list

SHELL ["/bin/bash", "-c", "-i","-l"]
RUN conda init bash && source /root/.bashrc && conda create --name rignet_cuda11 python=3.6 && conda activate rignet_cuda11
RUN echo "conda activate rignet_cuda11" >> ~/.bashrc

RUN conda activate rignet_cuda11 && pip install open3d==0.9.0 "rtree>=0.8,<0.9" trimesh[all] numpy scipy matplotlib tensorboard opencv-python
    
RUN conda activate rignet_cuda11 && conda install -y -c pytorch pytorch==1.7.1 torchvision==0.8.2 cudatoolkit=11.0

RUN conda activate rignet_cuda11 && pip install --no-index torch-scatter torch-sparse torch-cluster -f https://pytorch-geometric.com/whl/torch-1.7.1+cu110.html

RUN conda activate rignet_cuda11 && pip install torch-geometric==1.7.2

WORKDIR /usr/src/app
COPY . .

ENV CUDAFLAGS='-DNDEBUG=1'