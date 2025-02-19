import canvas
import chess/game.{type Game}
import gleam/fetch
import gleam/http
import gleam/http/request
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam_community/colour
import shared

pub fn main(canvas_size: Int) {
  let assert Ok(canvas) = canvas.get_from_id("canvas")
  let assert Ok(context) = canvas.context(canvas)
  canvas.rect(context, colour.blue, 0, 0, canvas_size, canvas_size)

  use game <- promise.try_await(get_game())
  let _ = game
  promise.resolve(Ok(Nil))
}

fn get_game() -> Promise(Result(Game, fetch.FetchError)) {
  let assert Ok(request) =
    request.to(
      "http://localhost:" <> int.to_string(shared.server_port) <> "/new",
    )
  let request = request |> request.set_method(http.Post)
  use response <- promise.try_await(fetch.send(request))
  use response <- promise.try_await(fetch.read_text_body(response))

  promise.resolve(Ok(game.from_fen(response.body)))
}
