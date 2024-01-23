class Deck
  RANKS = ((2..10).to_a + %w(Jack Queen King Ace)).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  def initialize
    @cards = new_cards
  end

  def draw
    @cards = new_cards if @cards.empty?
    @cards.pop
  end

  private
  
  def new_cards
    new_cards = SUITS.each_with_object([]) do |suit, arr|
      RANKS.each { |rank| arr << Card.new(rank, suit) }
    end

    new_cards.shuffle
  end
end

class Card
  attr_reader :rank, :suit

  FACE_CARD_VALUES = { 'Jack' => 11, 'Queen' => 12, 'King' => 13, 'Ace' => 14 }

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def value
    calculate_value(rank)
  end  

  def <=>(other_card)
    value = calculate_value(rank)
    other_card_value = calculate_value(other_card.rank)

    value <=> other_card_value
  end

  def ==(other_card)
    @rank == other_card.rank && @suit == other_card.suit
  end

  private

  def calculate_value(rank)
    if rank.to_s.to_i == rank
      rank
    else
      FACE_CARD_VALUES[rank]
    end
  end
end

class PokerHand
  def initialize(deck)
    @deck = deck
    @hand = deal_cards(5)
    @rank_counts = count_ranks
  end

  def print
    puts @hand
  end

  def evaluate
    case
    when royal_flush?     then 'Royal flush'
    when straight_flush?  then 'Straight flush'
    when four_of_a_kind?  then 'Four of a kind'
    when full_house?      then 'Full house'
    when flush?           then 'Flush'
    when straight?        then 'Straight'
    when three_of_a_kind? then 'Three of a kind'
    when two_pair?        then 'Two pair'
    when pair?            then 'Pair'
    else                       'High card'
    end
  end

  private

  def deal_cards(hand_size)
    hand = []
    hand_size.times { hand << @deck.draw }
    hand
  end

  def royal_flush?
    straight_flush? && lowest_card == 10
  end

  def straight_flush?
    flush? && straight?
  end

  def four_of_a_kind?
    @rank_counts.max >= 4
  end

  def full_house?
    @rank_counts.include?(2) && @rank_counts.include?(3)
  end

  def flush?
    @hand.all? { |card| card.suit == @hand[0].suit }
  end

  def straight?
    values = card_values

    values.each_with_index do |value, index|
      next if index == 0
      return false unless (value - values[index - 1]) == 1
    end

    true
  end

  def three_of_a_kind?
    @rank_counts.max >= 3
  end

  def two_pair?
    @rank_counts.count(2) >= 4
  end

  def pair?
    @rank_counts.max >= 2
  end

  def lowest_card
    values = card_values
    values[0]
  end

  def card_values
    @hand.map { |card| card.value }.sort
  end

  def count_ranks
    @hand.map do |first_card|
      @hand.count { |second_card| first_card.rank == second_card.rank }
    end
  end
end

hand = PokerHand.new(Deck.new)
hand.print
puts hand.evaluate

# Danger danger danger: monkey
# patching for testing purposes.
class Array
  alias_method :draw, :pop
end

# Test that we can identify each PokerHand type.
hand = PokerHand.new([
  Card.new(10,      'Hearts'),
  Card.new('Ace',   'Hearts'),
  Card.new('Queen', 'Hearts'),
  Card.new('King',  'Hearts'),
  Card.new('Jack',  'Hearts')
])
puts hand.evaluate == 'Royal flush'

hand = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Clubs'),
  Card.new('Queen', 'Clubs'),
  Card.new(10,      'Clubs'),
  Card.new('Jack',  'Clubs')
])
puts hand.evaluate == 'Straight flush'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(3, 'Diamonds')
])
puts hand.evaluate == 'Four of a kind'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(5, 'Hearts')
])
puts hand.evaluate == 'Full house'

hand = PokerHand.new([
  Card.new(10, 'Hearts'),
  Card.new('Ace', 'Hearts'),
  Card.new(2, 'Hearts'),
  Card.new('King', 'Hearts'),
  Card.new(3, 'Hearts')
])
puts hand.evaluate == 'Flush'

hand = PokerHand.new([
  Card.new(8,      'Clubs'),
  Card.new(9,      'Diamonds'),
  Card.new(10,     'Clubs'),
  Card.new(7,      'Hearts'),
  Card.new('Jack', 'Clubs')
])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
  Card.new('Queen', 'Clubs'),
  Card.new('King',  'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new('Ace',   'Hearts'),
  Card.new('Jack',  'Clubs')
])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(6, 'Diamonds')
])
puts hand.evaluate == 'Three of a kind'

hand = PokerHand.new([
  Card.new(9, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(8, 'Spades'),
  Card.new(5, 'Hearts')
])
puts hand.evaluate == 'Two pair'

hand = PokerHand.new([
  Card.new(2, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(9, 'Spades'),
  Card.new(3, 'Diamonds')
])
puts hand.evaluate == 'Pair'

hand = PokerHand.new([
  Card.new(2,      'Hearts'),
  Card.new('King', 'Clubs'),
  Card.new(5,      'Diamonds'),
  Card.new(9,      'Spades'),
  Card.new(3,      'Diamonds')
])
puts hand.evaluate == 'High card'
