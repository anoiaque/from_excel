require 'helper'

class TestBounds < Test::Unit::TestCase
  
  
  def test_default_bounds
    sheet = stubbed_sheet_with_bounds
    bounds = ExcelImport::Bounds.new(sheet)
    assert_equal 1, bounds.first_column
    assert_equal 10, bounds.last_column
    assert_equal 2, bounds.first_row #have a title line by default so first row is after title line
    assert_equal 10, bounds.last_row
  end
  
  def test_bounds_with_limits_changed
    sheet = stub
    bounds = ExcelImport::Bounds.new(sheet, :limits => {:start => [3, 4], :end => [5, 20]})
    assert_equal 4, bounds.first_column
    assert_equal 20, bounds.last_column
    assert_equal 3, bounds.first_row
    assert_equal 5, bounds.last_row
  end
  
  def test_bounds_without_title_for_columns
    sheet = stubbed_sheet_with_bounds
    bounds = ExcelImport::Bounds.new(sheet, :title => false)
    assert_equal 1, bounds.first_column
    assert_equal 10, bounds.last_column
    assert_equal 1, bounds.first_row # No title so first row is the first row of sheet
    assert_equal 10, bounds.last_row
  end
  
  def test_bounds_with_only_start_key_should_take_sheet_end_cell_coordinates
    sheet = stubbed_sheet_with_bounds
    bounds = ExcelImport::Bounds.new(sheet, :limits => {:start => [3, 4]})
    assert_equal 4, bounds.first_column
    assert_equal 10, bounds.last_column
    assert_equal 3, bounds.first_row
    assert_equal 10, bounds.last_row
  end
  
  def test_bounds_with_only_end_key_should_take_sheet_start_cell_coordinates_with_1_added_to_first_row_if_title
    sheet = stubbed_sheet_with_bounds
    bounds = ExcelImport::Bounds.new(sheet, :limits => {:end => [10, 5]})
    assert_equal 1, bounds.first_column
    assert_equal 5, bounds.last_column
    assert_equal 2, bounds.first_row
    assert_equal 10, bounds.last_row
  end
  
  def test_bounds_with_offset_from_title
    sheet = stubbed_sheet_with_bounds
    bounds = ExcelImport::Bounds.new(sheet, :offset_from_title => 4)
    assert_equal 1, bounds.first_column
    assert_equal 10, bounds.last_column
    assert_equal 5, bounds.first_row
    assert_equal 10, bounds.last_row
  end
  
  
  
  private
  
  def stubbed_sheet_with_bounds
    stub(:first_column => 1, :last_column => 10, :first_row => 1, :last_row => 10)
  end
  
end