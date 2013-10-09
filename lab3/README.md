Task #3
=======

TCP-on file transfer client-server application

Requierments
------------

###Ruby

Ruby version >= 1.9.3

Getting Started
---------------

Start by using main to listen on a specific port, with the file which is to be transferred:

    $ ruby main.rb -l 1234 filename.out

Using a second machine, connect to the listening main process, with output captured into a file:

    $ ruby main.rb 127.0.0.1 1234 filename.in

After the file has been transferred, the connection will close automatically.