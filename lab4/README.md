Task #4
=======

TCP-on file transfer client-server application with out-of-band messaging

Requierments
------------

###Ruby

* Ruby version >= 1.9.3

###Gems

* Slop version ~> 3.4.6
* BinData version ~> 1.6.0

Getting Started
---------------

Start by using main to listen on a specific port, with the file which is to be transferred and OOB messaging:

    $ ruby main.rb -lv -p 1234 -f filename.out

Option <tt>-v</tt> mean verbose: allow you get file transfer stats.
Using a second machine, connect to the listening main process, with output captured into a file:

    $ ruby main.rb -v -g 127.0.0.1 -p 1234 filename.in

After the file has been transferred, the connection will close automatically.