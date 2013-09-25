#include "ruby.h"
#include "stdio.h"
#include "sys/ioctl.h"
#include "sys/socket.h"

static VALUE t_atmark(VALUE self, VALUE fn)
{
	int fd;
	int flag;
	int result;

	fd = NUM2INT(fn);
	result = ioctl(fd, SIOCATMARK, &flag);
	if (result < 0)
		return (-1);
	return INT2NUM(flag);
}

VALUE cUrgentData;
void Init_sockatmark()
{
	//cSocket = rb_const_get(rb_cObject, rb_intern("Socket"));
	//rb_define_singleton_method(cSocket, "atmark", t_atmark, 1);

	cUrgentData = rb_define_class("UrgentData", rb_cObject);
	rb_define_method(cUrgentData, "atmark", t_atmark, 1);
}
