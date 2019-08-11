FROM centos:7

LABEL maintainer="plinecom@gmail.com"

ENV HOME /root
WORKDIR $HOME

RUN yum update -y && yum clean all

# Install packages
RUN yum -y install centos-release-scl epel-release https://centos7.iuscommunity.org/ius-release.rpm \
 && yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm \
 && yum -y install autoconf automake bison cmake3 flex gcc git \
    jack-audio-connection-kit-devel make patch pcre-devel python36u \
    python-setuptools subversion tcl yasm devtoolset-7-gcc-c++ libtool \
    libX11-devel libXcursor-devel libXi-devel libXinerama-devel \
    libXrandr-devel libXt-devel mesa-libGLU-devel zlib-devel \
    python-devel ilmbase-devel llvm-static \
    wget gcc-c++ sudo \
    SDL-devel bzip2 cmake \
    fftw-devel freetype-devel glew-devel jemalloc-devel \
    libjpeg-turbo-devel libogg-devel libpng-devel libtheora-devel \
    libtiff-devel libvorbis-devel libxml2-devel \
    openal-soft-devel openjpeg2-devel \
    readline-devel sqlite-devel \
    tbb-devel \
    tinyxml-devel yaml-cpp-devel \
    libsndfile-devel \
    x264-devel ffmpeg ffmpeg-devel \
    bzip2-devel libquadmath-devel \
 && yum clean all

# Use cmake3
RUN alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
    --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
    --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
    --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
    --family cmake

# Use python36
RUN alternatives --install /usr/bin/python3 python3 /bin/python36 20 \
    --family python3

# Install NASM
RUN curl -O https://www.nasm.us/pub/nasm/releasebuilds/2.14/nasm-2.14.tar.gz \
 && tar xf nasm-*.tar.gz && cd nasm-*/ \
 && ./configure && make && make install \
 && cd && rm -rf $HOME/nasm-*

# Instal tbb
RUN wget https://github.com/01org/tbb/archive/2019_U1.tar.gz \
 && tar xf 2019_U1.tar.gz && cd tbb-*/ \
 && make \
 && cp -R include/* /usr/local/include \
 && cp -R build/linux_intel64_gcc*release/* /usr/local/lib64/ \
 && cd && rm -rf $HOME/tbb-*

RUN sed -i -e "s/6\.1810/5\.1810/" /etc/redhat-release

# Get the source
RUN mkdir $HOME/blender-git \
 && cd $HOME/blender-git \
 && git clone https://git.blender.org/blender.git \
 && cd $HOME/blender-git/blender \
 && git checkout master \
 && git submodule update --init --recursive \
 && git submodule foreach git checkout master \
 && git submodule foreach git pull --rebase origin master

COPY start /usr/bin/
CMD ["scl", "enable", "devtoolset-7", "/usr/bin/start"]

