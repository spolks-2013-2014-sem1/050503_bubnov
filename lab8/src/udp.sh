#!/bin/bash

parallel sh -c "ruby main.rb -u -g 127.0.0.1 -p 5555 -f i.mp3" -- 1 2 3 4
