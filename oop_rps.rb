module Formattable
  def display_formatted_line(line)
    puts "=> #{line}"
  end
end

class Hand
  include Comparable

  attr_reader :choice

  CHOICES = {"r" => "Rock", "p" => "Paper", "s" => "Scissors"}

  def initialize(choice)
    @choice = choice
  end

  def has_winning_hand?(other_hand)

  end

  def <=>(other_hand)
    if @choice == other_hand.choice
      0
    elsif (@choice == 'r' && other_hand.choice == 's') || 
            (@choice == 'p' && other_hand.choice == 'r') || 
            (@choice == 's' && other_hand.choice == 'p')
      1
    else
      -1
    end
  end

  def display_winning_result
    case @choice
    when 'r'
      puts "Rock smashes Scissors!"
    when 'p'
      puts "Paper smothers Rock!"
    when 's'
      puts "Scissors shreds Paper!"
    end
  end
end

class Player
  attr_accessor :name, :hand, :wins

  def initialize(name = "Computer")
    @name = name
    @wins = 0
  end

  def to_s
    "#{name} chose #{Hand::CHOICES[self.hand.choice]}"
  end

  def pick_hand
    self.hand = Hand.new(Hand::CHOICES.keys.sample)
  end
end

class Human < Player
  include Formattable

  def pick_hand
    begin
      display_formatted_line "Pick one: (R / P / S)"
      choice = gets.chomp.downcase
    end until Hand::CHOICES.keys.include?(choice)

    self.hand = Hand.new(choice)
  end
end

class Game
  include Formattable

  attr_accessor :player, :computer, :tie

  def initialize
    @player = Human.new("Player")
    @computer = Player.new
    @rounds = 0
    @tie = 0
  end

  def welcome_message
    system 'clear'

    display_formatted_line "Welcome to Rock, Paper, Scissors!\n\n"
    puts 'What is your name?'
    player.name = gets.chomp
  end

  def compare_hands
    if player.hand == computer.hand
      @tie += 1
      display_formatted_line "It's a tie!"
    elsif player.hand > computer.hand
      player.wins += 1
      player.hand.display_winning_result
      display_formatted_line "#{player.name} won!"
    else
      computer.hand.display_winning_result
      computer.wins += 1
      display_formatted_line "#{computer.name} won!"
    end
  end

  def replay?
    puts"\nPlay again? (Enter 'Y' for another round or any key to exit)"
    gets.chomp.downcase
  end

  def display_score
    scoreboard = <<-EOL

    Score (out of #{@rounds} rounds) -
    #{player.name}: #{player.wins} wins
    Computer: #{computer.wins} wins
    Tie: #{@tie}

    EOL

    puts scoreboard
  end

  def play_round
    system 'clear'

    @rounds += 1
    player.pick_hand
    puts player
    computer.pick_hand
    puts computer
    compare_hands
  end

  def run
    welcome_message

    begin 
      play_round
    end until replay? != 'y'

    display_score
  end
end 

Game.new.run