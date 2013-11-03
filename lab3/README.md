Task #3
=======

TCP-on file transfer client-server application

Requierments
------------

###Ruby

Ruby version >= 1.9.3

###Gems

Slop version ~ 3.4.6

Getting Started
---------------

Start by using main to listen on a specific port, with the file which is to be transferred:

    $ ruby main.rb -l -p 1234 -f filename.out

Using a second machine, connect to the listening main process, with output captured into a file:

    $ ruby main.rb -g 127.0.0.1 -p 1234 -f filename.in

After the file has been transferred, the connection will close automatically.