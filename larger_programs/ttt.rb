module Formattable
  def prompt(message)
    puts "=> #{message}"
  end

  def joinor(arr, delimiter = ', ', word = 'or')
    arr.each_with_object("") do |element, text|
      if element == arr.last
        last_delimiter = arr.length > 2 ? delimiter + word : " #{word}"
        text << "#{last_delimiter} "
      elsif element != arr.first
        text << delimiter
      end

      text << element.to_s
    end
  end

  def clear
    system "clear"
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [7, 5, 3]]

  MIDDLE_SQUARE = 5

  def initialize
    @squares = create_empty_squares
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

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def near_complete_lines(player_marker)
    WINNING_LINES.select do |line|
      three_squares = @squares.values_at(*line)
      marker_count(three_squares, player_marker) == 2 &&
        three_squares.count(&:unmarked?) == 1
    end
  end

  def middle_square_unmarked?
    @squares[MIDDLE_SQUARE].unmarked?
  end

  def unmarked_squares
    @squares.select { |_, square| square.unmarked? }.keys
  end

  def full?
    unmarked_squares.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      three_squares = @squares.values_at(*line)
      if all_marked?(three_squares) && markers_identical?(three_squares)
        return three_squares.first.marker
      end
    end

    nil
  end

  def reset
    @squares = create_empty_squares
  end

  private

  def create_empty_squares
    squares_hash = {}
    (1..9).each { |num| squares_hash[num] = Square.new }
    squares_hash
  end

  def marker_count(squares, marker)
    squares.count { |square| square.marker == marker }
  end

  def all_marked?(squares)
    squares.all? { |square| !square.unmarked? }
  end

  def markers_identical?(squares)
    markers = squares.map(&:marker)
    markers.uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def to_s
    marker
  end
end

class Player
  attr_reader :marker, :name

  def initialize(board)
    @board = board
  end

  def to_s
    name
  end
end

class Human < Player
  include Formattable

  def choose_name
    name_choice = ""

    loop do
      prompt("What's your name?")
      name_choice = gets.chomp
      break unless blank_string?(name_choice)
      prompt("Name can't be blank")
    end

    @name = name_choice
  end

  def choose_marker
    marker_choice = ""
    prompt("Which marker would you like? (Must be a single character)")

    loop do
      marker_choice = gets.chomp
      break if valid_marker?(marker_choice)
      prompt("Invalid marker. Please choose a single character")
    end

    @marker = marker_choice
  end

  def choose_who_moves_first(opponent)
    turn_choice = ""
    prompt("Who should move first? (please select a number between 1 and 3)")
    puts "1. #{@name}\n2. #{opponent}\n3. Random"

    loop do
      turn_choice = convert_turn_choice(gets.chomp, opponent)
      break if turn_choice == @name || turn_choice == opponent
      prompt('Invalid option. Please choose a number between 1 and 3')
    end

    turn_choice
  end

  def move
    square = nil
    prompt("Please choose a square (options: " \
           "#{joinor(@board.unmarked_squares)})")

    loop do
      square = gets.chomp.to_i
      break if @board.unmarked_squares.include?(square)
      prompt("Invalid entry. Please choose an empty square between 1 and 9")
    end

    @board[square] = marker
  end

  private

  def blank_string?(str)
    str.empty? || str.chars.uniq[0] == " "
  end

  def valid_marker?(marker_choice)
    marker_choice.length == 1 && marker_choice != " "
  end

  def convert_turn_choice(turn_choice, opponent)
    case turn_choice
    when "1" then @name
    when "2" then opponent
    when "3" then [@name, opponent].sample
    end
  end
end

class Computer < Player
  DEFAULT_MARKER = "O"
  ALTERNATIVE_MARKER = "X"
  COMPUTER_NAMES = ['R2D2', 'Hal', 'Sonny', 'Marvin', 'Dolores', 'T-800'] +
                   ['Ava', 'VIKI', 'Bard', 'Sydney']

  def choose_name(opponent_name)
    name_choice = ""

    loop do
      name_choice = COMPUTER_NAMES.sample
      break unless name_choice == opponent_name
    end

    @name = name_choice
  end

  def choose_marker(opponent_marker)
    @opponent_marker = opponent_marker

    @marker = case opponent_marker
              when DEFAULT_MARKER then ALTERNATIVE_MARKER
              else DEFAULT_MARKER
              end
  end

  def move
    computer_threats = @board.near_complete_lines(@marker)
    opponent_threats = @board.near_complete_lines(@opponent_marker)
    square = choose_square(computer_threats, opponent_threats)
    @board[square] = @marker
  end

  private

  def choose_square(computer_threats, opponent_threats)
    if !computer_threats.empty?
      computer_threats[0].find { |num| @board.unmarked_squares.include?(num) }
    elsif !opponent_threats.empty?
      opponent_threats[0].find { |num| @board.unmarked_squares.include?(num) }
    elsif @board.middle_square_unmarked?
      Board::MIDDLE_SQUARE
    else
      @board.unmarked_squares.sample
    end
  end
