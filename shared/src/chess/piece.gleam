import gleam/result

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
