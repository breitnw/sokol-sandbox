#include "main.h"
#include "shaders/triangle.glsl.h"

static void init(void) {
  sg_setup(&(sg_desc){
      .environment = sglue_environment(),
      .logger.func = slog_func,
  });

  // a vertex buffer with 3 vertices
  float vertices[] = {// positions            // colors
                      0.0f,  0.5f,  0.5f, 1.0f, 0.0f, 1.0f, 1.0f,
                      0.5f,  -0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 1.0f,
                      -0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 1.0f};
  state.bind.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
      .data = SG_RANGE(vertices), .label = "triangle-vertices"});

  // create shader from code-generated sg_shader_desc
  sg_shader shd = sg_make_shader(triangle_shader_desc(sg_query_backend()));

  // create a pipeline object (default render states are fine for triangle)
  sg_pipeline_desc pipeline_desc = {
      .shader = shd,
      // if the vertex layout doesn't have gaps, don't need
      // to provide strides and offsets
      .layout = {.attrs = {[ATTR_triangle_position].format =
                               SG_VERTEXFORMAT_FLOAT3,
                           [ATTR_triangle_color0].format =
                               SG_VERTEXFORMAT_FLOAT4}},
      .label = "triangle-pipeline"};
  state.pip = sg_make_pipeline(&pipeline_desc);

  // a pass action to clear framebuffer to black
  state.pass_action =
      (sg_pass_action){.colors[0] = {.load_action = SG_LOADACTION_CLEAR,
                                     .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}}};
}

void frame(void) {
  sg_begin_pass(
      &(sg_pass){.action = state.pass_action, .swapchain = sglue_swapchain()});
  sg_apply_pipeline(state.pip);
  sg_apply_bindings(&state.bind);
  sg_draw(0, 3, 1);
  sg_end_pass();
  sg_commit();
}

void cleanup(void) { sg_shutdown(); }

sapp_desc sokol_main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;
  return (sapp_desc){
      .init_cb = init,
      .frame_cb = frame,
      .cleanup_cb = cleanup,
      .width = 640,
      .height = 480,
      .window_title = "Triangle (sokol-app)",
      .icon.sokol_default = true,
      .logger.func = slog_func,
  };
}
