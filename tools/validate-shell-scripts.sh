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
if [ -z "${GITHUB_BASE_REF}" ]
    then 
        MainBranch="origin/main"
    else
        MainBranch="origin/$GITHUB_BASE_REF"
fi
Files=$(git diff --name-only --diff-filter=AM "$MainBranch" | xargs -n1  file | grep script | cut -d: -f1)
if [ -n "${Files}" ]
    then
        echo "Validating shell scripts added or modified in comparison to $MainBranch"
        set -x
        # shellcheck disable=SC2086 # We want to split on spaces
        shellcheck ${Files}
    else
        echo "No shell scripts added or modified in comparison to $MainBranch"
fi
