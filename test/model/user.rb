class User
  include ExcelImport
  attr_accessor :first_name, :last_name, :age, :adress, :role
  
  def initialize args={}
    @first_name = args[:first_name]
    @last_name = args[:last_name]
    @age = args[:age]
    @adress = args[:adress]
    @role = args[:role]
  end
  
  def ==(other)
    first_name == other.first_name &&
    last_name == other.last_name &&
    age == other.age &&
    adress == other.adress &&
    role == other.role
  end
  
end