class Deck
  attr_reader :cards

  SET_OF_CARDS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  SUITS = ['♠', '♥', '♣', '♦']

  def initialize(n)
    @cards = [] # an array of Card objects
    single_deck = []

    SET_OF_CARDS.each do |card|
      SUITS.each do |suit|
        # If the card is a number card
        if card.to_i != 0
          value = card.to_i
        elsif card == 'J' || card == 'Q' || card == 'K'
          value = 10
        elsif card == 'A'
          value = 11
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

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def sum_of_cards
    sum = 0
    cards.each {|card| sum += card.value }

    if cards.map { |card| card.card }.include?('A') && sum > 21
      sum -= 10
    end

    sum
  end

  def to_s
    "#{cards.join(", ")}"
  end

  def blackjack?
    sum_of_cards == 21
  end

  def bust?
    sum_of_cards > 21
  end

end

class Player
  attr_reader :name
  attr_accessor :hand

  def initialize(name)
    @name = name
    @hand = Hand.new
  end

  def display_hand
    puts "#{name}'s Hand: #{hand}"
  end

  def display_sum_of_cards
    puts "- #{name}'s cards have a sum of #{hand.sum_of_cards}."
  end

  def hit(deck)
    hand.cards << deck.deal_card
  end

  def stay
    puts "=> #{name} chooses to stay.\n\n"
  end

  def turn(deck)
    loop do
      sleep 0.8
      break if hand.blackjack?

      puts "\nWould you like to Hit ('h') or Stay ('s')?"
      choice = gets.chomp.downcase

      if choice == 'h'
        hit(deck)
        puts "=> #{name} chooses to hit and draws a #{hand.cards.last}."
        display_hand
        display_sum_of_cards
        break if hand.blackjack? || hand.bust?
      elsif choice == 's'
        stay
        break
      else
        puts "Sorry, that is not a valid option"
        next
      end
    end
  end

end

class Dealer < Player

  def turn(deck)
    loop do 
      if hand.sum_of_cards < 17
        hit(deck)
        puts "=> #{name} chooses to hit and draws a #{hand.cards.last}."
        display_hand
        display_sum_of_cards
        break if hand.blackjack? || hand.bust?
      elsif hand.sum_of_cards >= 17
        stay
        break
      end
    end
  end

end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new(2)
    @player = Player.new("Jane")
    @dealer = Dealer.new("Dealer")
  end

  def welcome_message
    system 'clear'
    puts "Welcome to Blackjack!\n\n"
  end

  def deal_initial_cards
    2.times do
      player.hit(deck)
      dealer.hit(deck)
    end
  end

  def blackjack_or_bust
    if player.hand.blackjack?
      "#{player.name} got Blackjack!"
    elsif dealer.hand.blackjack? 
      "#{dealer.name} got Blackjack!"
    elsif player.hand.bust?
      "#{player.name} bust!"
    elsif dealer.hand.bust?
      "#{dealer.name} bust!"
    else
      false
    end
  end

  def winner
    if blackjack_or_bust
      if player.hand.blackjack? || dealer.hand.bust?
        "#{player.name} wins!"
      else
        "#{dealer.name} wins!"
      end
    else
      if player.hand.sum_of_cards > dealer.hand.sum_of_cards 
        "#{player.name} wins!"
      elsif dealer.hand.sum_of_cards > player.hand.sum_of_cards
        "#{dealer.name} wins!"
      else
        "It's a tie."
      end
    end
  end

  def display_winner
    if blackjack_or_bust
      puts "#{blackjack_or_bust}"
    else
      player.display_sum_of_cards
      dealer.display_sum_of_cards
    end

    puts "#{winner}"
  end

  def run
    welcome_message
    deal_initial_cards
    player.display_hand
    player.display_sum_of_cards
    dealer.display_hand
    dealer.display_sum_of_cards

    loop do
      break if blackjack_or_bust
      player.turn(deck)
      break if blackjack_or_bust
      dealer.turn(deck)
      break if blackjack_or_bust || winner
    end

    display_winner
  end

end

Game.new.run
