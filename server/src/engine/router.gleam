import chess/board
import engine/web
import gleam/bytes_tree
import gleam/http.{Get, Post}
import gleam/string_tree
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home_page(req)

    ["new"] -> new_game(req)
    ["legal"] -> todo as "Implement /legal"
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
  use <- wisp.require_method(req, Post)
  let board = board.empty()
  wisp.ok()
  |> wisp.set_body(
    wisp.Bytes(bytes_tree.from_bit_array(board.to_binary(board))),
  )
  |> wisp.set_header("Access-Control-Allow-Origin", "*")
}
