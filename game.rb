require 'colorize'
require_relative 'checkers.rb'
require_relative 'players.rb'

class Game

  def initialize(first_player = nil, second_player = nil, size = 8)
    @players = first_player || HumanPlayer.new, second_player || HumanPlayer.new
    @game_board = Board.new(size)
    @players.first.set_color(:white)
    @players.last.set_color(:black)
    nil
  end

  def run
    play
    end_game
  end

  def play
    until over?
      begin
        turn = @players.first.get_moves(@game_board)
        @game_board[turn.first].perform_moves(turn.last)
      rescue StandardError => error
        p error.message
        retry
      end

      @players.reverse!
    end
  end

  def over?
    draw? || won?
  end

  def won?
    @game_board.all_pieces(@players.first.color).count == 0 ||
    !@game_board.has_moves?(@players.first.color)
  end

  def draw?
    !@game_board.has_moves?(@players.first.color) &&
    !@game_board.has_moves?(@players.last.color)
  end

  def end_game
    if won?
      p "Congratulations #{@players.last.color.to_s.capitalize}! You won!"
    else
      p "You both suck!"
    end
  end
end
