#!/usr/bin/env bash

apt-get update -qq -y
apt-get install -qq -y wget tree libglib2.0-0 libicu-dev libicu55 \
                       libegl1-mesa
