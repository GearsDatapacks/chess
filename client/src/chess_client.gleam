import canvas
import chess/board
import chess/piece
import gleam/dict
import gleam/fetch
import gleam/http
import gleam/http/request
import gleam/int
import gleam/io
import gleam/javascript/promise.{type Promise}
import gleam_community/colour
import shared

pub fn main(canvas_size: Int) {
  let assert Ok(canvas) = canvas.get_from_id("canvas")
  let assert Ok(context) = canvas.context(canvas)

  use #(game, moves) <- promise.try_await(get_game())
  io.debug(#(game, moves))
  draw_board(game.board, context, canvas_size / board.size)

  promise.resolve(Ok(Nil))
}

fn get_game() -> Promise(Result(shared.GameInformation, fetch.FetchError)) {
  let assert Ok(request) =
    request.to(
      "http://localhost:" <> int.to_string(shared.server_port) <> "/new",
    )
  let request = request |> request.set_method(http.Get)
  use response <- promise.try_await(fetch.send(request))
  use response <- promise.try_await(fetch.read_text_body(response))
  io.debug(response.body)

  promise.resolve(Ok(shared.game_information_from_string(response.body)))
}

fn draw_board(board: board.Board, context: canvas.Context, square_size: Int) {
  use _, position, square <- dict.fold(board.squares, Nil)
  let colour = case { position.file + position.rank } % 2 == 0 {
    False -> colour.dark_blue
    True -> colour.white
  }
  canvas.rect(
    context,
    colour,
    square_size * position.file,
    square_size * position.rank,
    square_size,
    square_size,
  )

  case square {
    board.Empty -> Nil
    board.Occupied(piece) -> {
      let colour_text = case piece.colour {
        piece.Black -> "black"
        piece.White -> "white"
      }
      let kind_text = case piece.kind {
        piece.Bishop -> "bishop"
        piece.King -> "king"
        piece.Knight -> "knight"
        piece.Pawn -> "pawn"
        piece.Queen -> "queen"
        piece.Rook -> "rook"
      }
      let image_path = "/assets/" <> colour_text <> "-" <> kind_text <> ".svg"
      canvas.image(
        context,
        image_path,
        square_size * position.file,
        square_size * position.rank,
        square_size,
        square_size,
      )
      Nil
    }
  }

  Nil
}
