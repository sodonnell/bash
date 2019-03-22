#!/usr/bin/env bash
#
# Simple Apache Benchmark Script for HTTP Service
# Stress Testing and Performance Analysis.
#
# Requires: ab
#
# CentOS:
# $ yum install httpd-tools
#
# Ubuntu:
# $ apt install apache-utils
#
# Author: Sean O'Donnell <sean@seanodonnell.com>
#

# Stress Frequency
# Number of concurrent user/connection during simulation
NUM_CONS=500;
# Number of requests per simulated user
NUM_REQS=1000;

# Stress Targets
BASE_URL="https://www.mysite.net";

# Authentication Endpoint and Data Info
#AUTH_EP="${BASE_URL}/login"; # un-comment if using a custom login page.
AUTH_POST_TYPE="application/x-www-form-urlencoded";
AUTH_POST_DATA="post.txt"; # format: email=some.geek@spambot.net&password=some.weak.passwd

# Application Endpoints (example)
APP_EPS=(
    blog
    about
    about/work
    about/portfolio
    about/resume
    cart
    faq
    photos
    photos/albums
    photos/selfies
    photos/family
);

# "Authenticate"
if [ ! -z ${AUTH_EP} ]; then
    ab -n ${NUM_REQS} -c ${NUM_CONS} -T ${AUTH_POST_TYPE} -p ${AUTH_POST_DATA} ${AUTH_EP}
fi

# Hit the APP Endpoints
if [ ! -z ${APP_EPS} ]; then
    for i in ${APP_EPS[@]}; do
        ab -n ${NUM_REQS} -c ${NUM_CONS} ${BASE_URL}/${i}
    done;
fi;
