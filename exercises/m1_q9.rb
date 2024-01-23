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
    cards = SUITS.each_with_object([]) do |suit, arr|
      RANKS.each { |rank| arr << Card.new(rank, suit) }
    end

    cards.shuffle
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

deck = Deck.new
drawn = []
52.times { drawn << deck.draw }
p drawn.count { |card| card.rank == 5 } == 4
p drawn.count { |card| card.suit == 'Hearts' } == 13

drawn2 = []
52.times { drawn2 << deck.draw }
p drawn != drawn2 # Almost always.
