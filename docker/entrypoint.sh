#!/usr/bin/env bash

bin/cli db:create > /dev/null 2>&1
bin/cli db:migrate > /dev/null 2>&1

# We don't know how long the server has been down, so run a prune job
bin/cli prune

bin/server