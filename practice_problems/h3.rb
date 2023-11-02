class Vehicle
  attr_accessor :speed, :heading
  attr_reader :range

  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    @range = calculate_range(km_traveled_per_liter, liters_of_fuel_capacity)
  end  

  def calculate_range(km_traveled_per_liter, liters_of_fuel_capacity)
    km_traveled_per_liter * liters_of_fuel_capacity
  end
end

class WheeledVehicle < Vehicle
  def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
    super(km_traveled_per_liter, liters_of_fuel_capacity)
    @tires = tire_array
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

class Boat < Vehicle
  attr_reader :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    @range = calculate_range(km_traveled_per_liter, liters_of_fuel_capacity)
    @propeller_count = num_propellers
    @hull_count = num_hulls
  end

  def calculate_range(km_traveled_per_liter, liters_of_fuel_capacity)
    super + 10
  end  
end

class Catamaran < Boat
end

class Motorboat < Boat
  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    super(1, 1, km_traveled_per_liter, liters_of_fuel_capacity)
  end
end

my_catamaran = Catamaran.new(2, 2, 50, 25.0)
puts my_catamaran.range

my_car = Auto.new
puts my_car.range
