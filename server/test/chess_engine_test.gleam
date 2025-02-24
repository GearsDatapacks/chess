import chess/board
import chess/game
import engine/move
import gleam/int
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn perft_all(fen: String, expected: List(Int)) {
  expected
  |> list.index_map(fn(expected, index) { perft(fen, index + 1, expected) })
  Nil
}

fn perft(fen: String, depth: Int, expected_moves: Int) {
  do_perft(game.from_fen(fen), depth - 1) |> should.equal(expected_moves)
}

fn do_perft(game: game.Game, depth: Int) -> Int {
  let legal_moves = move.legal_moves(game)
  case depth {
    0 -> list.length(legal_moves)
    _ ->
      list.map(legal_moves, fn(move) {
        game |> move.apply_move(move) |> do_perft(depth - 1)
      })
      |> int.sum
  }
}

pub fn perft_initial_position_test() {
  perft_all("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", [
    20, 400, 8902, 197_281, 4_865_609, 119_060_324,
  ])
}

pub fn apply_move_test() {
  board.starting_fen
  |> game.from_fen
  |> move.apply_move(board.move_from_string("a2a4"))
  |> game.to_fen
  |> should.equal("rnbqkbnr/pppppppp/8/8/P7/8/1PPPPPPP/RNBQKBNR b KQkq a3 0 1")

  board.starting_fen
  |> game.from_fen
  |> move.apply_move(board.move_from_string("g1f3"))
  |> game.to_fen
  |> should.equal("rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1")

  board.starting_fen
  |> game.from_fen
  |> move.apply_move(board.move_from_string("a2a4"))
  |> move.apply_move(board.move_from_string("b8c6"))
  |> game.to_fen
  |> should.equal("r1bqkbnr/pppppppp/2n5/8/P7/8/1PPPPPPP/RNBQKBNR w KQkq - 1 2")

  board.starting_fen
  |> game.from_fen
  |> move.apply_move(board.move_from_string("a2a4"))
  |> move.apply_move(board.move_from_string("b7b5"))
  |> game.to_fen
  |> should.equal(
    "rnbqkbnr/p1pppppp/8/1p6/P7/8/1PPPPPPP/RNBQKBNR w KQkq b6 0 2",
  )
}
