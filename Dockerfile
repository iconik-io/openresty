# This is all based no https://github.com/openresty/openresty/blob/master/.travis.yml

FROM ubuntu:noble

RUN apt-get -y update && apt-get -y install \
      wget \
      patch \
      gcc \
      axel \
      dos2unix \
      libgd-dev \
      dos2unix \
      libpcre3 \
      libpcre3-dev \
      mercurial \
      libpq-dev \
      cpanminus \
      && \
    apt-get clean 

ENV PCRE_PREFIX=/opt/pcre2 \
    OPENSSL_PREFIX=/opt/ssl3

ENV JOBS=3 \
    PCRE_VER=10.44 \
    PCRE_LIB=$PCRE_PREFIX/lib \
    PCRE_INC=$PCRE_PREFIX/include \
    OPENSSL_LIB=$OPENSSL_PREFIX/lib \
    OPENSSL_INC=$OPENSSL_PREFIX/include \
    OPENRESTY_PREFIX=/opt/openresty \
    OPENSSL_VER=3.0.15 \
    OPENSSL_PATCH_VER=3.0.15


ADD patches /patches

RUN <<__EOF__
  set -ex
  mkdir download-cache
  cpanm --notest Test::Nginx IPC::Run3 # > build.log 2>&1 || (cat build.log && exit 1)
  wget -P download-cache https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VER}/pcre2-${PCRE_VER}.tar.gz
  tar zxf download-cache/pcre2-${PCRE_VER}.tar.gz
  pwd
  cd pcre2-$PCRE_VER/
  pwd
  ./configure --prefix=${PCRE_PREFIX} --enable-jit --enable-utf --enable-unicode-properties # > build.log 2>&1 || (cat build.log && exit 1)
  make -j$JOBS # > build.log 2>&1 || (cat build.log && exit 1)
  PATH=$PATH make install # > build.log 2>&1 || (cat build.log && exit 1)
  pwd
  cd ..
  pwd

  wget -P download-cache https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz
  tar zxf download-cache/openssl-$OPENSSL_VER.tar.gz
  cd openssl-$OPENSSL_VER/
  pwd
  patch -p1 < ../patches/openssl-$OPENSSL_PATCH_VER-sess_set_get_cb_yield.patch
  pwd
  ./config no-threads shared enable-ssl3 enable-ssl3-method -g --prefix=$OPENSSL_PREFIX -DPURIFY # > build.log 2>&1 || (cat build.log && exit 1)
  make -j$JOBS # > build.log 2>&1 || (cat build.log && exit 1)
  make PATH=$PATH install_sw # > build.log 2>&1 || (cat build.log && exit 1)
  cd ..
__EOF__

RUN apt-get -y update && apt-get -y install git
