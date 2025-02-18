import chess/piece.{type Piece}
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/result

pub const size = 8

pub type Board {
  Board(squares: Dict(#(Int, Int), Square))
}

pub type Square {
  Empty
  Occupied(Piece)
}

fn square_from_binary(bits: BitArray) -> Result(#(Square, BitArray), Nil) {
  case bits {
    <<0b0000:size(4), rest:bits>> -> Ok(#(Empty, rest))
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
  squares: Dict(#(Int, Int), Square),
  x: Int,
  y: Int,
) -> Dict(#(Int, Int), Square) {
  let squares = dict.insert(squares, #(x, y), Empty)
  case x + 1 >= size, y + 1 >= size {
    True, False -> populate_squares(squares, 0, y + 1)
    True, True -> squares
    False, _ -> populate_squares(squares, x + 1, y)
  }
}

pub fn to_binary(board: Board) -> BitArray {
  to_binary_loop(board, 0, 0, <<>>)
}

fn to_binary_loop(board: Board, x: Int, y: Int, bits: BitArray) -> BitArray {
  case dict.get(board.squares, #(x, y)) {
    Error(_) -> bits
    Ok(square) -> {
      let square_bits = case square {
        Empty -> <<0:size(4)>>
        Occupied(piece) -> piece.to_binary(piece)
      }
      let #(x, y) = case x + 1 >= size {
        False -> #(x + 1, y)
        True -> #(0, y + 1)
      }
      to_binary_loop(board, x, y, bit_array.append(bits, square_bits))
    }
  }
}

pub fn from_binary(bits: BitArray) -> Board {
  from_binary_loop(bits, 0, 0, Board(dict.new()))
}

fn from_binary_loop(bits: BitArray, x: Int, y: Int, board: Board) -> Board {
  case square_from_binary(bits) {
    Error(_) -> board
    Ok(#(square, bits)) -> {
      let board = Board(dict.insert(board.squares, #(x, y), square))
      let #(x, y) = case x + 1 >= size {
        False -> #(x + 1, y)
        True -> #(0, y + 1)
      }
      from_binary_loop(bits, x, y, board)
    }
  }
}
