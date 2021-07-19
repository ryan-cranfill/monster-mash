FROM ubuntu

RUN apt-get update -y && DEBIAN_FRONTEND="noninteractive" apt-get -y install cmake git python3 curl unzip

RUN cd /opt && git clone https://github.com/emscripten-core/emsdk.git && cd emsdk && \
    ./emsdk install latest && ./emsdk activate latest

COPY third_party /app/third_party
RUN cd /app/third_party && mkdir triangle && cd triangle && \
    curl http://www.netlib.org/voronoi/triangle.zip -O && \
    unzip triangle.zip && rm triangle.zip

COPY data /app/data
COPY src /app/src
RUN /bin/bash -c "source "/opt/emsdk/emsdk_env.sh" && \
    cd /app/src && \
    mkdir -p build/Release && cd build/Release && \
    cmake ../../. -D CMAKE_C_COMPILER=emcc -D CMAKE_CXX_COMPILER=em++ -D CMAKE_BUILD_TYPE=Release && \
    make"

WORKDIR /app/src/build/Release

RUN mkdir includes && cd includes && \
    cp ../../../ui/* . && \
    cp ../../../../third_party/FileSaver/FileSaver.js . && \
    cp ../../../../third_party/emscripten-ui/module.js .

EXPOSE 8000

ENTRYPOINT [ "python3" ]
CMD [ "-m", "http.server", "8000" ]
