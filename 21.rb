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
    self.hand << card
    puts ""
    puts "The new card is: #{card}."
    puts ""
  end


  def busted?
    self.total > 21
  end

  def total
    sum = 0
    count = 0

    self.hand.each do |card|
      if card.value == 'Ace'
        count +=1
      end 
    end 

    self.hand.each do |card|
      sum += card.to_i
    end

    count > 0 ? determine_ace_value(count, sum) : sum
  end

  def determine_ace_value(count, sum)
    if count == 1 
      sum <= 10 ? sum += 11 : sum += 1
    elsif count == 2
      sum <= 9 ? sum += 12 : sum += 2
    elsif count == 3
      sum <= 8 ? sum += 13 : sum += 3 
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
      participant.hand << @deck.deal
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
        puts "You've busted! You lose!"
        break
      end 

      break if answer == 'stay'
    end
  end

  def dealer_turn
    loop do 
      if dealer.total >= 17
        puts ""
        puts "Dealer stays."
      else 
        puts ""
        puts "Dealer hits."
        dealer.hit(@deck)
      end
      break if dealer.total >= 17
    end 
    if dealer.busted?
      puts "Dealer has busted!"
    end
  end

  def show_result
    if !player.busted? && player.total > dealer.total
      puts "You win!"
    elsif player.total == dealer.total
      puts "It's a tie!" 
    elsif  !dealer.busted? && dealer.total > player.total
      puts "Dealer wins!"
    end 
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
      break if ['y','n'].include? answer.downcase
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
      deal_cards(player, 2)
      deal_cards(dealer, 2)
      show_initial_cards
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