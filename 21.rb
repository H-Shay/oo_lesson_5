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
    ['King', 'Queen', 'Ace', 'Jack'].each do |value|
      deck << Card.new(suit, value)
    end
  end

  def deal
    card = deck.sample
    deck.delete(card)
  end
end

class Participant
  attr_accessor :hand

  def initialize
    @hand = []
  end

  def hit(deck)
    card = deck.deal
    hand << card
    puts ""
    puts "The new card is: #{card}."
    puts ""
  end

  def busted?
    total > 21
  end

  def total
    sum = 0
    count = 0

    hand.each do |card|
      count += 1 if card.value == 'Ace'
    end

    hand.each do |card|
      sum += card.to_i
    end

    count > 0 ? determine_ace_value(count, sum) : sum
  end

  def determine_ace_value(count, sum)
    case count
    when 1
      sum += sum <= 10 ? 11 : 1
    when 2
      sum += sum <= 9 ? 12 : 2
    when 3
      sum += sum <= 8 ? 13 : 3
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

  def deal_initial_hand(participant1, participant2)
    2.times do
      participant1.hand << deck.deal
      participant2.hand << deck.deal
    end
    show_initial_cards
  end

  def show_initial_cards
    puts ""
    puts "Your cards: #{player.hand[0]} and #{player.hand[1]}."
    puts "The dealer's card: #{dealer.hand[0]}"
    puts ""
  end

  def player_turn
    loop do
      answer = hit_or_stay
      if answer == 'hit'
        player.hit(deck)
      end

      if player.busted?
        puts "You've busted! You lose!"
        break
      end

      break if answer == 'stay'
    end
  end

  def hit_or_stay
    puts "Would you like to hit or stay?"
    answer = nil

    loop do
      answer = gets.chomp
      break if ['hit', 'stay'].include?(answer)
      puts "Invalid input. Please enter a valid choice: hit or stay."
    end
    answer
  end

  def dealer_turn
    loop do
      if dealer.total >= 17
        puts "Dealer stays."
      else
        puts "Dealer hits."
        dealer.hit(deck)
      end
      break if dealer.total >= 17
    end
    puts "Dealer has busted!" if dealer.busted?
  end

  def show_result
    if player_wins?
      puts "You win!"
    elsif player.total == dealer.total
      puts "It's a tie!"
    elsif dealer_wins?
      puts "Dealer wins!"
    end
  end

  def player_wins?
    !player.busted? && player.total > dealer.total
  end

  def dealer_wins?
    !dealer.busted? && dealer.total > player.total
  end

  def reset_game
    initialize
  end

  def welcome_message
    puts ""
    puts "Welcome to 21. Let's play some cards!"
    puts ""
  end

  def play_again?
    answer = ""
    loop do
      puts "Would you like to play again? (y/n)?"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Invalid input, please choose either y or n."
    end
    answer == 'y'
  end

  def goodbye_message
    puts "Thanks for playing 21!"
  end

  def start
    welcome_message
    loop do
      deal_initial_hand(dealer, player)
      player_turn
      dealer_turn unless player.busted?
      show_result
      break unless play_again?
      reset_game
    end
    goodbye_message
  end
end

Game.new.start
