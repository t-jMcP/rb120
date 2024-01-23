class GuessingGame
  def initialize(low_value, high_value)
    @range = (low_value..high_value).to_a
    @target_number = @range.sample
    @guesses_left = calculate_guesses(high_value - low_value)
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

  def calculate_guesses(range_size)
    @guesses_left = Math.log2(range_size).to_i + 1
  end

  def reset
    @guesses_left = calculate_guesses(@range.last - @range.first)
    @target_number = @range.sample
  end

  def show_guesses_remaining
    if @guesses_left == 1
      puts "Only 1 guess left"
    else  
      puts "You have #{@guesses_left} guesses remaining"
    end
  end

  def make_guess
    print "Enter a number between #{@range.first} and #{@range.last}: "
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

game = GuessingGame.new(501, 1500)
game.play

=begin
You have 10 guesses remaining.
Enter a number between 501 and 1500: 104
Invalid guess. Enter a number between 501 and 1500: 1000
Your guess is too low.

You have 9 guesses remaining.
Enter a number between 501 and 1500: 1250
Your guess is too low.

You have 8 guesses remaining.
Enter a number between 501 and 1500: 1375
Your guess is too high.

You have 7 guesses remaining.
Enter a number between 501 and 1500: 80
Invalid guess. Enter a number between 501 and 1500: 1312
Your guess is too low.

You have 6 guesses remaining.
Enter a number between 501 and 1500: 1343
Your guess is too low.

You have 5 guesses remaining.
Enter a number between 501 and 1500: 1359
Your guess is too high.

You have 4 guesses remaining.
Enter a number between 501 and 1500: 1351
Your guess is too low.

You have 3 guesses remaining.
Enter a number between 501 and 1500: 1355
That's the number!

You won!
=end

game.play

=begin
You have 10 guesses remaining.
Enter a number between 501 and 1500: 1000
Your guess is too high.

You have 9 guesses remaining.
Enter a number between 501 and 1500: 750
Your guess is too low.

You have 8 guesses remaining.
Enter a number between 501 and 1500: 875
Your guess is too high.

You have 7 guesses remaining.
Enter a number between 501 and 1500: 812
Your guess is too low.

You have 6 guesses remaining.
Enter a number between 501 and 1500: 843
Your guess is too high.

You have 5 guesses remaining.
Enter a number between 501 and 1500: 820
Your guess is too low.

You have 4 guesses remaining.
Enter a number between 501 and 1500: 830
Your guess is too low.

You have 3 guesses remaining.
Enter a number between 501 and 1500: 835
Your guess is too low.

You have 2 guesses remaining.
Enter a number between 501 and 1500: 836
Your guess is too low.

You have 1 guess remaining.
Enter a number between 501 and 1500: 837
Your guess is too low.

You have no more guesses. You lost!
=end
