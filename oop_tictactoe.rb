require 'pry'

class Board

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

  def initialize
    @grid = {}
    (1..9).each { |position| @grid[position] = Square.new(' ') }
    @reference_board = {}
    (1..9).each { |position| @reference_board[position] = "#{position}" }
  end

  def draw
    system 'clear'
    puts "Let's play Tic-Tac-Toe:"
    puts
    puts "                Open Squares\n\n"
    puts " #{@grid[1]} | #{@grid[2]} | #{@grid[3]}       #{@reference_board[1]} | #{@reference_board[2]} | #{@reference_board[3]}  "
    puts "-----------     -----------"
    puts " #{@grid[4]} | #{@grid[5]} | #{@grid[6]}       #{@reference_board[4]} | #{@reference_board[5]} | #{@reference_board[6]}  "
    puts "-----------     -----------"
    puts " #{@grid[7]} | #{@grid[8]} | #{@grid[9]}       #{@reference_board[7]} | #{@reference_board[8]} | #{@reference_board[9]}  "
    puts
  end

  def all_squares_filled?
    empty_positions.size == 0
  end

  def empty_positions
    @grid.select { |_, square| square.empty? }.keys
  end

  def mark_square(position, marker)
    @grid[position].mark(marker)
    @reference_board[position] = ' '
  end

  def three_in_a_row?(marker)
    WINNING_LINES.each do |line|
      return true if (@grid[line[0]].value == marker) && (@grid[line[1]].value == marker) && (@grid[line[2]].value == marker)
    end
    false
  end
end

class Square
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def empty?
    @value == ' '
  end

  def mark(marker)
    @value = marker
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :name, :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
  end
end

class Human < Player
  def pick_square(board)
    puts "Please choose a square (1 - 9)"

    begin
      position = gets.chomp.to_i
      puts "Please choose an empty square:"
    end until board.empty_positions.include?(position)

    board.mark_square(position, marker)
  end
end

class Game
  def initialize
    @board = Board.new
    @human = Human.new('', 'X')
    @computer = Player.new('Computer', 'O')
    @current_player = @human
    @winner = nil
  end

  def welcome_message
    system 'clear'

    puts "Welcome to Tic-Tac-Toe!"
    get_player_name
  end

  def get_player_name
    puts "\nWhat is your name?"
    @human.name = gets.chomp
  end

  def current_player_marks_square
    if @current_player == @human
      @human.pick_square(@board)
    end
    @board.mark_square(position, @current_player.marker)
  end

  def alternate_player
    if @current_player == @human
      @current_player = @computer
    else
      @current_player = @human
    end
  end

  def check_for_winner
    if @board.three_in_a_row?(@human.marker)
      @winner = @human.name
    elsif @board.three_in_a_row?(@computer.marker)
      @winner = @computer.name
    else
      false
    end
  end

  def display_winner
    if @board.three_in_a_row?(@human.marker)
      puts "#{@human.name} won!"
    elsif @board.three_in_a_row?(@computer.marker)
      puts "Computer won!"
    else
      puts "It's a tie."
    end
  end

  def run
    welcome_message
    @board.draw

    begin
      current_player_marks_square
      @board.draw
      break if check_for_winner
      alternate_player
    end until @board.all_squares_filled?

    display_winner
  end
end

Game.new.run