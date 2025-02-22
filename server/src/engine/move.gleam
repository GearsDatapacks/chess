import chess/board.{type Move, type Position}
import chess/game.{type Game}
import chess/piece
import engine/move/direction.{type Direction}
import gleam/dict
import gleam/list
import gleam/result

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
    // TODO: King moves
    piece.King -> []
    // TODO: Pawn moves
    piece.Pawn -> get_pawn_moves(game, position)
    // TODO: Knight moves
    piece.Knight -> []
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

fn get_pawn_moves(game: Game, position: Position) -> List(Move) {
  // TODO: double moves, taking moves
  let direction = case game.to_move {
    piece.Black -> direction.down
    piece.White -> direction.up
  }
  maybe_move(game, position, direction)
  |> result.map(list.wrap)
  |> result.unwrap([])
}

// TODO: Implement
pub fn apply_move(game: Game, _move: Move) -> Game {
  game
}
