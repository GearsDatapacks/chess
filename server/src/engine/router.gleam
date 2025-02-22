import chess/board
import chess/game
import engine/move
import engine/web
import gleam/http.{Get}
import gleam/io
import gleam/list
import gleam/string
import gleam/string_tree
import shared
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home_page(req)

    ["new"] -> new_game(req)
    ["move"] -> todo as "Implement /move"
    ["generate"] -> todo as "Implement /generate"

    _ -> wisp.not_found()
  }
}

fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)

  let html = string_tree.from_string("This is a chess engine!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn new_game(req: Request) -> Response {
  use <- wisp.require_method(req, Get)

  let game = game.from_fen(board.starting_fen)
  let moves = move.legal_moves(game)

  wisp.ok()
  |> wisp.string_body(shared.game_information_to_string(#(game, moves)))
  |> wisp.set_header("Access-Control-Allow-Origin", "*")
}
