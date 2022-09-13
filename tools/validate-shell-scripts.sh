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

Files=$(find . -type f | grep -v './.git' | xargs -n1  file | grep script | cut -d: -f1)
if [ -n "${Files}" ]
    then
        echo "Validating shell scripts"
        set -x
        # shellcheck disable=SC2086 # We want to split on spaces
        shellcheck ${Files}
    else
        echo "No shell scripts to validate"
fi
