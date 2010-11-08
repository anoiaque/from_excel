require 'helper'

class TestFromExcel < Test::Unit::TestCase
  SIMPLE_SHEET= File.join(File.dirname(__FILE__), 'spreadsheets/simple_sheet.xls')
  SHEET_WITH_COLUMN_NAME_DIFFERENT_FROM_ATTRIBUTE = File.join(File.dirname(__FILE__), 'spreadsheets/sheet_with_column_name_different_from_attribute.xls')
  SHEET_WITHOUT_COLUMNS_NAMES =  File.join(File.dirname(__FILE__), 'spreadsheets/sheet_without_columns_names.xls')
  SHEET_WITH_START_END_COLUMNS_ROWS =  File.join(File.dirname(__FILE__), 'spreadsheets/sheet_with_start_end_columns_rows.xls')
  SHEET_WITH_COLUMNS_FROM_ASSOCIATION = File.join(File.dirname(__FILE__), 'spreadsheets/sheet_with_columns_from_association.xls')
  SHEET_WITH_COLUMN_VALUE_TO_ASSOCIATION_ID = File.join(File.dirname(__FILE__), 'spreadsheets/sheet_with_column_value_to_association_id.xls')

  def test_import_with_simple_sheet
    assert users = User.from_excel(File.new SIMPLE_SHEET)
    assert_equal sheet_users, users
  end
  
  def test_import_with_simple_sheet_with_some_attributes_mapped_with_columns_names
    sheet = File.new(SHEET_WITH_COLUMN_NAME_DIFFERENT_FROM_ATTRIBUTE)
    users = User.from_excel sheet, :mapping => {:first_name => 'Prenom'}
    assert_equal sheet_users, users
  end
  
  def test_should_be_able_to_import_with_attributes_mapped_with_columns_index
    sheet =  File.new(SHEET_WITHOUT_COLUMNS_NAMES)
    users = User.from_excel sheet,  :mapping => {:first_name => 1, :last_name => 2, :age => 3},
                                    :limits => {:start => [2, 1]}
    assert_equal sheet_users, users
  end
  
  def test_should_be_able_to_import_simple_sheet_with_given_start_and_end_columns_and_rows
    assert users = User.from_excel(File.new(SHEET_WITH_START_END_COLUMNS_ROWS), :limits => {:start => [3, 3], :end => [5, 5] })
    assert_equal sheet_users, users
  end
  
  def test_should_import_columns_on_associations_attributes_with_mapping_on_columns_names
    sheet =  File.new(SHEET_WITH_COLUMNS_FROM_ASSOCIATION)
    mapping = {[:adress, :street] => 'Street', [:adress, :town] => 'Town', [:adress, :zip_code] => 'Zip Code'}
    users = User.from_excel sheet, :mapping => mapping

    assert_equal users_with_adresses, users
  end
  
  def test_should_be_able_to_apply_rule_on_column_cells_to_transform_data_from_sheet_to_object_attribute_value
    sheet =  File.new(SHEET_WITH_COLUMN_VALUE_TO_ASSOCIATION_ID)
    mapping = {[:role, :id] => 'Rôle'}
    rules = {[:role, :id] => rule_to_retrieve_id}
    users = User.from_excel sheet, :mapping => mapping, :rules => rules
    
    assert_equal users_with_role, users
  end
  
  private
  
  def rule_to_retrieve_id
    lambda do |cell_value|
      case cell_value
      when 'Admin' then 1
      when 'Reader' then 2
      end
    end
  end
  
  def sheet_users
   [User.new(:first_name => 'Albert', :last_name =>	'Einstein', :age => 131),
    User.new(:first_name => 'Leonard', :last_name =>	'De Vinci', :age => 558),
    User.new(:first_name => 'Martin', :last_name =>	'Heidegger', :age => 121)]
  end
  
  def users_with_adresses
    adresses = [ Adress.new(:street => '17 rue de Brest', :town => 'Quimper', :zip_code => 29000),
                 Adress.new(:street => '26 rue des Lilas', :town => 'Paris', :zip_code => 75017),
                 Adress.new(:street => '13 rue du port', :town => 'Vannes', :zip_code => 56000)]
    users = sheet_users             
    users.each_with_index {|user, index| user.adress = adresses[index]}
    users
  end
  
  def users_with_role
    [ User.new(:first_name => 'Bobby', :last_name =>	'Lapointe', :role => Role.new(:id => 1)),
      User.new(:first_name => 'Gaston', :last_name =>	'Lagaffe', :role => Role.new(:id => 2)) ]
  end
  
  
  
end
