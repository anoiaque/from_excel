require 'helper'

class TestMapping < Test::Unit::TestCase
  
  def test_mapping_should_make_default_attribute_name_from_columns_title
    sheet = stubbed_sheet
    bounds = ExcelImport::Bounds.new(sheet)
    mapping = ExcelImport::Mapping.new(sheet, {}, bounds )

    assert_equal :first_name, mapping.attribute('First Name')
    assert_equal :last_name, mapping.attribute('Last Name')
  end
  
  def test_mapping_should__attribute_name
    sheet = stubbed_sheet
    bounds = ExcelImport::Bounds.new(sheet)
    mapping = ExcelImport::Mapping.new(sheet, {:name => 'First Name'}, bounds )

    assert_equal :name, mapping.attribute(1)
  end
  
  def test_should_handle_association_attributes
    sheet = stubbed_sheet_with_adress_columns
    mapping = {[:adress, :street] => 'Street', [:adress, :town] => 'Town'}
    bounds = ExcelImport::Bounds.new(sheet)
    mapping = ExcelImport::Mapping.new(sheet, mapping, bounds )

    assert_equal [:adress, :street], mapping.attribute(4)
    assert_equal [:adress, :town], mapping.attribute(5)
    assert_equal 5, mapping.map[[:adress, :town]]
    assert_equal ({:adress => Adress}), mapping.has_one_associations
    
  end
  
  private
  
  def stubbed_sheet
    sheet = stub(:first_column => 1, :last_column => 3, :first_row => 1, :last_row => 2)
    sheet.stubs(:cell).with(1,1).returns('First Name')
    sheet.stubs(:cell).with(1,2).returns('Last Name')
    sheet.stubs(:cell).with(1,3).returns('Age')
    sheet
  end
  
  def stubbed_sheet_with_adress_columns
    sheet = stub(:first_column => 1, :last_column => 5, :first_row => 1, :last_row => 2)
    sheet.stubs(:cell).with(1,1).returns('First Name')
    sheet.stubs(:cell).with(1,2).returns('Last Name')
    sheet.stubs(:cell).with(1,3).returns('Age')
    sheet.stubs(:cell).with(1,4).returns('Street')
    sheet.stubs(:cell).with(1,5).returns('Town')
    sheet
  end
  
end