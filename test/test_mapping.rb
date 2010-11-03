require 'helper'

class TestMapping < Test::Unit::TestCase
  
  def test_mapping_should_return_default_attribute_name
    mapping = ExcelImport::Mapping.new({:first_name => 'First Name'})
    assert_equal :first_name, mapping.attribute_for('First Name')
    assert_equal :last_name, mapping.attribute_for('Last Name')
  end
end