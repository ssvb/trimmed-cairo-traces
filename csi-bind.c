#include <cairo.h>
#include <cairo-script-interpreter.h>

#include <stdio.h>

static cairo_status_t
write (void *closure, const unsigned char *data, unsigned int length)
{
    if (fwrite (data, length, 1, closure) != 1)
	return CAIRO_STATUS_WRITE_ERROR;

    return CAIRO_STATUS_SUCCESS;
}

int
main (void)
{
    return cairo_script_interpreter_translate_stream (stdin, write, stdout);
}
