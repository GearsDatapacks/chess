import canvas
import gleam/int
import gleam/io
import gleam/result
import gleam_community/colour
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event

const canvas_width = 1000

const canvas_height = canvas_width

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Context {
  ValidContext(canvas.Context)
  Uninitialised
  ContextError(String)
}

type Model {
  Model(context: Context)
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model(Uninitialised), effect.none())
}

fn view(_model: Model) -> element.Element(Msg) {
  html.canvas([
    attribute.id("canvas"),
    attribute.width(canvas_width),
    attribute.height(canvas_height),
    event.on_click(DrawRectangle),
  ])
}

// Update
//
//

type Msg {
  DoNothing
  FetchContext
  ContextFetched(Context)
  DrawRectangle
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    DoNothing -> #(model, effect.none())
    ContextFetched(context) -> #(Model(context), effect.none())
    FetchContext -> #(model, fetch_context())
    DrawRectangle -> #(model, draw_rectangle(model.context))
  }
}

fn fetch_context() -> Effect(Msg) {
  use dispatch <- effect.from()

  let get_error = fn(error) {
    case error {
      canvas.ElementNotCanvas -> "Element was not a canvas element"
      canvas.ElementNotFound -> "Element was not found"
    }
  }
  let context_error = fn(error) {
    case error {
      canvas.FailedToGetContext -> "Failed to get canvas context"
    }
  }

  let context = {
    use canvas <- result.try(
      canvas.get_from_id("canvas") |> result.map_error(get_error),
    )
    canvas.context(canvas) |> result.map_error(context_error)
  }

  case context {
    Ok(context) -> ValidContext(context)
    Error(message) -> ContextError(message)
  }
  |> ContextFetched
  |> dispatch
}

fn draw_rectangle(context: Context) -> Effect(Msg) {
  use dispatch <- effect.from()

  let assert Ok(colour) = colour.from_rgb_hex(int.random(0xffffff))

  case context {
    ContextError(error) -> {
      io.println_error("Error ocurred: " <> error)
      dispatch(DoNothing)
    }
    Uninitialised -> {
      dispatch(FetchContext)
      dispatch(DrawRectangle)
    }
    ValidContext(context) -> {
      canvas.rect(context, colour, 0, 0, canvas_width, canvas_height)
      dispatch(DoNothing)
    }
  }
}