end

class Score
  include Formattable
  WINNING_SCORE = 5

  def initialize(marker1, marker2)
    @player1 = { marker: marker1, score: 0 }
    @player2 = { marker: marker2, score: 0 }
  end

  def increment(round_winner)
    if round_winner == @player1[:marker]
      @player1[:score] += 1
    elsif round_winner == @player2[:marker]
      @player2[:score] += 1
    end
  end

  def current(marker)
    if marker == @player1[:marker]
      @player1[:score]
    elsif marker == @player2[:marker]
      @player2[:score]
    end
  end

  def winning_score_reached?
    @player1[:score] == WINNING_SCORE || @player2[:score] == WINNING_SCORE
  end

  def highest
    if @player1[:score] > @player2[:score]
      @player1[:marker]
    elsif @player1[:score] < @player2[:score]
      @player2[:marker]
    end
  end

  def reset
    @player1[:score] = 0
    @player2[:score] = 0
  end
end

class TTTGame
  include Formattable

  def initialize
    @board = Board.new
    @human = Human.new(@board)
    @computer = Computer.new(@board)
  end

  def play
    setup_game
    play_game
    display_goodbye_message
  end

  private

  def setup_game
    clear
    display_welcome_message
    set_names
    set_markers
    set_turn_order
  end

  def display_welcome_message
    prompt("Welcome to Tic Tac Toe! First to #{Score::WINNING_SCORE} rounds " \
           "wins")
    puts ""
  end

  def set_names
    @human.choose_name
    @computer.choose_name(@human.name)
  end

  def set_markers
    @human.choose_marker
    @computer.choose_marker(@human.marker)
    @scores = Score.new(@human.marker, @computer.marker)
  end

  def set_turn_order
    turn_choice = @human.choose_who_moves_first(@computer.name)
    prompt("#{turn_choice} moving first")
    @first_turn = case turn_choice
                  when @human.name then @human.marker
                  else @computer.marker
                  end
    @current_marker = @first_turn
    sleep(1)
  end

  def play_game
    loop do
      play_round

      if game_over?
        determine_final_result
        break unless play_again?
        reset_game(reset_score: true)
      else
        reset_game
      end
    end
  end

  def display_goodbye_message
    prompt("Thanks for playing Tic Tac Toe!")
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    prompt("You're #{@human.marker}. #{@computer} is #{@computer.marker}")
    puts ""
    @board.draw
    puts ""
  end

  def current_player_moves
    if human_turn?
      @human.move
      @current_marker = @computer.marker
    else
      @computer.move
      @current_marker = @human.marker
    end
  end

  def human_turn?
    @current_marker == @human.marker
  end

  def play_round
    display_board

    loop do
      current_player_moves
      break if @board.someone_won? || @board.full?
      clear_screen_and_display_board if human_turn?
    end

    determine_result
  end

  def determine_result
    winner = @board.winning_marker
    @scores.increment(winner)
    display_result(winner)
  end

  def display_result(winner)
    clear_screen_and_display_board

    case winner
    when @human.marker then prompt("You won this round!")
    when @computer.marker then prompt("#{@computer} won this round!")
    else prompt("It's a tie!")
    end

    show_current_score
  end

  def show_current_score
    prompt("Current score: #{@human} #{@scores.current(@human.marker)} - " \
           "#{@computer} #{@scores.current(@computer.marker)} ")
    sleep(2)
  end

  def game_over?
    @scores.winning_score_reached?
  end

  def determine_final_result
    final_winner = @scores.highest
    display_final_result(final_winner)
  end

  def display_final_result(winner)
    case winner
    when @human.marker then prompt("You reached #{Score::WINNING_SCORE} " \
                                   "rounds first. Congratulations!")
    else prompt("#{@computer} reached #{Score::WINNING_SCORE} " \
                "rounds first. Unlucky!")
    end
  end

  def play_again?
    prompt("Do you want to play again? (Press 'Y' to confirm)")
    repeat_choice = gets.chomp
    repeat_choice.downcase.start_with?('y')
  end

  def reset_game(reset_score: false)
    @board.reset
    @current_marker = @first_turn
    clear
    if reset_score
      @scores.reset
      display_play_again_message
    else
      display_new_round_message
    end
  end

  def display_new_round_message
    prompt("Starting the next round")
    sleep(1)
  end

  def display_play_again_message
    prompt("Starting a new game")
    sleep(1)
    puts ""
  end
end

game = TTTGame.new
game.play
