class Piece

  attr_reader :color

  def initialize(pos, board, king = false, start_pos = nil)
    @board = board
    @king = king
    @pos = pos
    @start_pos = start_pos || @pos
    @color = set_color(@start_pos)
    @board[@pos] = self
  end

  def perform_moves!(move_seq)
    if move_seq.count == 1
      perform_slide(move_seq.first) || perform_jump(move_seq.first)
    else
      move_seq.each do |move|
        return unless perform_jump(move)
      end
    end
  end

  def perform_slide(move)
    return false if !diagonal_moves.include?(move) || @board[move]
    exec_move(move)
  end

  def valid_move_seq?(move_seq)
    dummy_board = @board.dup
    dummy_self = dummy_board[@pos]
    dummy_self.perform_moves!(move_seq)
  end

  def perform_moves(move_seq)
    if valid_move_seq?(move_seq)
      perform_moves!(move_seq)
    else
      raise 'Invalid Move'
    end
  end

  def perform_jump(move)
    delta_used = delta_math(move, @pos.map {|coord| coord*(-1)})
    jumped_space = delta_math(@pos, delta_used.map {|coord| (coord*0.5).to_i})
    return false unless  diagonal_moves(2).include?(move) && @board[move].nil? &&
                            @board[jumped_space].is_enemy?(self)

    @board[jumped_space] = nil
    exec_move(move)
  end

  def exec_move(move)
    @board[move] = self
    @board[@pos] = nil
    @pos = move
    maybe_promote
    true
  end

  def is_enemy?(piece)
    return false if self.nil? || self.color == piece.color
    true
  end

  def y_directions
    return [1,-1] if @king
    @color == :white ?  [-1] : [1]
  end

  def dup(duped_board)
    dummy_piece = Piece.new(@pos, duped_board, @king, @start_pos)
  end

  def set_color(start)
    start[0] >= @board.grid.count / 2 ? :white : :black
  end

  def maybe_promote
    @king = true if (@color == :white && @pos.first == 0) ||
                    (@color == :black && @pos.first == @board.grid.count-1)
  end

  def diagonal_moves(length = 1)
    deltas = []

    y_directions.each do |y_dir|
      [1,-1].each do |x_dir|
        deltas << [y_dir * length, x_dir * length]
      end
    end

    new_locations = deltas.map {|dy, dx| [@pos.first + dy, @pos.last + dx]}
  end

  def delta_math(pos, delt)
    [pos.first + delt.first, pos.last + delt.last]
  end

end

class Board

  attr_reader :grid, :size

  def initialize(size = 8, self_pop = true)
    @size = size
    @grid = Array.new(size) {Array.new(size)}
    initialize_sides if self_pop
  end

  def [](pos)
    grid[pos.first][pos.last]
  end

  def []=(pos, piece)
    raise "Invalid Space" if pos.any? {|coord| !coord.between?(0, @grid.count-1)}
    grid[pos.first][pos.last] = piece
  end

  def clear(pos)
    self[pos]= nil
  end

  def dup
    duped_board = Board.new(@size, false)
    @grid.each do |row|
      row.each do |piece|
        piece.dup(duped_board) if piece
      end
    end

    duped_board
  end

  def all_pieces(color)
    @grid.flatten.compact.select {|piece| piece.color == color}
  end

  def has_moves?(color)
    all_pieces(color).any? do |piece|
      piece.diagonal_moves.each do |move|
        return true if piece.valid_move_seq?([move])
      end
    end
  end


  def initialize_sides
    (0..2).each {|row| initialize_row(row)}
    (@grid.count-3...@grid.count).each {|row| initialize_row(row)}
  end

  def render
    @grid.each do |row|
      row.each do |pos|
        if pos.nil?
          print " "
        else
          print pos.color == :white ? '○' : '●'
        end
      end
      puts
    end
    nil
  end

  def initialize_row(row)
    offset = row % 2 == 0 ? 0 : 1

    (0...@grid.count).each do |col|
      next if col - offset != 0
      Piece.new([row, col], self)
      offset += 2
    end
  end

end
