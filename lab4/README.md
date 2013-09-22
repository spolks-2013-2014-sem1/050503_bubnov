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

    <tt>$ ruby netdup.rb -lv 1234 < filename.in</tt>

Option <tt>-v</tt> mean verbose: allow you get file transfer stats.
Using a second machine, connect to the listening netdup process, with output captured into a file:

    <tt>$ ruby netdup.rb -v 127.0.0.1 1234 > filename.out</tt>

After the file has been transferred, the connection will close automatically.