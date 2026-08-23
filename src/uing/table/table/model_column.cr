module UIng
  class Table < Control
    # Special values used where libui-ng accepts a model column that controls
    # whether a table cell is editable or clickable.
    enum ModelColumn
      Never  = -1
      Always = -2
    end
  end
end
