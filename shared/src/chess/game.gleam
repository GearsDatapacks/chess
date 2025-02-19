import chess/board
import chess/piece
import gleam/int
import gleam/option.{None, Some}
import gleam/string

pub type Game {
  Game(
    board: board.Board,
    to_move: piece.Colour,
    castling: Castling,
    en_passant: option.Option(board.Position),
    half_moves: Int,
    full_moves: Int,
  )
}

pub type Castling {
  Castling(
    white_kingside: Bool,
    white_queenside: Bool,
    black_kingside: Bool,
    black_queenside: Bool,
  )
}

fn castling_to_fen(castling: Castling) -> String {
  let fen = ""

  let fen = case castling.white_kingside {
    True -> fen <> "K"
    False -> fen
  }

  let fen = case castling.white_queenside {
    True -> fen <> "Q"
    False -> fen
  }

  let fen = case castling.black_kingside {
    True -> fen <> "k"
    False -> fen
  }

  let fen = case castling.black_queenside {
    True -> fen <> "q"
    False -> fen
  }

  case fen {
    "" -> "-"
    _ -> fen
  }
}

fn castling_from_fen(fen: String) -> Castling {
  let #(fen, white_kingside) = case fen {
    "K" <> fen -> #(fen, True)
    _ -> #(fen, False)
  }
  let #(fen, white_queenside) = case fen {
    "Q" <> fen -> #(fen, True)
    _ -> #(fen, False)
  }
  let #(fen, black_kingside) = case fen {
    "k" <> fen -> #(fen, True)
    _ -> #(fen, False)
  }
  let black_queenside = case fen {
    "q" <> _ -> True
    _ -> False
  }

  Castling(white_kingside:, white_queenside:, black_kingside:, black_queenside:)
}

pub fn to_fen(game: Game) -> String {
  let board_fen = board.to_fen(game.board)
  let to_move_fen = case game.to_move {
    piece.Black -> "b"
    piece.White -> "w"
  }
  let castling_fen = castling_to_fen(game.castling)
  let en_passant_fen =
    game.en_passant
    |> option.map(board.position_to_string)
    |> option.unwrap("-")
  let half_moves_fen = int.to_string(game.half_moves)
  let full_moves_fen = int.to_string(game.full_moves)

  board_fen
  <> " "
  <> to_move_fen
  <> " "
  <> castling_fen
  <> " "
  <> en_passant_fen
  <> " "
  <> half_moves_fen
  <> " "
  <> full_moves_fen
}

pub fn from_fen(fen: String) -> Game {
  let assert [board, to_move, castling, en_passant, half_moves, full_moves] =
    string.split(fen, " ")
  let board = board.from_fen(board)
  let to_move = case to_move {
    "w" -> piece.White
    "b" -> piece.Black
    _ -> piece.White
  }
  let castling = castling_from_fen(castling)
  let en_passant = case en_passant {
    "-" -> None
    _ -> Some(board.position_from_string(en_passant))
  }
  let assert Ok(half_moves) = int.parse(half_moves)
  let assert Ok(full_moves) = int.parse(full_moves)

  Game(board:, to_move:, castling:, en_passant:, half_moves:, full_moves:)
}
