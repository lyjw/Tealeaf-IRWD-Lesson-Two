module Formattable
  def print_divider
    puts "-------------------------------------------------"
  end

  def format(msg)
    puts "\n#{msg}\n\n"
  end

  def start_turn
    format "[ #{name}'s Turn ]"
    display_hand
    display_sum_of_cards
  end
end

module Hand
  def reset
    self.hand = []
  end

  def add_card(new_card)
    hand << new_card
  end

  def upcard
    hand.first
  end

  def display_upcard
    puts "#{name}'s upcard is: #{upcard}"
  end

  def last_card_dealt
    hand.last
  end

  def display_hand
    puts "#{name}'s Hand: #{hand.join(", ")}"
  end

  def sum_of_cards
    sum = 0
    hand.each {|card| sum += card.value }

    hand.select { |card| card.card == 'A'}.count.times do 
        sum -= 10 if sum > Game::BLACKJACK
    end

    sum
  end

  def display_sum_of_cards
    puts "The sum of #{name}'s cards is #{sum_of_cards}"
  end

  def display_hit_result
    format "=> #{name} chooses to hit and draws a #{last_card_dealt}"
    display_hand
    display_sum_of_cards
  end

  def stay
    format "=> #{name} chooses to stay."
  end

  def blackjack?
    sum_of_cards == Game::BLACKJACK
  end

  def bust?
    sum_of_cards > Game::BLACKJACK
  end
end

class Deck
  SET_OF_CARDS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  SUITS = ['♠', '♥', '♣', '♦']

  attr_reader :cards

  def initialize(n)
    @cards = []
    single_deck = []

    SET_OF_CARDS.each do |card|
      SUITS.each do |suit|
        if card == 'A'
          value = 11
        elsif card == 'J' || card == 'Q' || card == 'K'
          value = 10
        else
          value = card.to_i
        end
        
        single_deck << Card.new(card, suit, value)
      end
    end

    n.times { @cards << single_deck }
    @cards = @cards.flatten.shuffle!
  end

  def deal_card
    cards.shift
  end
end

class Card
  attr_reader :card, :suit
  attr_accessor :value

  def initialize(card, suit, value)
    @card = card
    @suit = suit
    @value = value
  end

  def to_s
    "#{card} #{suit}"
  end
end

class Player
  include Formattable
  include Hand

  attr_accessor :name, :hand, :wins

  def initialize
    @name = ""
    @hand = []
    @wins = 0
  end

  def set_name
    puts "What is your name?"
    @name = gets.chomp
  end

  def record_win
    @wins += 1
  end

  def turn(deck)
    start_turn

    loop do
      break if blackjack?

      puts "\nWould you like to 'Hit' or 'Stay'?"
      choice = gets.chomp.downcase

      if choice == 'hit'
        add_card(deck.deal_card)
        display_hit_result
        break if blackjack? || bust?
      elsif choice == 'stay'
        stay
        break
      end

      next if !['hit','stay'].include?(choice)
    end
  end
end

class Dealer
  include Formattable
  include Hand

  MIN_HAND = 17

  attr_accessor :name, :hand

  def initialize
    @name = "Dealer"
    @hand = []
  end

  def turn(deck)
    start_turn
    
    loop do 
      break if blackjack?
      sleep 0.8

      if sum_of_cards < MIN_HAND
        add_card(deck.deal_card)
        display_hit_result
        break if blackjack? || bust?
      elsif sum_of_cards >= MIN_HAND
        stay
        break
      end
    end
  end
end

class Game
  include Formattable

  BLACKJACK = 21

  attr_accessor :deck, :player, :dealer, :rounds

  def initialize
    @deck = Deck.new(2)
    @player = Player.new
    @dealer = Dealer.new
    @rounds = 0
  end

  def reset_hands
    @player.reset
    @dealer.reset
  end

  def display_welcome_message
    system 'clear'
    format "Welcome to Blackjack!"
  end

  def deal_initial_cards
    2.times do
      player.add_card(deck.deal_card)
      dealer.add_card(deck.deal_card)
    end
  end

  def both_blackjack?
    player.blackjack? && dealer.blackjack?
  end

  def announce_blackjack(person)
    if person == @player
      "Congratulations, you got Blackjack!"
    else
      "#{person.name} got Blackjack."
    end
  end

  def announce_bust(person)
    "#{person.name} bust."
  end

  def blackjack_or_bust?(person)
    person.blackjack? || person.bust?
  end

  def end_by_blackjack_or_bust?
    blackjack_or_bust?(player) || blackjack_or_bust?(dealer)
  end

  def announce_blackjack_or_bust
    if both_blackjack?
      "Both #{player.name} and #{dealer.name} got Blackjack."
    elsif player.blackjack?
      player.record_win
      announce_blackjack(player)
    elsif dealer.blackjack? 
      announce_blackjack(dealer)
    elsif player.bust?
      announce_bust(player)
    elsif dealer.bust?
      announce_bust(dealer)
    end
  end

  def compare_hands
    if player.sum_of_cards > dealer.sum_of_cards
      player.record_win
      winning_message(player)
    elsif dealer.sum_of_cards > player.sum_of_cards
      winning_message(dealer)
    else
      "It's a tie."
    end
  end

  def winning_message(winner)
    "Winner: #{winner.name}"
  end

  def winner
    if end_by_blackjack_or_bust?
      if both_blackjack?
        " It's a tie."
      elsif player.blackjack? || dealer.bust?
        winning_message(player)
      else
        winning_message(dealer)
      end
    else
      compare_hands
    end
  end

  def display_result
    format "[ Result ]"

    if end_by_blackjack_or_bust?
      puts announce_blackjack_or_bust
    else
      player.display_sum_of_cards
      dealer.display_sum_of_cards
    end

    format "#{winner}"
  end

  def replay?
    puts "[ Another Round? (Y/N) ]"
    choice = gets.chomp.downcase

    until ['y','n'].include?(choice) do
      puts "Please enter 'Y' to play again or 'N' to exit."
      choice = gets.chomp.downcase
    end

    choice == 'y' ? true : false
  end

  def start_game
    system 'clear'
    self.rounds += 1
    puts "Welcome to Round #{rounds}:\n\n"
    deal_initial_cards
    dealer.display_upcard
    print_divider
  end

  def end_game
    format "Thanks for playing!"
    puts "=> You won #{player.wins} out of #{rounds} rounds."
  end

  def run
    display_welcome_message
    player.set_name

    loop do
      start_game

      loop do
        player.turn(deck)
        break if blackjack_or_bust?(player)
        dealer.turn(deck)
        break if end_by_blackjack_or_bust? || winner
      end

      display_result
      break if !replay?
      reset_hands
    end

    end_game
  end
end

Game.new.run
