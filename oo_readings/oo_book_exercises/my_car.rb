module Towable
  def can_tow?(pounds)
    pounds < 1500
  end
end  

class Vehicle
  attr_accessor :colour, :current_speed
  attr_reader :year, :model

  @@number_of_vehicles = 0

  def initialize(y, c, m)
    @year = y
    @colour = c
    @model = m
    @current_speed = 0
    
    @@number_of_vehicles += 1
  end

  def self.show_number_of_vehicles
    puts "Number of vehicles created: #{@@number_of_vehicles}"
  end  

  def speed_up(increase)
    self.current_speed += increase
    puts "Accelerating by #{increase}mph"
  end
  
  def break(decrease)
    self.current_speed -= decrease
    puts "Slowing down by #{decrease}mph"
  end
  
  def stop
    self.current_speed = 0
    puts "Stopping"
  end

  def self.calculate_mpg(miles, gallons)
    puts "Miles per gallon: #{miles / gallons}"
  end

  def spray_paint
    puts "Your vehicle is currently #{colour}. What colour would you like to change it to?"
    new_colour = gets.chomp
    puts "Ok, spray painting it #{new_colour}"
    self.colour = new_colour
  end

  def age
    "Your #{model} is #{years_old} years old"
  end
  
  private
  def years_old
    Time.now.year - self.year
  end
end  

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4
  
  def info
    "My car is a #{year} #{colour} #{model} and is currently doing #{current_speed}mph"
  end

  def to_s
    "My car is a #{colour} #{year} #{model}"
  end
end

class MyTruck < Vehicle
  include Towable
  NUMBER_OF_DOORS = 2

  def to_s
    "My truck is a #{colour} #{year} #{model}"
  end
end

Vehicle.show_number_of_vehicles

car = MyCar.new(2010, "blue", "Range Rover")
Vehicle.show_number_of_vehicles
puts car.model
puts car.info

car.speed_up(20)
car.break(10)
car.stop
puts car.info


car.spray_paint
puts car.colour

MyCar.calculate_mpg(500, 10)
puts car.age

puts car


truck = MyTruck.new(2015, "white", "Toyota")
puts truck
Vehicle.show_number_of_vehicles

puts truck.can_tow?(1000)
puts truck.can_tow?(10000)

puts MyCar.ancestors
