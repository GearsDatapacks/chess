import canvas
import gleam_community/colour

pub fn main(canvas_size: Int) {
  let assert Ok(canvas) = canvas.get_from_id("canvas")
  let assert Ok(context) = canvas.context(canvas)
  canvas.rect(context, colour.blue, 0, 0, canvas_size, canvas_size)
}
