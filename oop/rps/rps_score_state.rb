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
      puts "Please choose rock, paper or scissors:"
      choice = gets.chomp
      break choice if Move::OPTIONS.include?(choice)
      puts "Invalid choice"
    end

    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::OPTIONS.sample)
  end
end

class Move
  attr_reader :value

  OPTIONS = ["rock", "paper", "scissors"]

  WINNING_PAIRS = {
    "rock" => "scissors",
    "paper" => "rock",
    "scissors" => "paper"
  }

  def initialize(value)
    @value = value
  end

  def >(opposing_move)
    WINNING_PAIRS[value] == opposing_move.value
  end

  def to_s
    @value
  end
end

class RPSGame
  attr_accessor :human, :computer

  WINNING_SCORE = 10

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock Paper Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock Paper Scissors!"
  end

  def choose_moves
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
    increment_scores(winner)
  end

  def display_winner(winner)
    case winner
    when :human then puts "#{human.name} wins!"
    when :computer then puts "#{computer.name} wins!"
    else puts "It's a tie"
    end
  end

  def increment_scores(winner)
    case winner
    when :human then human.score += 1
    when :computer then computer.score += 1
    end

    display_scores
  end

  def display_scores
    puts "Current score: #{human.name} #{human.score} - " \
         "#{computer.name} #{computer.score}"
  end

  def game_over?
    human.score == WINNING_SCORE || computer.score == WINNING_SCORE
  end

  def display_final_score
    if human.score > computer.score
      puts "#{human.name} reached #{WINNING_SCORE} " \
           "rounds first. Congratulations!"
    else
      puts "#{computer.name} reached #{WINNING_SCORE} rounds first. Unlucky"
    end
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
        display_final_score
        break unless play_again?
      end
    end

    display_goodbye_message
  end
end

RPSGame.new.play
