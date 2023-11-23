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

module Displayable
  include Formattable

  def display_welcome_message(winning_score)
    prompt("Welcome to Tic Tac Toe! First to #{winning_score} " \
           "rounds wins")
    puts ""
  end

  def display_who_moves_first(first_mover)
    prompt("#{first_mover} moving first")
    sleep(2)
  end

  def display_current_score(player1, player2)
    prompt("Current score: #{player1.name} #{player1.score} - " \
           "#{player2.name} #{player2.score}")
  end

  def display_board(player1, player2, board)
    prompt("You're #{player1.marker}. #{player2} is #{player2.marker}")
    puts ""
    board.draw
    puts ""
  end

  def display_round_winner(winner_name, human_name, computer_name)
    case winner_name
    when human_name then prompt("You won this round!")
    when computer_name then prompt("#{computer_name} won this round!")
    else prompt("It's a tie!")
    end

    sleep(2)
  end

  def display_new_round_message
    prompt("Starting the next round")
    sleep(1)
  end

  def display_game_winner(winner_name, human_name, computer_name, winning_score)
    case winner_name
    when human_name then prompt("You reached #{winning_score}" \
                                "rounds first. Congratulations!")
    when computer_name then prompt("#{computer_name} reached " \
                                   "#{winning_score} rounds first. Unlucky!")
    end
  end

  def display_play_again_message
    clear
    prompt("Starting a new game")
    sleep(1)
    puts ""
  end

  def display_goodbye_message
    prompt("Thanks for playing Tic Tac Toe!")
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
    puts "1        |2        |3"
    puts "         |         |"
    puts "    #{@squares[1]}    |    #{@squares[2]}    |    #{@squares[3]}"
    puts "         |         |"
    puts "         |         |"
    puts "---------+---------+--------"
    puts "4        |5        |6"
    puts "         |         |"
    puts "    #{@squares[4]}    |    #{@squares[5]}    |    #{@squares[6]}"
    puts "         |         |"
    puts "         |         |"
    puts "---------+---------+--------"
    puts "7        |8        |9"
    puts "         |         |"
    puts "    #{@squares[7]}    |    #{@squares[8]}    |    #{@squares[9]}"
    puts "         |         |"
    puts "         |         |"
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
  attr_accessor :score

  def initialize(board)
    @board = board
    @score = 0
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
    prompt("Who should start the first round? " \
           "(please select a number between 1 and 3)")
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

class TTTGame
  WINNING_SCORE = 5
  include Formattable, Displayable

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
    display_welcome_message(WINNING_SCORE)
    set_names
    set_markers
    set_turn_order
  end

  def set_names
    @human.choose_name
    @computer.choose_name(@human.name)
  end

  def set_markers
    @human.choose_marker
    @computer.choose_marker(@human.marker)
  end

  def set_turn_order
    @first_turn = @human.choose_who_moves_first(@computer.name)
    @current_move = @first_turn
    display_who_moves_first(@first_turn)
  end

  def play_game
    loop do
      play_round

      if game_over?
        determine_game_winner
        break unless play_again?
        reset_board(new_game: true)
      else
        reset_board
      end
    end
  end

  def play_round
    show_game_state

    loop do
      current_player_moves
      break if @board.someone_won? || @board.full?
      show_game_state if human_turn?
    end

    end_round
  end

  def show_game_state
    clear
    display_current_score(@human, @computer)
    display_board(@human, @computer, @board)
  end

  def current_player_moves
    if human_turn?
      @human.move
      @current_move = @computer.name
    else
      @computer.move
      @current_move = @human.name
    end
  end

  def human_turn?
    @current_move == @human.name
  end

  def end_round
    round_winner = @board.winning_marker

    if round_winner == @human.marker
      @human.score += 1
      winner_name = @human.name
    elsif round_winner == @computer.marker
      @computer.score += 1
      winner_name = @computer.name
    end

    show_game_state
    display_round_winner(winner_name, @human.name, @computer.name)
  end

  def game_over?
    @human.score == WINNING_SCORE || @computer.score == WINNING_SCORE
  end

  def determine_game_winner
    if @human.score > @computer.score
      winner_name = @human.name
    elsif @human.score < @computer.score
      winner_name = @computer.name
    end

    display_game_winner(winner_name, @human.name, @computer.name, WINNING_SCORE)
  end

  def play_again?
    prompt("Do you want to play again? (Press 'Y' to confirm)")
    repeat_choice = gets.chomp
    repeat_choice.downcase.start_with?('y')
  end

  def reset_board(new_game: false)
    @board.reset

    if new_game
      reset_scores
      display_play_again_message
      set_turn_order
    else
      switch_first_turn
      display_new_round_message
      display_who_moves_first(@first_turn)
    end
  end

  def reset_scores
    @human.score = 0
    @computer.score = 0
  end

  def switch_first_turn
    @first_turn = case @first_turn
                  when @human.name then @computer.name
                  when @computer.name then @human.name
                  end
    @current_move = @first_turn
  end
end

game = TTTGame.new
game.play
