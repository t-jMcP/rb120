module Moveable
  attr_accessor :speed, :heading
  attr_reader :range

  def calculate_range(fuel_capacity, fuel_efficiency)
    fuel_capacity * fuel_efficiency
  end
end

class WheeledVehicle
  include Moveable

  def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
    @tires = tire_array
    @range = calculate_range(km_traveled_per_liter, liters_of_fuel_capacity)
  end

  def tire_pressure(tire_index)
    @tires[tire_index]
  end

  def inflate_tire(tire_index, pressure)
    @tires[tire_index] = pressure
  end
end

class Auto < WheeledVehicle
  def initialize
    # 4 tires are various tire pressures
    super([30,30,32,32], 50, 25.0)
  end
end

class Motorcycle < WheeledVehicle
  def initialize
    # 2 tires are various tire pressures
    super([20,20], 80, 8.0)
  end
end

class Boat
  include Moveable
  attr_reader :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    @propeller_count = num_propellers
    @hull_count = num_hulls
    @range = calculate_range(km_traveled_per_liter, liters_of_fuel_capacity)
  end
end

class Catamaran < Boat
end

class Motorboat < Boat
  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    super(1, 1, km_traveled_per_liter, liters_of_fuel_capacity)
  end
end

my_catamaran = Catamaran.new(2, 2, 30, 10.0)
puts "Catamaran details:"
puts my_catamaran.range
puts my_catamaran.propeller_count
puts my_catamaran.hull_count

my_motorboat = Motorboat.new(50, 7.0)
puts "Motorboat details:"
puts my_motorboat.range
puts my_motorboat.propeller_count
puts my_motorboat.hull_count
