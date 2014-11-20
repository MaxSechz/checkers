class HumanPlayer

  attr_reader :color

  def set_color(color)
    @color = color
  end

  def get_moves(board)
    board.render
    puts "Enter the piece you wish to move"
    piece = gets.chomp.split(',').map {|coord| coord.to_i}
    raise 'Invalid Piece' if !board[piece] || board[piece].color != @color
    puts "Enter the space(s) you wish to move it to"

    move_seq = gets.chomp.split.map do |coords|
       coords.split(',').map {|coord| coord.to_i}
    end

    [piece, move_seq]
  end
end
