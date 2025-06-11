#!/bin/bash

ab -n 100000 -c 249 -H "token:c055fb5c-7d35-42a8-b4e7-a20a706d999b" "localhost:5001/playlist/"
