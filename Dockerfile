FROM nvidia/cuda:10.2-cudnn7-devel

# Envrinment settings
ENV SETUSER root
ENV SRC_ROOT /home/$SETUSER/occupancy_networks
ENV CONDA_ENV mesh_funcspace
SHELL ["/bin/bash", "-c"]

# CUDA
ENV PATH /usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Apt
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils
RUN apt-get install -y git wget curl zsh bzip2 unzip vim build-essential cmake
RUN apt-get install -y mesa-utils mesa-common-dev libglu1-mesa-dev libglew-dev libglib2.0-dev

# Oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -q -O miniconda.sh
RUN chmod +x miniconda.sh && ./miniconda.sh -b -p /opt/conda
ENV PATH /opt/conda/bin:$PATH
SHELL ["/usr/bin/zsh", "-c"]
RUN conda init zsh
RUN conda install python=3.7

# Clone repo
ARG CACHE_DATE=2016-01-01
RUN git clone https://github.com/tatsy/occupancy_networks $SRC_ROOT

# Setup
RUN cd $SRC_ROOT && \
    conda env create --file environment.yaml
RUN echo "conda activate mesh_funcspace" >> ~/.zshrc
SHELL ["conda", "run", "-n", "mesh_funcspace", "/usr/bin/zsh", "-c"]

RUN cd $SRC_ROOT && \
    python setup.py build_ext --inplace

WORKDIR $SRC_ROOT
CMD ["/usr/bin/zsh"]
