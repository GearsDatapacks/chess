import chess/piece.{type Piece}
import gleam/dict.{type Dict}
import gleam/int
import gleam/result
import gleam/string

pub const size = 8

pub type Board {
  Board(squares: Dict(Position, Square))
}

pub type Square {
  Empty
  Occupied(Piece)
}

pub type Position {
  Position(file: Int, rank: Int)
}

pub fn position_to_string(position: Position) -> String {
  let file = case position.file {
    0 -> "a"
    1 -> "b"
    2 -> "c"
    3 -> "d"
    4 -> "e"
    5 -> "f"
    6 -> "g"
    7 -> "h"
    _ -> "a"
  }

  file <> int.to_string(position.rank + 1)
}

pub fn position_from_string(string: String) -> Position {
  let assert Ok(#(file, rank)) = string.pop_grapheme(string)
  let file = case file {
    "a" -> 0
    "b" -> 1
    "c" -> 2
    "d" -> 3
    "e" -> 4
    "f" -> 5
    "g" -> 6
    "h" -> 7
    _ -> 0
  }
  let assert Ok(rank) = int.parse(rank)
  Position(file:, rank: rank - 1)
}

pub type Move {
  Move(from: Position, to: Position)
}

pub fn move_to_string(move: Move) -> String {
  position_to_string(move.from) <> position_to_string(move.to)
}

pub fn move_from_string(string: String) -> Move {
  let from = string |> string.drop_end(2) |> position_from_string
  let to = string |> string.drop_start(2) |> position_from_string
  Move(from:, to:)
}

fn square_from_binary(bits: BitArray) -> Result(#(Square, BitArray), Nil) {
  case bits {
    <<piece:size(4), rest:bits>> if piece == 0 -> Ok(#(Empty, rest))
    _ ->
      piece.from_binary(bits)
      |> result.map(fn(pair) {
        let #(piece, bits) = pair
        #(Occupied(piece), bits)
      })
  }
}

pub fn empty() -> Board {
  let squares = populate_squares(dict.new(), 0, 0)
  Board(squares:)
}

fn populate_squares(
  squares: Dict(Position, Square),
  file: Int,
  rank: Int,
) -> Dict(Position, Square) {
  let squares = dict.insert(squares, Position(file:, rank:), Empty)
  case file + 1 >= size, rank + 1 >= size {
    True, False -> populate_squares(squares, 0, rank + 1)
    True, True -> squares
    False, _ -> populate_squares(squares, file + 1, rank)
  }
}

pub fn to_binary(board: Board) -> BitArray {
  to_binary_loop(board, 0, 0, <<>>)
}

fn to_binary_loop(
  board: Board,
  file: Int,
  rank: Int,
  bits: BitArray,
) -> BitArray {
  case dict.get(board.squares, Position(file:, rank:)) {
    Error(_) -> bits
    Ok(square) -> {
      let square_bits = case square {
        Empty -> <<0:size(4)>>
        Occupied(piece) -> piece.to_binary(piece)
      }
      let #(x, y) = case file + 1 >= size {
        False -> #(file + 1, rank)
        True -> #(0, rank + 1)
      }
      to_binary_loop(board, x, y, <<bits:bits, square_bits:bits>>)
    }
  }
}

pub fn from_binary(bits: BitArray) -> Board {
  from_binary_loop(bits, 0, 0, Board(dict.new()))
}

fn from_binary_loop(bits: BitArray, file: Int, rank: Int, board: Board) -> Board {
  case square_from_binary(bits) {
    Error(_) -> board
    Ok(#(square, bits)) -> {
      let board =
        Board(dict.insert(board.squares, Position(file:, rank:), square))
      let #(x, y) = case file + 1 >= size {
        False -> #(file + 1, rank)
        True -> #(0, rank + 1)
      }
      from_binary_loop(bits, x, y, board)
    }
  }
}

pub const starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

pub fn from_fen(fen: String) -> Board {
  from_fen_loop(fen, 0, size - 1, empty())
}

fn from_fen_loop(fen: String, file: Int, rank: Int, board: Board) -> Board {
  case string.pop_grapheme(fen) {
    Error(_) -> board
    Ok(#("/", fen)) -> from_fen_loop(fen, 0, rank - 1, board)
    Ok(#(char, fen)) ->
      case int.parse(char) {
        Ok(empty_spaces) -> from_fen_loop(fen, file + empty_spaces, rank, board)
        Error(_) ->
          case piece.from_fen(char) {
            Error(_) -> board
            Ok(piece) -> {
              let board =
                Board(dict.insert(
                  board.squares,
                  Position(file:, rank:),
                  Occupied(piece),
                ))
              from_fen_loop(fen, file + 1, rank, board)
            }
          }
      }
  }
}

pub fn to_fen(board: Board) -> String {
  to_fen_loop(board, 0, size - 1, 0, "")
}

fn to_fen_loop(
  board: Board,
  file: Int,
  rank: Int,
  empty: Int,
  fen: String,
) -> String {
  let fen = case file == 0 {
    True ->
      case rank == size - 1 || rank < 0 {
        False -> fen <> "/"
        True -> fen
      }
    False -> fen
  }

  let #(next_file, next_rank) = case file + 1 >= size {
    False -> #(file + 1, rank)
    True -> #(0, rank - 1)
  }

  case dict.get(board.squares, Position(file:, rank:)) {
    Error(_) -> fen
    Ok(Empty) ->
      case next_file == 0 {
        False -> to_fen_loop(board, next_file, next_rank, empty + 1, fen)
        True ->
          to_fen_loop(
            board,
            next_file,
            next_rank,
            0,
            fen <> int.to_string(empty + 1),
          )
      }
    Ok(Occupied(piece)) -> {
      let fen = case empty {
        0 -> fen
        _ -> fen <> int.to_string(empty)
      }
      to_fen_loop(board, next_file, next_rank, 0, fen <> piece.to_fen(piece))
    }
  }
}
