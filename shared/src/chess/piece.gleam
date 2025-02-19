import gleam/result
import gleam/string

pub type Piece {
  Piece(colour: Colour, kind: PieceKind)
}

pub type Colour {
  White
  Black
}

pub type PieceKind {
  King
  Queen
  Bishop
  Knight
  Rook
  Pawn
}

pub fn to_binary(piece: Piece) -> BitArray {
  let colour_bit = case piece.colour {
    Black -> 0
    White -> 1
  }

  let kind_bits = case piece.kind {
    King -> 0b001
    Queen -> 0b010
    Bishop -> 0b011
    Knight -> 0b100
    Rook -> 0b101
    Pawn -> 0b110
  }

  <<colour_bit:size(1), kind_bits:size(3)>>
}

pub fn from_binary(bits: BitArray) -> Result(#(Piece, BitArray), Nil) {
  case bits {
    <<colour_bit:size(1), kind_bits:size(3), rest:bits>> -> {
      let colour = case colour_bit {
        0 -> Black
        1 -> White
        _ -> panic as "1 bit values cannot exceed this range"
      }

      use kind <- result.map(case kind_bits {
        0b001 -> Ok(King)
        0b010 -> Ok(Queen)
        0b011 -> Ok(Bishop)
        0b100 -> Ok(Knight)
        0b101 -> Ok(Rook)
        0b110 -> Ok(Pawn)
        _ -> Error(Nil)
      })

      #(Piece(colour, kind), rest)
    }
    _ -> Error(Nil)
  }
}

pub fn from_fen(fen: String) -> Result(Piece, Nil) {
  case fen {
    "K" -> Ok(Piece(White, King))
    "Q" -> Ok(Piece(White, Queen))
    "B" -> Ok(Piece(White, Bishop))
    "N" -> Ok(Piece(White, Knight))
    "R" -> Ok(Piece(White, Rook))
    "P" -> Ok(Piece(White, Pawn))
    "k" -> Ok(Piece(Black, King))
    "q" -> Ok(Piece(Black, Queen))
    "b" -> Ok(Piece(Black, Bishop))
    "n" -> Ok(Piece(Black, Knight))
    "r" -> Ok(Piece(Black, Rook))
    "p" -> Ok(Piece(Black, Pawn))
    _ -> Error(Nil)
  }
}

pub fn to_fen(piece: Piece) -> String {
  let kind = case piece.kind {
    Bishop -> "B"
    King -> "K"
    Knight -> "N"
    Pawn -> "P"
    Queen -> "Q"
    Rook -> "R"
  }

  case piece.colour {
    Black -> string.lowercase(kind)
    White -> kind
  }
}
