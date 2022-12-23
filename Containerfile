# Container definition
#
# Copyright (c) 2022 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Require podman to run ccutil
FROM quay.io/podman/stable:latest

# Require superuser privileges to install packages
USER root

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
    version="2022.12"

# Install DNF packages
RUN set -x \
    && dnf upgrade --assumeyes --quiet \
    && dnf install --assumeyes --quiet \
    ShellCheck \
    bash \
    curl \
    file \
    findutils \
    git-core \
    graphviz \
    grep \
    htmltest \
    jq \
    nodejs \
    python3-jinja2-cli \
    python3-pip \
    python3-wheel \
    rsync \
    rubygem-bundler \
    shyaml \
    tar \
    tox \
    tree \
    unzip \
    vale \
    wget \
    which \
    && dnf clean all --quiet \
    && dot -v \
    && node --version \
    && ruby --version \
    && vale --version
# Install Python packages
RUN set -x \
    && pip3 install --no-cache-dir --no-input --quiet \
    diagrams \
    yq \
    && yq --versionq

# Install Node.js packages
ARG ANTORA_VERSION=3.0.2
RUN set -x \
    && corepack enable \
    && yarnpkg global add --non-interactive \
    @antora/cli@${ANTORA_VERSION} \
    @antora/lunr-extension \
    @antora/site-generator@${ANTORA_VERSION} \
    asciidoctor \
    asciidoctor-emoji \
    asciidoctor-kroki \
    gulp \
    gulp-cli \
    gulp-connect \
    js-yaml \
    && npm cache clean --force \
    && rm /tmp/* -rfv

# Avoid error: Local gulp not found in /projects
ENV NODE_PATH="/usr/local/share/.config/yarn/global/node_modules"
VOLUME /projects
WORKDIR /projects
USER 1001

RUN set -x \
    && antora --version \
    && asciidoctor --version \
    && bash --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && htmltest --version \
    && jinja2 --version \
    && jq --version \
    && pip3 freeze \
    && vale -v \
    && yarn --version \
    && yarnpkg global list \
    && yq --version
