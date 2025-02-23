import chess/board.{type Move, type Position, Board}
import chess/game.{type Game, Game}
import chess/piece
import engine/move/direction.{type Direction}
import gleam/dict
import gleam/list
import gleam/result

// TODO: en passant, castling, check
pub fn legal_moves(game: Game) -> List(Move) {
  use moves, position, square <- dict.fold(game.board.squares, [])
  case square {
    board.Occupied(piece) if piece.colour == game.to_move ->
      list.append(get_moves_for_piece(game, piece, position), moves)
    _ -> moves
  }
}

fn get_moves_for_piece(
  game: Game,
  piece: piece.Piece,
  position: Position,
) -> List(Move) {
  case piece.kind {
    piece.Bishop ->
      get_sliding_moves(game, position, direction.bishop_directions)
    piece.Queen -> get_sliding_moves(game, position, direction.queen_directions)
    piece.Rook -> get_sliding_moves(game, position, direction.rook_directions)
    piece.King -> get_king_moves(game, position)
    piece.Pawn -> get_pawn_moves(game, position)
    piece.Knight -> get_knight_moves(game, position)
  }
}

type MoveValidity {
  Valid
  Invalid
  ValidThenStop
}

fn move_validity(square: board.Square, colour: piece.Colour) -> MoveValidity {
  case square {
    board.Empty -> Valid
    board.Occupied(piece) if piece.colour == colour -> Invalid
    board.Occupied(_) -> ValidThenStop
  }
}

fn maybe_move(
  game: Game,
  from: Position,
  direction: Direction,
) -> Result(board.Move, Nil) {
  case direction.in_direction(from, direction) {
    Error(_) -> Error(Nil)
    Ok(to) ->
      case dict.get(game.board.squares, to) {
        Error(_) -> Error(Nil)
        Ok(square) ->
          case move_validity(square, game.to_move) {
            Invalid -> Error(Nil)
            Valid | ValidThenStop -> Ok(board.Move(from:, to:))
          }
      }
  }
}

fn get_sliding_moves(
  game: Game,
  position: Position,
  directions: List(Direction),
) -> List(Move) {
  list.flat_map(directions, get_sliding_moves_loop(game, position, _, []))
}

fn get_sliding_moves_loop(
  game: Game,
  position: Position,
  direction: Direction,
  moves: List(Move),
) -> List(Move) {
  case direction.in_direction(position, direction) {
    Error(_) -> moves
    Ok(new_position) ->
      case
        dict.get(game.board.squares, new_position)
        |> result.map(move_validity(_, game.to_move))
      {
        Error(_) | Ok(Invalid) -> moves
        Ok(ValidThenStop) -> [
          board.Move(from: position, to: new_position),
          ..moves
        ]
        Ok(Valid) ->
          get_sliding_moves_loop(game, new_position, direction, [
            board.Move(from: position, to: new_position),
            ..moves
          ])
      }
  }
}

fn get_king_moves(game: Game, position: Position) -> List(Move) {
  direction.queen_directions |> list.filter_map(maybe_move(game, position, _))
}

fn get_knight_moves(game: Game, position: Position) -> List(Move) {
  direction.knight_directions |> list.filter_map(maybe_move(game, position, _))
}

fn get_pawn_moves(game: Game, position: Position) -> List(Move) {
  let #(direction, take_directions) = case game.to_move {
    piece.Black -> #(direction.down, [direction.down_left, direction.down_right])
    piece.White -> #(direction.up, [direction.up_left, direction.up_right])
  }
  let directions = case game.to_move, position.rank {
    piece.Black, 6 | piece.White, 1 -> [
      direction,
      direction.multiply(direction, 2),
    ]
    _, _ -> [direction]
  }
  directions
  |> list.filter_map(maybe_move(game, position, _))
  |> list.append(
    take_directions
    |> list.filter_map(fn(direction) {
      case direction.in_direction(position, direction) {
        Error(_) -> Error(Nil)
        Ok(to) ->
          case dict.get(game.board.squares, to) {
            Error(_) -> Error(Nil)
            Ok(square) ->
              case move_validity(square, game.to_move) {
                Invalid | Valid -> Error(Nil)
                ValidThenStop -> Ok(board.Move(from: position, to:))
              }
          }
      }
    }),
  )
}

pub fn apply_move(game: Game, move: Move) -> Game {
  let squares = case dict.get(game.board.squares, move.from) {
    Error(_) -> game.board.squares
    Ok(square) ->
      game.board.squares
      |> dict.insert(move.to, square)
      |> dict.insert(move.from, board.Empty)
  }
  let #(to_move, move_increment) = case game.to_move {
    piece.Black -> #(piece.White, 1)
    piece.White -> #(piece.Black, 0)
  }
  // TODO: only increment half moves if a reversible move was taken
  Game(
    ..game,
    to_move:,
    board: Board(squares:),
    half_moves: game.half_moves + 1,
    full_moves: game.full_moves + move_increment,
  )
}
