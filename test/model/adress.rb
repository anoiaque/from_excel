class Adress
  attr_accessor :street, :town, :zip_code
  
  def initialize args={}
    @street = args[:street]
    @town = args[:town]
    @zip_code = args[:zip_code]
  end
  
  def ==(other)
    return false unless other
    street == other.street &&
    town == other.town &&
    zip_code == other.zip_code
  end
  
end