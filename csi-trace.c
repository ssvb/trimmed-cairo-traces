#include <cairo-script.h>
#include <cairo-script-interpreter.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <setjmp.h>
#include <time.h>

static jmp_buf jmp;
static time_t timeout;

static cairo_format_t
format_from_content (cairo_content_t content)
{
    switch (content) {
    case CAIRO_CONTENT_ALPHA: return CAIRO_FORMAT_A8;
    case CAIRO_CONTENT_COLOR: return CAIRO_FORMAT_RGB24;
    default:
    case CAIRO_CONTENT_COLOR_ALPHA: return CAIRO_FORMAT_ARGB32;
    }
}

static cairo_surface_t *
_script_surface_create (void *closure,
			 cairo_content_t content,
			 double width, double height,
			 long uid)
{
    cairo_surface_t *surface, *image;
    cairo_rectangle_t extents;

    /* use a image target so that we can use this surface as a source */
    image = cairo_image_surface_create (format_from_content (content),
					ceil (width), ceil (height));
    surface = cairo_script_surface_create_for_target (closure, image);
    cairo_surface_destroy (image);

    return surface;
}

static cairo_t *
_script_context_create (void *closure,
			cairo_surface_t *surface)
{
    if (timeout && time (NULL) > timeout)
	longjmp (jmp, 1);

    return cairo_create (surface);
}

static cairo_status_t
write (void *closure, const unsigned char *data, unsigned int length)
{
    if (fwrite (data, length, 1, closure) != 1)
	return CAIRO_STATUS_WRITE_ERROR;

    return CAIRO_STATUS_SUCCESS;
}

int
main (int argc, char **argv)
{
    const cairo_script_interpreter_hooks_t hooks = {
	.closure = cairo_script_create_for_stream (write, stdout),
	.surface_create = _script_surface_create,
	.context_create = _script_context_create,
    };
    cairo_script_interpreter_t *csi;
    int i;

    for (i = 1; i < argc; i++) {
	if (strcmp (argv[i], "--trim") == 0) {
	    timeout = atoi (argv[i+1]);
	    i++;
	} else if (strncmp (argv[i], "--trim=", 7) == 0) {
	    timeout = atoi (argv[i] + 7);
	} else if (strcmp (argv[i], "--version")) {
	    printf ("%s: version %s\n", argv[0], __DATE__);
	    exit (0);
	} else if (strcmp (argv[i], "--help")) {
	    printf ("usage: %s [--trim=max.seconds] < in > out\n", argv[0]);
	    exit (0);
	}
    }

    if (timeout)
	timeout += time (NULL);

    csi = cairo_script_interpreter_create ();
    cairo_script_interpreter_install_hooks (csi, &hooks);
    if (setjmp (jmp) == 0)
	cairo_script_interpreter_feed_stream (csi, stdin);
    cairo_device_destroy (hooks.closure);
    return cairo_script_interpreter_destroy (csi);
}
