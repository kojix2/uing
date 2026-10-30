require "../spec_helper"

module SpecSupport
  class LifetimeSafetyModel < UIng::Table::Model
    getter? native_freed = false

    def initialize
      super(Pointer(UIng::LibUI::TableModel).null)
    end

    def tracked_table_count : Int32
      @tables.size
    end

    protected def free_native : Nil
      @native_freed = true
    end
  end

  class TableSchemaModel < UIng::Table::Model
    def initialize(column_types : Array(UIng::Table::Value::Type))
      super(Pointer(UIng::LibUI::TableModel).null)
      @column_types = column_types
    end

    def validate_data(column : Int32, type : UIng::Table::Value::Type, role : String = "data") : Nil
      validate_data_column(column, type, role)
    end

    def validate_state(column : Int32) : Nil
      validate_state_column(column, "state")
    end

    def validate_color(column : Int32) : Nil
      validate_optional_color_column(column, "color")
    end
  end
end
