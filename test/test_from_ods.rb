require 'helper'

class TestFromExcel < Test::Unit::TestCase
  SIMPLE_SHEET= File.join(File.dirname(__FILE__), 'spreadsheets/simple_sheet.ods')

  def test_import_with_simple_sheet
    assert users = User.from_ooo(File.new SIMPLE_SHEET)
    assert_equal sheet_users, users
  end
  
end
