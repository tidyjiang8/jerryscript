#!/bin/bash

# Copyright 2016 Samsung Electronics Co., Ltd.
# Copyright 2016 University of Szeged
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [[ "$OSTYPE" == "linux"* ]]; then
    CPPCHECK_JOBS=${CPPCHECK_JOBS:=$(nproc)}
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CPPCHECK_JOBS=${CPPCHECK_JOBS:=$(sysctl -n hw.ncpu)}
else
    CPPCHECK_JOBS=${CPPCHECK_JOBS:=1}
fi

JERRY_CORE_DIRS=`find jerry-core -type d`
JERRY_PORT_DEFAULT_DIRS=`find targets/default -type d`
JERRY_LIBC_DIRS=`find jerry-libc -type d`
JERRY_LIBM_DIRS=`find jerry-libm -type d`

INCLUDE_DIRS=()
for DIR in $JERRY_CORE_DIRS $JERRY_PORT_DEFAULT_DIRS $JERRY_LIBC_DIRS $JERRY_LIBM_DIRS
do
 INCLUDE_DIRS=("${INCLUDE_DIRS[@]}" "-I$DIR")
done

cppcheck -j$CPPCHECK_JOBS --force \
 --language=c --std=c99 \
 --enable=warning,style,performance,portability,information \
 --quiet --template="{file}:{line}: {severity}({id}): {message}" \
 --error-exitcode=1 \
 --exitcode-suppressions=tools/cppcheck/suppressions-list \
 --suppressions-list=tools/cppcheck/suppressions-list \
 "${INCLUDE_DIRS[@]}" \
 jerry-core targets/default jerry-libc jerry-libm *.c *h tests/unit
