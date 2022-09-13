# Container definition
#
# Copyright (c) 2022 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Fedora has DNF packages for Htmltest and ShellCheck.
FROM quay.io/fedora/nodejs-16:latest
USER root

EXPOSE 4000
EXPOSE 35729

ENV NAME="Antora for modular docs"
ENV SUMMARY="Platform for building documentation websites powered by Antora and compliant with modular docs."
ENV DESCRIPTION="The container contains Antora, some Antora extensions, some Asciidoctor extensions, Git CLI, Graphviz, Htmltest, Vale, and some additional tools."

LABEL description="$DESCRIPTION" \
    io.k8s.description="$DESCRIPTION" \
    io.k8s.display-name="$NAME" \
    io.openshift.expose-services="4000:http" \
    license="EPL" \
    MAINTAINERS="$NAME maintainers" \
    maintainer="$NAME maintainers" \
    name="quay.io/antoraformodulardocs/antora-for-modular-docs" \
    source="https://github.com/antora-for-modular-docs/antora-for-modular-docs/blob/main/Dockerfile" \
    summary="$SUMMARY" \
    URL="quay.io/antoraformodulardocs/antora-for-modular-docs" \
    vendor="$NAME" \
    version="2022.09"

# Upgrade the system
RUN dnf upgrade --assumeyes --quiet
# Install DNF packages
RUN set -x \
    && dnf install --assumeyes --quiet dnf-plugins-core \
    && dnf copr enable --assumeyes --quiet mczernek/vale \
    && dnf install --assumeyes --quiet \
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
    ShellCheck \
    tar \
    unzip \
    vale \
    wget \
    yarnpkg \
    && dnf clean all

# Install Python packages
RUN set -x \
    && pip3 install --no-cache-dir --no-input \
    diagrams \
    yq

# Avoid error: Local gulp not found in /projects
ENV NODE_PATH="/usr/local/share/.config/yarn/global/node_modules"
# Install Node.js packages
RUN set -x \
    && yarnpkg global add --non-interactive \
    @antora/cli \
    @antora/collector-extension \
    @antora/lunr-extension \
    @antora/site-generator \
    asciidoctor \
    asciidoctor-emoji \
    asciidoctor-kroki \
    gulp \
    gulp-cli \
    gulp-connect \
    js-yaml \
    && npm cache clean --force \
    && rm /tmp/* -rfv

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
