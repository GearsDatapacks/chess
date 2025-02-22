import chess/board
import chess/game
import gleam/list
import gleam/string

pub const server_port = 4322

pub type GameInformation =
  #(game.Game, List(board.Move))

pub fn game_information_to_string(information: GameInformation) -> String {
  let #(game, moves) = information
  game.to_fen(game)
  <> ","
  <> moves |> list.map(board.move_to_string) |> string.join(",")
}

pub fn game_information_from_string(string: String) -> GameInformation {
  case string.split(string, ",") {
    [game] | [game, ""] -> #(game.from_fen(game), [])
    [game, ..moves] -> #(
      game.from_fen(game),
      list.map(moves, board.move_from_string),
    )
    [] -> panic as "string.split always returns at least 1 element"
  }
}
