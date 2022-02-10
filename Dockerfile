# Container definition
#
# Copyright (c) 2022 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Build binaries in a temporary container
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
ARG VALE_VERSION=2.15.0
RUN wget -qO- https://github.com/errata-ai/vale/archive/v${VALE_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${VALE_VERSION}" -o bin/vale ./cmd/vale \
    &&  /vale/bin/vale --version

# Download shellcheck
ARG SHELLCHECK_VERSION=0.8.0
RUN wget -qO- https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.$(uname -m).tar.xz | tar -C /usr/local/bin/ --no-anchored 'shellcheck' --strip=1 -xJf -

# Prepare the container
FROM registry.access.redhat.com/ubi8/nodejs-16
USER root

COPY --from=builder /vale/bin/vale /usr/local/bin/vale
COPY --from=builder /htmltest/bin/htmltest /usr/local/bin/htmltest
COPY --from=builder /usr/local/bin/shellcheck /usr/local/bin/shellcheck

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

ARG ANTORA_VERSION=3.0.1
RUN dnf install -y \
    bash \
    curl \
    file \
    findutils \
    git-core \
    grep \
    jq \
    nodejs \
    python3-pip \
    python3-wheel \
    tar \
    unzip \
    wget \
    && dnf clean all \
    && pip3 install --no-cache-dir --no-input \
    diagrams \
    jinja2-cli \
    yq \
    && npm install -g  \
    @antora/cli@${ANTORA_VERSION} \
    @antora/lunr-extension \
    @antora/site-generator@${ANTORA_VERSION} \
    asciidoctor \
    gulp \
    gulp-cli \
    gulp-connect \
    js-yaml \
    && npm cache clean --force \
    && rm /tmp/* -rfv \
    && corepack enable 

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
    && yarn --version \
    && yq --version 
