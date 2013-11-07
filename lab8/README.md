Task #8
=======

TCP&UDP-on file transfer client-server application with out-of-band messaging.

Requierments
------------

###Ruby

Ruby version >= 1.9.3

###Gems

Slop version ~ 3.4.6
Process Shared version ~ 0.1.7

Getting Started
---------------

Start by using main to listen on a specific port, with the file which is to be transferred through UDP protocol:

    $ ruby main.rb -lu -p 1234

or through TCP protocol:

    $ruby main.rb -l -p 1234

Option <tt>-v</tt> mean verbose: allow you get file transfer stats (available only via TCP protocol).
Using a second machine, connect to the listening main process, with output captured into a file:

    $ ruby main.rb -u -g 127.0.0.1 -p 1234 -f filename.in

After the file has been transferred, the connection will close automatically.