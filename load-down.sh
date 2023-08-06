#!/bin/bash

set -o allexport
source .env
source .env.local
set +o allexport

docker-compose down