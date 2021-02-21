require 'pry'

class Card
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit 
    @value = value 
  end

  def to_s
    "#{value} of #{suit}"
  end

  def to_i
    case value
    when 'King'
      10
    when 'Queen'
      10
    when 'Jack'
      10
    else 
      value.to_i
    end 
  end
end

class Deck
  attr_accessor :deck

  def initialize
    @deck = []
    add_suit('Hearts')
    add_suit('Clubs')
    add_suit('Diamonds')
    add_suit('Spades')
  end

  def add_suit(suit)
    (2..10).each do |value|
      deck << Card.new(suit, value)
    end
    deck << Card.new(suit, 'Ace')
    deck << Card.new(suit, 'King')
    deck << Card.new(suit, 'Queen')
    deck << Card.new(suit, 'Jack')
  end

  def deal
    card = @deck.sample
  end

  def remove_card(card)
    @deck.delete(card)
  end
end


class Participant
  attr_accessor :hand

  def initialize
    @hand = []
  end

  def hit(deck)
    card = deck.deal
    self.hand << card
    deck.remove_card(card)
    puts ""
    puts "The new card is: #{card}."
    puts ""
  end


  def busted?
    self.total > 21
  end

  def total
    sum = 0
    self.hand.each do |card|
      if card.value == 'Ace'
          #do something else here
      else
        sum += card.to_i
      end 
    end
    sum
  end
end

class Player < Participant
end

class Dealer < Participant 
end

class Game
  attr_accessor :deck, :player, :dealer
  
  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def deal_cards(participant, num_cards)
    num_cards.times do 
      card = @deck.deal
      participant.hand << card
      @deck.remove_card(card)
    end
  end

  def show_initial_cards
    puts ""
    puts "Your cards: #{player.hand[0]} and #{player.hand[1]}."
    puts "The dealer's card: #{dealer.hand[0]}"
    puts ""
  end 

  def player_turn
    loop do 
      puts "Would you like to hit or stay?"
      answer = nil

      loop do 
        answer = gets.chomp
        break if ['hit', 'stay'].include?(answer)
        puts "Invalid input. Please enter a valid choice: hit or stay."
      end 

      if answer == 'hit'
        player.hit(@deck)
      end 

      if player.busted?
        puts "You lose!"
        break
      end 

      break if answer == 'stay'
    end
  end

  def dealer_turn
    dealer.hit(@deck) unless dealer.total >= 17
    puts ""
    puts "Dealer stays."
    puts ""
  end

  def show_result
    puts "#{player.hand}"
    puts "#{dealer.hand}"
    if player.total > dealer.total
      puts "You win!"
    else 
      puts "Delaer wins!"
    end 
  end

  def start
    deal_cards(player, 2)
    deal_cards(dealer, 2)
    show_initial_cards
    player_turn
    dealer_turn unless player.busted?
    show_result
  end
end

Game.new.start