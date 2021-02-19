require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def immediate_threat?
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_human_markers?(squares)
        return true
      end 
    end
    false 
  end 

  def find_vulnerable_square
    #check each line in WINNING_LINES to see which one has two human markers 
    #find the line with two human markers 
    #find the empty square number in the line and return 
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def two_identical_human_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    markers.all?(TTTGame::HUMAN_MARKER) && markers.size == 2 
  end 

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class ScoreKeeper
  attr_reader :human_score, :computer_score
  
  def initialize
    @human_score = 0
    @computer_score = 0
  end

  def increment_human_score
    @human_score += 1
  end

  def increment_computer_score
    @computer_score += 1
  end 
end 

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
    @score = ScoreKeeper.new 
  end

  def increment_score
    board.winning_marker == HUMAN_MARKER ? @score.increment_human_score : @score.increment_computer_score
  end

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      display_board
      player_move
      display_result
      increment_score
      display_score
      check_score
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def check_score
    if @score.human_score == 5 || @score.computer_score == 5
      declare_winner
    end
  end

  def declare_winner
    if @score.human_score > @score.computer_score
      puts "You won the game!"
      puts ""
    else 
      puts "Computer has won the game!"
      puts ""
    end 
  end 

  def display_score
    puts ""
    puts "You have #{@score.human_score} points, computer has #{@score.computer_score} points."
    puts ""
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys,', ')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def joinor(array, delimiter=', ', joining_word = 'or')
    return_string = ""
    count = 0

    if array.count == 2 
      return array[0].to_s + ' ' + joining_word + ' ' + array[1].to_s
    elsif array.count == 1
      return array[0].to_s 
    end  
 
    while count < array.length-1
      return_string << array[count].to_s + delimiter
      count +=1
    end 
    return_string + joining_word + ' ' + array[-1].to_s
  end 


  def computer_moves
    if board.immediate_threat?
      vulnerable_square = board.find_vulnerable_square
    else
      board[board.unmarked_keys.sample] = computer.marker
    end 
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play