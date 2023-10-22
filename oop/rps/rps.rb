=begin
Textual description:
Rock, Paper, Scissors is a two-player game where each player chooses
one of three possible moves: rock, paper, or scissors. The chosen moves
will then be compared to see who wins, according to the following rules:

- rock beats scissors
- scissors beats paper
- paper beats rock

If the players chose the same move, then it's a tie.

Nouns & verbs:
- Player: choose
- Move
- Rule
Unassigned: compare
=end

class Player
  attr_accessor :move, :name, :score

  def initialize
    @move = nil
    @score = 0
    set_name
  end
end

class Human < Player
  def set_name
    user_name = nil

    loop do
      puts "What's your name?"
      user_name = gets.chomp
      break unless user_name.empty?
      puts "Please enter a value"
    end

    self.name = user_name
  end

  def choose
    choice = nil

    loop do
      puts "Please choose rock, paper, scissors, lizard or spock:"
      choice = gets.chomp
      break choice if Move::OPTIONS.include?(choice)
      puts "Invalid choice"
    end

    self.move = Move.new(choice, :human)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::OPTIONS.sample, :computer)
  end
end

class Move
  attr_reader :value

  OPTIONS = ["rock", "paper", "scissors", "lizard", "spock"]

  WINNING_PAIRS = {
    "rock" => ["scissors", "lizard"],
    "paper" => ["rock", "spock"],
    "scissors" => ["paper", "lizard"],
    "lizard" => ["paper", "spock"],
    "spock" => ["rock", "scissors"]
  }

  @@human_moves = []
  @@computer_moves = []

  def initialize(value, player)
    @value = value
    if player == :human
      @@human_moves << value
    elsif player == :computer
      @@computer_moves << value
    end
  end

  def >(opposing_move)
    WINNING_PAIRS[value].include?(opposing_move.value)
  end

  def to_s
    @value
  end

  def self.show_history
    print "human move history: "
    @@human_moves.each { |move| print "#{move} " }
    print "\n"

    print "computer move history: "
    @@computer_moves.each { |move| print "#{move} " }
    print "\n"
  end

  def self.reset_history
    @@human_moves = []
    @@computer_moves = []
  end
end

class Score
  attr_accessor :human, :computer

  WINNING_SCORE = 10

  def initialize
    @human = 0
    @computer = 0
  end

  def increment(winner)
    if winner == :human
      self.human += 1
    elsif winner == :computer
      self.computer += 1
    end
  end

  def display_current(human_name, computer_name)
    puts "Current score: #{human_name} #{human} - " \
         "#{computer_name} #{computer}"
  end

  def final_score_reached?
    human == WINNING_SCORE || computer == WINNING_SCORE
  end

  def display_final(human_name, computer_name)
    if human > computer
      puts "#{human_name} reached #{WINNING_SCORE} " \
           "rounds first. Congratulations!"
    else
      puts "#{computer_name} reached #{WINNING_SCORE} rounds first. Unlucky"
    end
  end
end

class RPSGame
  attr_reader :human, :computer, :score

  def initialize
    @human = Human.new
    @computer = Computer.new
    @score = Score.new
  end

  def display_welcome_message
    puts "Welcome to Rock Paper Scissors Lizard Spock!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock Paper Scissors Lizard Spock!"
  end

  def see_move_history?
    puts "Do you want to see the move history? (Type Y to confirm)"
    gets.chomp.downcase == 'y'
  end

  def choose_moves
    Move.show_history if see_move_history?
    human.choose
    computer.choose
    display_moves
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def determine_winner
    winner = if human.move > computer.move
               :human
             elsif computer.move > human.move
               :computer
             else
               :tie
             end
    display_winner(winner)
    score.increment(winner)
    score.display_current(human.name, computer.name)
  end

  def display_winner(winner)
    case winner
    when :human then puts "#{human.name} wins!"
    when :computer then puts "#{computer.name} wins!"
    else puts "It's a tie"
    end
  end

  def game_over?
    score.final_score_reached?
  end

  def end_game
    score.display_final(human.name, computer.name)
    Move.reset_history
  end

  def play_again?
    puts "Do you want to play another round? (Type Y to confirm)"
    gets.chomp.downcase == 'y'
  end

  def play
    display_welcome_message

    loop do
      choose_moves
      determine_winner
      if game_over?
        end_game
        break unless play_again?
      end
    end

    display_goodbye_message
  end
end

RPSGame.new.play
