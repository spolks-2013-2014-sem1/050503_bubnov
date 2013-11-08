#!/bin/bash

(ruby main.rb -u -g 127.0.0.1 -p 5555 -f 1.mp3;
 ruby main.rb -u -g 127.0.0.1 -p 5555 -f 2.mp3;
 ruby main.rb -u -g 127.0.0.1 -p 5555 -f 3.mp3) | parallel

#parallel sh -c "ruby main.rb -u -g 127.0.0.1 -p 5555 -f i.mp3" -- 1 2 3 4
