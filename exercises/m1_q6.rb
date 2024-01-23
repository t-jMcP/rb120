class GuessingGame
  GUESSES_NUMBER = 7
  RANGE = (1..100).to_a

  def initialize
    @guesses_left = GUESSES_NUMBER
    @target_number = RANGE.sample
  end

  def play
    reset
    result = nil

    loop do
      show_guesses_remaining
      guess = make_guess

      result = check_guess(guess)
      break if result == :correct

      @guesses_left -= 1
      break if @guesses_left == 0
    end

    show_final_result(result)
  end

  private
  def reset
    @guesses_left = GUESSES_NUMBER
    @target_number = RANGE.sample
  end

  def show_guesses_remaining
    if @guesses_left == 1
      puts "Only 1 guess left"
    else  
      puts "You have #{@guesses_left} guesses remaining"
    end
  end

  def make_guess
    print "Enter a number between #{RANGE.first} and #{RANGE.last}: "
    gets.chomp.to_i
  end

  def check_guess(guess)
    if guess == @target_number
      :correct
    elsif guess < @target_number
      puts "Your guess is too low"
      :incorrect
    else
      puts "Your guess is too high"
      :incorrect
    end
  end

  def show_final_result(result)
    if result == :correct
      puts "That's the number!"
      puts
      puts "You won!"
    else
      puts "You have no more guesses left. You lost!"
    end
  end
end

game = GuessingGame.new
game.play

=begin
You have 7 guesses remaining.
Enter a number between 1 and 100: 104
Invalid guess. Enter a number between 1 and 100: 50
Your guess is too low.

You have 6 guesses remaining.
Enter a number between 1 and 100: 75
Your guess is too low.

You have 5 guesses remaining.
Enter a number between 1 and 100: 85
Your guess is too high.

You have 4 guesses remaining.
Enter a number between 1 and 100: 0
Invalid guess. Enter a number between 1 and 100: 80

You have 3 guesses remaining.
Enter a number between 1 and 100: 81
That's the number!

You won!
=end

game.play

=begin
You have 7 guesses remaining.
Enter a number between 1 and 100: 50
Your guess is too high.

You have 6 guesses remaining.
Enter a number between 1 and 100: 25
Your guess is too low.

You have 5 guesses remaining.
Enter a number between 1 and 100: 37
Your guess is too high.

You have 4 guesses remaining.
Enter a number between 1 and 100: 31
Your guess is too low.

You have 3 guesses remaining.
Enter a number between 1 and 100: 34
Your guess is too high.

You have 2 guesses remaining.
Enter a number between 1 and 100: 32
Your guess is too low.

You have 1 guess remaining.
Enter a number between 1 and 100: 32
Your guess is too low.

You have no more guesses. You lost!
=end
