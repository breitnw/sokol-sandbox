#define SOKOL_IMPL
#define SOKOL_GLCORE

#include <sokol/sokol_app.h>
#include <sokol/sokol_gfx.h>
#include <sokol/sokol_glue.h>
#include <sokol/sokol_log.h>

// application state
static struct {
  sg_pipeline pip;
  sg_bindings bind;
  sg_pass_action pass_action;
} state;

static void init(void);
void frame(void);
void cleanup(void);
sapp_desc sokol_main(int argc, char *argv[]);
