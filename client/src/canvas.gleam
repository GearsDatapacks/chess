import gleam_community/colour

pub type Canvas

pub type Context

pub type CanvasGetError {
  ElementNotFound
  ElementNotCanvas
}

pub type GetContextError {
  FailedToGetContext
}

@external(javascript, "./canvas_ffi.mjs", "getFromId")
pub fn get_from_id(id: String) -> Result(Canvas, CanvasGetError)

@external(javascript, "./canvas_ffi.mjs", "getContext")
pub fn context(canvas: Canvas) -> Result(Context, GetContextError)

pub fn rect(
  context: Context,
  colour: colour.Colour,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
) -> Nil {
  colour
  |> colour.to_css_rgba_string
  |> do_rect(context, _, x, y, width, height)
}

@external(javascript, "./canvas_ffi.mjs", "fillRect")
fn do_rect(
  context: Context,
  colour: String,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
) -> Nil

@external(javascript, "./canvas_ffi.mjs", "getWindowDimensions")
pub fn window_dimensions() -> #(Int, Int)
