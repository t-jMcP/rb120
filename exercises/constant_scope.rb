WHEELS = 6

class Car < Vehicle
  def wheels
    WHEELS
  end  
end

puts Car.new.wheels
