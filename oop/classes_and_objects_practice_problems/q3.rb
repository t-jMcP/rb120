class Person
  attr_accessor :first_name, :last_name

  def initialize(name)
    update_names(name)
  end

  def name
    "#{@first_name} #{@last_name}".strip
  end

  def name=(name)
    update_names(name)
  end

  def update_names(full_name)
    names = full_name.split
    self.first_name = names.first
    self.last_name = names.length > 1 ? names.last : ''
  end
end

bob = Person.new('Robert')
puts bob.name                  # => 'Robert'
puts bob.first_name            # => 'Robert'
puts bob.last_name             # => ''
bob.last_name = 'Smith'
puts bob.name                  # => 'Robert Smith'

bob.name = "John Adams"
puts bob.first_name            # => 'John'
puts bob.last_name             # => 'Adams'
