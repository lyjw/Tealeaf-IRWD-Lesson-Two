class Board
  WINNING_COMBOS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

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

  def winning_lines
    winning_lines = []

    WINNING_COMBOS.each do |line|
      winning_line = @grid.select { |key| line.include? key }
      squares = winning_line.keys
      values = winning_line.map { |_, v| v.value }
      winning_line_hash = Hash[squares.zip(values)]

      winning_lines << winning_line_hash
    end

    winning_lines
  end

  def three_in_a_row?(marker)
    winning_lines.each do |line|
      return true if line.values.count(marker) == 3
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
  attr_accessor :name
  attr_reader :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
  end

  def move_to_win(board, marker)
    board.winning_lines.each do |line|
      return best_move(line) if line.values.count(marker) == 2
    end
    false
  end

  def defend(board, marker)
    board.winning_lines.each do |line|
      values = line.values

      if !values.include?(marker) && values.count(' ') == 1
        return best_move(line)
      end
    end
    false
  end

  def best_move(line)
    line.select { |_, value| value == ' ' }.keys.first
  end
end

class Human < Player

  def get_player_name
    puts "\nWhat is your name?"
    @name = gets.chomp
  end

  def pick_square(board)
    puts "Please choose a square (1 - 9)"

    begin
      position = gets.chomp.to_i
      puts "Please choose an empty square:"
    end until board.empty_positions.include?(position)

    board.mark_square(position, marker)
  end
end

class Computer < Player
  def pick_square(board)
    puts "Computer is choosing a square..."
    sleep 0.5

    if move_to_win(board, marker)
      position = move_to_win(board, marker)
    elsif defend(board, marker)
      position = defend(board, marker)
    else
      position = board.empty_positions.sample
    end

    board.mark_square(position, marker)
  end
end

class Game
  attr_accessor :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new('', 'X')
    @computer = Computer.new('Computer', 'O')
  end

  def reset
    @board = Board.new
  end

  def welcome_message
    system 'clear'
    puts "Welcome to Tic-Tac-Toe!"
    human.get_player_name
  end

  def winner_or_tie?
    board.three_in_a_row?(human.marker) || board.three_in_a_row?(computer.marker) || 
      board.all_squares_filled?
  end

  def display_winner
    if board.three_in_a_row?(human.marker)
      puts "#{human.name} won!"
    elsif board.three_in_a_row?(computer.marker)
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def replay?
    puts "\nAnother round? (Enter 'Y' for another round or any key to exit)"
    answer = gets.chomp.downcase

    answer == 'y' ? true : false
  end

  def run
    welcome_message

    loop do
      board.draw

      loop do 
        human.pick_square(board)
        board.draw
        break if winner_or_tie?
        computer.pick_square(board)
        board.draw
        break if winner_or_tie?
      end

      display_winner
      replay? ? reset : break
    end
  end
end

Game.new.run