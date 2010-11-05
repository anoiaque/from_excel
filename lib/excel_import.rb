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
    
    attr_accessor :map, :has_one_associations
    
    def initialize sheet, map, bounds
      @map = map
      @sheet = sheet
      @bounds = bounds 
      @map ? indexation : default
      @has_one_associations = extract_has_one_associations
    end
    
    def extract_has_one_associations
      @map.inject({}) do |associations, (attribute, index)|
        next(associations) unless attribute.is_a?(Array)
        association = attribute.first
        next(associations) if associations.has_key?(association)
        associations.merge({association => klass_of(association)})
      end
    end
    
    def attributes_of association
      @map.select {|attribute,| attribute.is_a?(Array) && attribute.first == association}
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
    
    private
    
    def klass_of attribute
      attribute.to_s.camelize.constantize 
    end
 
  end
 
  class Integrator
    
    def initialize sheet, klass, options
      @sheet = sheet
      @klass = klass
      @bounds = Bounds.new(sheet, options)
      @rules = options[:rules]
      @mapping = Mapping.new(sheet, options[:mapping], @bounds)
    end
    
    def cell_value_with_rule row_index, column_index
      @sheet.cell(row_index, column_index)
    end
    
    def primary_attributes_hash row_index
      @mapping.map.select{|attribute,| attribute.is_a? Symbol}.inject({}) do |hash, (attribute, index)|
        hash[attribute] = cell_value_with_rule(row_index, index)
        hash
      end
    end
    
    def object_from_columns_for_association association, row_index, klass
      attributes = @mapping.attributes_of(association)
      attributes.inject(klass.new) do |object, ((association, attribute), index)|
        p association
        p attribute
        p index
        association_attribute = attribute
        object.send(association_attribute.to_s + '=', cell_value_with_rule(row_index, @mapping.map[attribute]))
        object
      end
    end
    
    def has_one_associations_attributes_hash row_index
      @mapping.has_one_associations.inject({}) do |hash, (association, klass)|
        hash[association] = object_from_columns_for_association(association, row_index, klass)
        hash
      end
    end
    
    def row_to_hash row_index
      hash = primary_attributes_hash(row_index)
      hash.merge(has_one_associations_attributes_hash row_index)
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