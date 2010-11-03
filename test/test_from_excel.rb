require 'helper'

class TestFromExcel < Test::Unit::TestCase
  SIMPLE_SHEET= File.join(File.dirname(__FILE__), 'spreadsheets/simple_sheet.xls')
  SHEET_WITH_COLUMN_NAME_DIFFERENT_FROM_ATTRIBUTE = File.join(File.dirname(__FILE__), 'spreadsheets/sheet_with_column_name_different_from_attribute.xls')
  SHEET_WITHOUT_COLUMNS_NAMES =  File.join(File.dirname(__FILE__), 'spreadsheets/sheet_without_columns_names.xls')
  SHEET_WITH_START_END_COLUMNS_ROWS =  File.join(File.dirname(__FILE__), 'spreadsheets/sheet_with_start_end_columns_rows.xls')
 
  def test_import_with_simple_sheet
    assert users = User.from_excel(File.new SIMPLE_SHEET)
    assert_equal simple_sheet_users, users
  end
  
  def test_import_with_simple_sheet_with_some_attributes_mapped_with_columns_names
    sheet = File.new(SHEET_WITH_COLUMN_NAME_DIFFERENT_FROM_ATTRIBUTE)
    users = User.from_excel sheet, :mapping => {:first_name => 'Prenom'}
    assert_equal simple_sheet_users, users
  end
  
  def test_import_with_simple_sheet_with_attributes_mapped_with_columns_index
    sheet =  File.new(SHEET_WITHOUT_COLUMNS_NAMES)
    users = User.from_excel sheet, :mapping => {:first_name => 1, :last_name => 2, :age => 3},
                                    :limits => {:start => [2, 1]}
    assert_equal simple_sheet_users, users
  end
  
  def test_import_with_simple_sheet_with_giving_start_and_end_columns_and_rows
    assert users = User.from_excel(File.new(SHEET_WITH_START_END_COLUMNS_ROWS), :limits => {:start => [3, 3], :end => [5, 5] })
    assert_equal simple_sheet_users, users
  end
  
  private
  
  def simple_sheet_users
   [User.new(:first_name => 'Albert', :last_name =>	'Einstein', :age => 131),
    User.new(:first_name => 'Leonard', :last_name =>	'De Vinci', :age => 558),
    User.new(:first_name => 'Martin', :last_name =>	'Heidegger', :age => 121)]
  end
  
end
