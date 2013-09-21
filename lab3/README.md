Task #3
=======

TCP-on file transfer client-server application

Requierments
------------

###Ruby

Ruby version >= 1.9.3

Getting Started
---------------

Start by using netdup to listen on a specific port, with the file which is to be transferred:
    $ ruby netdup.rb -l 1234 < filename.in

Using a second machine, connect to the listening netdup process, with output captured into a file:
    $ ruby netdup.rb 127.0.0.1 1234 > filename.out

After the file has been transferred, the connection will close automatically.