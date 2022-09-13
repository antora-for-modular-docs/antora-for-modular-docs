#!/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -e
vale --version
# Get fresh vale styles
vale sync
if [ -z "${GITHUB_BASE_REF}" ]
    then
        MainBranch="origin/main"
    else
        MainBranch="origin/$GITHUB_BASE_REF"
fi
git config --global --add safe.directory /projects
git status
Files=$(git diff --name-only --diff-filter=AM "$MainBranch")
if [ -n "${Files}" ]
    then
        echo "Validating languages on file added or modified in comparison to $MainBranch with $(vale -v)"
        set -x
        # shellcheck disable=SC2086 # We want to split on spaces
        vale ${Files}
    else
        echo "No files added or modified in comparison to $MainBranch"
fi
