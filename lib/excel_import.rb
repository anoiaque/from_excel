module ExcelImport
  
  class Bounds
    DEFAULT_OFFSET_FROM_TITLE = 1
    
    attr_accessor :first_row, :last_row, :first_column, :last_column, :offset_from_title
    
    def initialize sheet, options={} 
      @options = options
      @offset_from_title = title_offset
      bounds(sheet)
    end
    
    def bounds sheet
      limits = @options[:limits] || limits_from(sheet)
      @first_column =  limits[:start] ? limits[:start][1] : sheet.first_column 
      @first_row = limits[:start] ? limits[:start][0] : sheet.first_row + offset_from_title
      @last_column = limits[:end] ? limits[:end][1] : sheet.last_column
      @last_row = limits[:end] ? limits[:end][0] : sheet.last_row
    end
    
    def limits_from sheet
      {:start => [sheet.first_row + offset_from_title, sheet.first_column], :end => [sheet.last_row, sheet.last_column]}
    end
    
    def title_offset
      @options[:title] = true if @options[:title].nil?
      @options[:title] ?  @options[:offset_from_title] || DEFAULT_OFFSET_FROM_TITLE : 0
    end
    
  end
  
  class Mapping
    
    def initialize sheet, map, bounds
      @map = map
      @sheet = sheet
      @bounds = bounds 
      @map ? indexation : default
    end
    
    def indexation
      return self if @map.all? {|key, value| value.is_a?(Integer)}
      @bounds.first_column.upto(@bounds.last_column) do |index|
        @map[attribute column_name_at(index)] = index
      end
      self
    end
    
    def default
      @map = {}
      @bounds.first_column.upto(@bounds.last_column) do |index|
        @map[Mapping.default_attribute_for column_name_at(index)] = index
      end
    end
    
    def attribute column
      @map.each_pair {|key, value| return key if value == column}
      Mapping.default_attribute_for(column)
    end
    
    def column_name_at column_index
        @sheet.cell(@bounds.first_row - @bounds.offset_from_title, column_index)
     end
    
    def self.default_attribute_for column_name
      column_name.downcase.gsub(' ', '_').to_sym
    end
 
  end
 
  class Integrator
    
    def initialize sheet, klass, options
      @sheet = sheet
      @klass = klass
      @bounds = Bounds.new(sheet, options)
      @mapping = Mapping.new(sheet, options[:mapping], @bounds)
    end

    def row_to_hash row_index
      @bounds.first_column.upto(@bounds.last_column).inject({}) do |hash, column_index|
        attribute =  @mapping.attribute(column_index)
        hash[attribute] = @sheet.cell(row_index, column_index)
        hash
      end
    end
    
    def rows_to_objects
     @bounds.first_row.upto(@bounds.last_row).inject([]) {|objects, row_index| objects << @klass.new(row_to_hash(row_index)); objects}
    end
    
  end
  
  def self.included(base)
    class << base
      def from_excel spreadsheet, opt={}
        integrator = Integrator.new(Excel.new(spreadsheet.path), self, opt)
        integrator.rows_to_objects
      end
    end
  end
  
end