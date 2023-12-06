module Displayable
  def prompt(message)
    puts "=> #{message}"
  end

  def display_welcome_message(game, winning_score)
    prompt("Welcome to #{game}! First to #{winning_score} " \
           "rounds wins")
  end

  def display_totals
    prompt("Your final total is #{@player.hand_value} and " \
           "#{@dealer}'s is #{@dealer.hand_value}")
  end

  def display_result(result, bust_threshold)
    case result
    when :player_bust then prompt("You're bust! #{@dealer} wins this round")
    when :dealer_bust then prompt("#{@dealer} is bust. You win this round!")
    when :player_higher then prompt("You're closer to #{bust_threshold}. " \
                                    "You win this round!")
    when :dealer_higher then prompt("#{@dealer} is closer to " \
                                    "#{bust_threshold}. They win this round!")
    when :tie then prompt("You and #{@dealer} have the same score. It's a tie!")
    end
  end

  def display_score
    prompt("Current score: #{@player} #{@player.score} - " \
           "#{@dealer} - #{@dealer.score}")
  end

  def display_game_winner(winner_name, winning_score)
    case winner_name
    when @player.name then prompt("You reached #{winning_score}" \
                                  "rounds first. Congratulations!")
    when @dealer.name then prompt("#{@dealer} reached " \
                                  "#{winning_score} rounds first. Unlucky!")
    end
  end

  def display_goodbye_message(game)
    prompt("Thanks for playing #{game}!")
  end

  def clear
    system "clear"
  end
end

class Deck
  DECK_SUITS = ['Spades', 'Hearts', 'Clubs', 'Diamonds']
  FACE_CARDS = ['Jack', 'Queen', 'King']
  FACE_CARD_VALUE = 10
  ACE_VALUES = [1, 11]

  attr_reader :cards

  def initialize
    @cards = DECK_SUITS.each_with_object([]) do |suit, cards|
      add_numeric_cards(suit, cards)
      add_face_cards(suit, cards)
      add_ace(suit, cards)
    end

    cards.shuffle!
  end

  def deal_cards(number_to_deal)
    number_to_deal == 1 ? cards.pop : cards.pop(number_to_deal)
  end

  private

  def add_numeric_cards(suit, cards)
    (2..10).each do |num|
      cards.push(Card.new(num.to_s, suit, num))
    end
  end

  def add_face_cards(suit, cards)
    FACE_CARDS.each do |face|
      cards.push(Card.new(face, suit, FACE_CARD_VALUE))
    end
  end

  def add_ace(suit, cards)
    cards.push(Card.new('Ace', suit, ACE_VALUES))
  end
end

class Card
  attr_reader :rank, :value, :suit

  def initialize(rank, suit, value)
    @rank = rank
    @suit = suit
    @value = value
  end
end

class Participant
  include Displayable
  attr_accessor :hand, :score
  attr_reader :name, :choice, :hand_value

  def initialize
    @hand = []
    @score = 0
  end

  def to_s
    name
  end

  def show_hand
    display_all_cards
    calculate_hand_value
    display_hand_value
  end

  def hit(card)
    @hand.push(card)
  end

  def busted?(bust_threshold)
    @hand_value > bust_threshold
  end

  private

  def display_all_cards
    cards = hand.map { |card| "#{card.rank} of #{card.suit}" }
    prompt("#{name}'s hand:")
    cards.each { |card| puts "   - #{card}" }
  end

  def calculate_hand_value
    ace_cards, non_ace_cards = hand.partition { |card| card.rank == 'Ace' }

    non_ace_value = non_ace_cards.reduce(0) { |sum, card| sum + card.value }
    @hand_value = non_ace_value + calculate_aces_value(ace_cards, non_ace_value)
  end

  def calculate_aces_value(ace_cards, non_ace_value)
    ace_sum = 0

    ace_cards.each_with_index do |ace, index|
      ace_sum += if ace_sum + non_ace_value > 10 || index + 1 < ace_cards.length
                   ace.value[0]
                 else
                   ace.value[1]
                 end
    end

    ace_sum
  end

  def display_hand_value
    prompt("#{name}'s hand's total value is #{@hand_value} ")
  end
end

class Player < Participant
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

  def choose_move
    prompt("Would you like to hit or stay?")
    @choice = determine_player_choice
  end

  private

  def blank_string?(str)
    str.empty? || str.chars.uniq[0] == " "
  end

  def determine_player_choice
    loop do
      choice = gets.chomp

      if choice.downcase.start_with?('h')
        return 'hit'
      elsif choice.downcase.start_with?('s')
        return 'stay'
      end

      prompt('Invalid choice. Please try again')
    end
  end
end

