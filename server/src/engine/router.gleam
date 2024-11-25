import carpenter/table
import engine/web
import gleam/http.{Get, Post}
import gleam/string_tree
import wisp.{type Request, type Response}

pub type Board {
  Board
}

pub fn handle_request(req: Request, table: table.Set(String, Board)) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home_page(req)

    ["new"] -> new_game(req, table)
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

fn new_game(req: Request, table: table.Set(String, Board)) -> Response {
  use <- wisp.require_method(req, Post)
  table.insert(table, [#("board", Board)])
  wisp.ok()
}
