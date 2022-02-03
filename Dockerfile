# Copyright © 2022 Red Hat, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# Build binaries in another container
FROM registry.access.redhat.com/ubi8/go-toolset as builder
USER root

# Build htmltest
WORKDIR /htmltest
ARG HTMLTEST_VERSION=0.15.0
RUN wget -qO- https://github.com/wjdp/htmltest/archive/refs/tags/v${HTMLTEST_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${HTMLTEST_VERSION}" -o bin/htmltest . \
    &&  /htmltest/bin/htmltest --version

# Build vale
WORKDIR /vale
ARG VALE_VERSION=2.14.0
RUN wget -qO- https://github.com/errata-ai/vale/archive/v${VALE_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${VALE_VERSION}" -o bin/vale ./cmd/vale \
    &&  /vale/bin/vale --version

# Prapare the container
FROM registry.access.redhat.com/ubi8/nodejs-16
USER root

COPY --from=builder /vale/bin/vale /usr/local/bin/vale
COPY --from=builder /htmltest/bin/htmltest /usr/local/bin/htmltest

EXPOSE 4000
EXPOSE 35729

LABEL description="Tools to build documentation using Antora for modular docs." \
    io.k8s.description="Tools to build documentation using Antora for modular docs." \
    io.k8s.display-name="Antora for modular docs" \
    license="MIT" \
    MAINTAINERS="Antora for modular docs team" \
    maintainer="Antora for modular docs team" \
    name="" \
    source="https://github.com/eclipse/che-docs/blob/main/Dockerfile" \
    summary="Tools to build documentation using Antora for modular docs" \
    URL="quay.io/antoraformodulardocs/antora-for-modular-docs" \
    vendor="Antora for modular docs team" \
    version="2022.01"

ARG ANTORA_VERSION=3.0.0
RUN dnf install -y \
    bash \
    curl \
    findutils \
    git-core \
    grep \
    jq \
    nodejs \
    python3-pip \
    python3-wheel \
    tar \
    && pip3 install --no-cache-dir --no-input \
    diagrams \
    jinja2-cli \
    yq \
    && npm install --global \
    @antora/cli@${ANTORA_VERSION} \
    @antora/lunr-extension \
    @antora/site-generator@${ANTORA_VERSION} \
    asciidoctor \
    gulp \
    gulp-cli \
    gulp-connect \
    js-yaml
# && useradd --create-home --uid 1001 docsbuilder

ENV NODE_PATH="/opt/app-root/src/.npm-global/lib/node_modules/"
VOLUME /projects
WORKDIR /projects
USER 1001

RUN antora --version \
    && asciidoctor --version \
    && bash --version \
    && curl --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && htmltest --version \
    && jinja2 --version \
    && jq --version \ 
    && vale -v \
    && yq --version 