class Dealer < Participant
  COMPUTER_NAMES = ['R2D2', 'Hal', 'Sonny', 'Marvin', 'Dolores', 'T-800'] +
                   ['Ava', 'VIKI', 'Bard', 'Sydney']
  STAY_LIMIT = 17

  def choose_name(opponent_name)
    name_choice = ""

    loop do
      name_choice = COMPUTER_NAMES.sample
      break unless name_choice == opponent_name
    end

    @name = name_choice
  end

  def show_one_card
    card = hand[0]
    prompt("#{name}'s hand:")
    puts "   - #{card.rank} of #{card.suit}"
    puts "   - an unknown card"
    calculate_hand_value
  end

  def stay?
    @hand_value >= STAY_LIMIT
  end
end

class Game
  include Displayable
  BUST_THRESHOLD = 21
  WINNING_SCORE = 5
  STARTING_CARDS = 2

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    setup_game
    play_game
    display_goodbye_message(BUST_THRESHOLD)
  end

  private

  def setup_game
    clear
    display_welcome_message(BUST_THRESHOLD, WINNING_SCORE)
    choose_names
  end

  def choose_names
    @player.choose_name
    @dealer.choose_name(@player.name)
  end

  def play_game
    loop do
      play_round

      if game_over?
        determine_game_winner
        break unless play_again?
        start_new_game
      else
        start_new_round
      end
    end
  end

  def play_round
    deal_initial_cards
    show_game_state
    player_turn
    dealer_turn unless @player.busted?(BUST_THRESHOLD)
    end_round
  end

  def deal_initial_cards
    prompt("Dealing first cards...")
    sleep(1.5)
    @dealer.hand = @deck.deal_cards(STARTING_CARDS)
    @player.hand = @deck.deal_cards(STARTING_CARDS)
  end

  def show_game_state(reveal_dealer_hand: false)
    clear
    display_score
    @player.show_hand
    reveal_dealer_hand ? @dealer.show_hand : @dealer.show_one_card
    puts "-------------------------------------------------------"
  end

  def player_turn
    loop do
      @player.choose_move
      break if @player.choice == 'stay'

      deal_player_card
      break if @player.busted?(BUST_THRESHOLD)
    end
  end

  def deal_player_card
    prompt('Dealing you one more card...')
    sleep(1.5)
    card = @deck.deal_cards(1)
    @player.hit(card)

    show_game_state
    prompt("You drew #{card.rank} of #{card.suit}. " \
           "Your hand value is now #{@player.hand_value}")
  end

  def dealer_turn
    prompt("#{@dealer}'s turn")
    sleep(1)
    show_game_state(reveal_dealer_hand: true)

    loop do
      sleep(2)
      break if @dealer.stay?
      deal_dealer_card
    end
  end

  def deal_dealer_card
    prompt("#{@dealer} hits...")
    sleep(1.5)
    card = @deck.deal_cards(1)
    @dealer.hit(card)

    show_game_state(reveal_dealer_hand: true)
    prompt("#{@dealer} drew #{card.rank} of #{card.suit}. " \
           "#{@dealer}'s hand value is now #{@dealer.hand_value}")
  end

  def end_round
    display_totals
    sleep(2)
    result = determine_result
    display_result(result, BUST_THRESHOLD)
    update_scores(result)
    sleep(2)
  end

  def determine_result
    if @player.busted?(BUST_THRESHOLD)
      :player_bust
    elsif @dealer.busted?(BUST_THRESHOLD)
      :dealer_bust
    else
      highest_value
    end
  end

  def highest_value
    if @player.hand_value > @dealer.hand_value
      :player_higher
    elsif @player.hand_value < @dealer.hand_value
      :dealer_higher
    else
      :tie
    end
  end

  def update_scores(result)
    if result == :player_higher || result == :dealer_bust
      @player.score += 1
    elsif result == :dealer_higher || result == :player_bust
      @dealer.score += 1
    end
  end

  def game_over?
    @player.score == WINNING_SCORE || @dealer.score == WINNING_SCORE
  end

  def determine_game_winner
    if @player.score > @dealer.score
      winner_name = @player.name
    elsif @player.score < @dealer.score
      winner_name = @dealer.name
    end

    display_game_winner(winner_name, WINNING_SCORE)
  end

  def play_again?
    prompt("Do you want to play again? (Press 'Y' to confirm)")
    repeat_choice = gets.chomp
    repeat_choice.downcase.start_with?('y')
  end

  def start_new_game
    prompt("Let's play again...")
    reset_scores
    reset_cards
    sleep(2)
    clear
  end

  def reset_scores
    @player.score = 0
    @dealer.score = 0
  end

  def reset_cards
    @deck = Deck.new
    @player.hand = []
    @dealer.hand = []
  end

  def start_new_round
    prompt("Starting a new round...")
    reset_cards
    sleep(2)
    clear
  end
end

Game.new.start
