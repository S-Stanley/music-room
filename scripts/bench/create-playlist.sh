#!/bin/bash

ab -n 10000 -c 200 -H "token:c055fb5c-7d35-42a8-b4e7-a20a706d999b" -p <(echo -n "name=ok&orderType=VOTE&type=PUBLIC") -T "application/x-www-form-urlencoded" "localhost:5001/playlist/"
