class Student
  attr_accessor :name

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    grade < other_student.grade
  end

  protected

  attr_reader :grade
end

joe = Student.new("Joe", "A")
puts "Student's name is #{joe.name}"

bob = Student.new("Bob", "C")
puts puts "Well done!" if joe.better_grade_than?(bob)

