#!/usr/bin/env bash

bin/cli db:create > /dev/null 2>&1
bin/cli db:migrate > /dev/null 2>&1

bin/server