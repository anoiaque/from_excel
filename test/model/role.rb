class Role
  attr_accessor :id, :title
  
  def initialize args={}
    @id = args[:id]
    @name = args[:title]
  end
  
  def ==(other)
    id == other.id
  end
  
end