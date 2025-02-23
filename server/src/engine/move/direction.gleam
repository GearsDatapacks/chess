import chess/board.{type Position}

pub type Direction {
  Direction(file_change: Int, rank_change: Int)
}

pub fn in_direction(
  position: Position,
  direction: Direction,
) -> Result(Position, Nil) {
  case
    position.file + direction.file_change,
    position.rank + direction.rank_change
  {
    file, rank if file < 0 || rank < 0 -> Error(Nil)
    file, rank if file >= board.size || rank >= board.size -> Error(Nil)
    file, rank -> Ok(board.Position(file:, rank:))
  }
}

pub fn multiply(direction: Direction, by: Int) -> Direction {
  Direction(
    file_change: direction.file_change * by,
    rank_change: direction.rank_change * by,
  )
}

pub const left = Direction(-1, 0)

pub const right = Direction(1, 0)

pub const up = Direction(0, 1)

pub const down = Direction(0, -1)

pub const up_left = Direction(-1, 1)

pub const down_left = Direction(-1, -1)

pub const up_right = Direction(1, 1)

pub const down_right = Direction(1, -1)

pub const rook_directions = [left, right, up, down]

pub const bishop_directions = [up_left, up_right, down_left, down_right]

pub const queen_directions = [
  left,
  right,
  up,
  down,
  up_left,
  up_right,
  down_left,
  down_right,
]

pub const knight_directions = [
  Direction(-1, -2),
  Direction(1, -2),
  Direction(-1, 2),
  Direction(1, 2),
  Direction(2, -1),
  Direction(2, 1),
  Direction(-2, -1),
  Direction(-2, 1),
]
