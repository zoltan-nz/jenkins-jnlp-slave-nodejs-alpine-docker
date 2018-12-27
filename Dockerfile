FROM jenkins/jnlp-slave:alpine

USER root

# Source: https://github.com/mhart/alpine-node/blob/master/Dockerfile
# Licence: https://github.com/mhart/alpine-node/blob/master/LICENSE
ENV VERSION=v11.12.0 NPM_VERSION=6 YARN_VERSION=latest

# For base builds
ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk add --no-cache curl curl-dev make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
    curl -sfSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
    tar -xf node-${VERSION}.tar.xz && \
    cd node-${VERSION} && \
    ./configure --prefix=/usr ${CONFIG_FLAGS} && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    cd / && \
    if [ -z "$CONFIG_FLAGS" ]; then \
    if [ -n "$NPM_VERSION" ]; then \
    npm install -g npm@${NPM_VERSION}; \
    fi; \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
    if [ -n "$YARN_VERSION" ]; then \
    curl -sfSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
    gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
    mkdir /usr/local/share/yarn && \
    tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
    ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
    ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
    rm ${YARN_VERSION}.tar.gz*; \
    fi; \
    fi && \
    apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS} && \
    rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
    { rm -rf /root/.gnupg || true; }

USER jenkins