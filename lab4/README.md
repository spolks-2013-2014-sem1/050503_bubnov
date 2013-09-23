Task #4
=======

TCP-on file transfer client-server application with out-of-band messaging

Requierments
------------

###Ruby

Ruby version >= 1.9.3

Getting Started
---------------

Start by using netdup to listen on a specific port, with the file which is to be transferred and OOB messaging:

    $ ruby netdup.rb -lv 1234 < filename.in

Option <tt>-v</tt> mean verbose: allow you get file transfer stats.
Using a second machine, connect to the listening netdup process, with output captured into a file:

    $ ruby netdup.rb -v 127.0.0.1 1234 > filename.out

After the file has been transferred, the connection will close automatically.