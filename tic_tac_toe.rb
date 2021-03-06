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

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
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
  # rubocop:enable Metrics/MethodLength

  def someone_won?
    !!winning_marker
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

  def computer_winning_move
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares, TTTGame::COMPUTER_MARKER)
        squares.each do |square|
          if square.marker == Square::INITIAL_MARKER
            square.marker = TTTGame::COMPUTER_MARKER
          end
        end
      end
    end
  end

  def computer_nearly_winning?
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares, TTTGame::COMPUTER_MARKER)
        return true
      end
    end
    false
  end

  def immediate_threat?
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares, TTTGame::HUMAN_MARKER)
        return true
      end
    end
    false
  end

  def defend_vulnerable_square
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares, TTTGame::HUMAN_MARKER)
        squares.each do |square|
          if square.marker == Square::INITIAL_MARKER
            square.marker = TTTGame::COMPUTER_MARKER
          end
        end
      end
    end
  end

  private

  def two_identical_markers?(squares, type_of_marker)
    markers = squares.select(&:marked?).collect(&:marker)
    markers.all?(type_of_marker) && markers.size == 2
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
  attr_accessor :marker, :name

  def initialize(marker=nil, name = nil)
    @marker = marker
    @name = name
  end
end

class ScoreKeeper
  attr_accessor :human_score, :computer_score

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
  attr_reader :board, :human, :computer
  attr_writer :current_marker
  attr_accessor :score

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Player.new
    @current_marker = nil
    @score = ScoreKeeper.new
  end

  def choose_marker
    puts "Please choose a marker: X or O."
    answer = nil

    loop do
      answer = gets.chomp
      break if ['X', 'O'].include?(answer)
      puts "Invalid choice. Please select either X or O."
    end

    human.marker = answer
    computer.marker = human.marker == 'X' ? 'O' : 'X'
    set_marker_constant
  end

  def set_marker_constant
    TTTGame.const_set(:HUMAN_MARKER, human.marker)
    TTTGame.const_set(:COMPUTER_MARKER, computer.marker)
  end

  def choose_who_goes_first
    puts "Would you like to go first? (y/n)"
    answer = nil

    loop do
      answer = gets.chomp
      break if ['y', 'n'].include?(answer)
      puts "Invalid choice, please select y or n."
    end

    assign_current_marker(answer)
  end

  def assign_current_marker(answer)
    @current_marker = if answer == 'y'
                        human.marker
                      else
                        computer.marker
                      end
  end

  def set_name
    puts "What shall I call you? Please enter your name."
    answer = gets.chomp
    @human.name = answer
    @computer.name = ['Roger', 'Hal', 'Homer'].sample
    puts ""
    puts "Hello, #{human.name}. My name is #{computer.name}."
  end

  def increment_and_display_score
    case board.winning_marker
    when human.marker
      score.increment_human_score
    when computer.marker
      score.increment_computer_score
    end
    display_score
  end

  def play
    clear
    display_welcome_message
    choose_marker
    choose_who_goes_first
    set_name
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      display_board
      player_move
      display_result
      increment_and_display_score
      check_score
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def check_score
    declare_winner if score.human_score == 5 || score.computer_score == 5
  end

  def declare_winner
    if score.human_score > score.computer_score
      puts "#{human.name} won the game!"
    else
      puts "#{computer.name} has won the game!"
    end
    puts " "
    score.human_score = 0
    score.computer_score = 0
  end

  def display_score
    puts ""
    puts "#{human.name} has #{score.human_score} points."
    puts "#{computer.name} has #{score.computer_score} points."
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
    @current_marker == human.marker
  end

  def display_board
    puts "#{human.name} is an #{human.marker}."
    puts "#{computer.name} is an #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys, ', ')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def joinor(arr, delimiter=', ', word='or')
    case arr.size
    when 0 then ''
    when 1 then arr.first
    when 2 then arr.join(" #{word} ")
    else
      arr[-1] = "#{word} #{arr.last}"
      arr.join(delimiter)
    end
  end

  def computer_moves
    if board.computer_nearly_winning?
      board.computer_winning_move
    elsif board.unmarked_keys.include?(5)
      board[5] = computer.marker
    elsif board.immediate_threat?
      board.defend_vulnerable_square
    else
      computer_random_move
    end
  end

  def computer_random_move
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
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
    choose_who_goes_first
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
