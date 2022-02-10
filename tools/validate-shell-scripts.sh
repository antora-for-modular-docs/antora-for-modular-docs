#!/bin/sh
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
        MAINBRANCH="origin/main"
    else
        MAINBRANCH="origin/$GITHUB_BASE_REF"
fi
FILES=$(git diff --name-only --diff-filter=AM "$MAINBRANCH" | xargs -n1  file | grep script | cut -d: -f1)
if [ -n "${FILES}" ]
    then
        echo "Validating shell scripts added or modified in comparison to $MAINBRANCH"
        set -x
        # shellcheck disable=SC2086 # We want to split on spaces
        shellcheck ${FILES}
    else
        echo "No shell scripts added or modified in comparison to $MAINBRANCH"
fi
