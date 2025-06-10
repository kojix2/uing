require "../src/uing"

UIng.init

# Column constants
enum Column
  Avatar     = 0
  Name       = 1
  Age        = 2
  Department = 3
  Salary     = 4
  Progress   = 5
  Active     = 6
end

COLUMN_NAMES     = ["Avatar", "Name", "Age", "Department", "Salary", "Progress", "Active"]
SORTABLE_COLUMNS = [Column::Name, Column::Age, Column::Department, Column::Salary, Column::Active]

# Sample data structure for a more complex table
class Employee
  property name : String
  property age : Int32
  property department : String
  property salary : Int32
  property active : Bool
  property avatar : UIng::Image?
  property progress : Int32 # Progress value (0-100, or -1 for indeterminate)

  def initialize(@name : String, @age : Int32, @department : String, @salary : Int32, @active : Bool = true, @avatar : UIng::Image? = nil, @progress : Int32 = 0)
  end
end

# Create sample avatar images (simple colored rectangles)
def create_avatar_image(r : Float64, g : Float64, b : Float64) : UIng::Image
  width = 32
  height = 32
  image = UIng::Image.new(width, height)

  # Create a simple colored rectangle as avatar
  pixels = Bytes.new(width * height * 4) # RGBA
  (0...height).each do |y|
    (0...width).each do |x|
      offset = (y * width + x) * 4
      pixels[offset] = (r * 255).to_u8     # Red
      pixels[offset + 1] = (g * 255).to_u8 # Green
      pixels[offset + 2] = (b * 255).to_u8 # Blue
      pixels[offset + 3] = 255_u8          # Alpha
    end
  end

  image.append(pixels.to_unsafe, width, height, width * 4)
  image
end

# Create a default gray avatar for employees without avatars
DEFAULT_AVATAR = create_avatar_image(0.5, 0.5, 0.5)

# Global employee data (mutable for sorting)
EMPLOYEES = [
  Employee.new("Alice Johnson", 28, "Engineering", 75000, true, create_avatar_image(0.8, 0.2, 0.2), 85),
  Employee.new("Bob Smith", 35, "Marketing", 65000, true, create_avatar_image(0.2, 0.8, 0.2), 72),
  Employee.new("Carol Davis", 42, "Engineering", 85000, true, create_avatar_image(0.2, 0.2, 0.8), 95),
  Employee.new("David Wilson", 31, "Sales", 55000, true, create_avatar_image(0.8, 0.8, 0.2), 60),
  Employee.new("Eve Brown", 29, "HR", 60000, true, create_avatar_image(0.8, 0.2, 0.8), 45),
  Employee.new("Frank Miller", 38, "Engineering", 90000, true, create_avatar_image(0.2, 0.8, 0.8), 88),
  Employee.new("Grace Lee", 26, "Marketing", 58000, true, create_avatar_image(0.6, 0.4, 0.2), 30),
  Employee.new("Henry Taylor", 45, "Sales", 70000, true, create_avatar_image(0.4, 0.6, 0.8), 78),
  Employee.new("Ivy Chen", 33, "Engineering", 80000, true, create_avatar_image(0.8, 0.6, 0.4), 92),
  Employee.new("Jack Anderson", 27, "HR", 52000, true, create_avatar_image(0.4, 0.8, 0.6), -1), # Indeterminate progress
] of Employee

# Global sort state
SORT_COLUMN    = -1
SORT_ASCENDING = true

main_window = UIng::Window.new("Advanced Table Example", 800, 600)
main_window.margined = true

vbox = UIng::Box.new(:vertical)
vbox.padded = true
main_window.child = vbox

# Control panel
control_panel = UIng::Box.new(:horizontal)
control_panel.padded = true

# Add employee button
add_button = UIng::Button.new("Add Employee")
control_panel.append(add_button, false)

# Delete selected button
delete_button = UIng::Button.new("Delete Selected")
control_panel.append(delete_button, false)

# Toggle active status button
toggle_button = UIng::Button.new("Toggle Selected Active")
control_panel.append(toggle_button, false)

# Selection mode controls
selection_label = UIng::Label.new("Selection Mode:")
control_panel.append(selection_label, false)

single_radio = UIng::RadioButtons.new
single_radio.append("Single")
single_radio.append("Multiple")
single_radio.selected = 0
control_panel.append(single_radio, false)

vbox.append(control_panel, false)

# Status label
status_label = UIng::Label.new("Ready")
vbox.append(status_label, false)

# Create table model handler
model_handler = UIng::TableModelHandler.new do
  num_columns { |_, _| COLUMN_NAMES.size }

  column_type do |_, _, column|
    case Column.new(column)
    when .avatar?
      UIng::TableValueType::Image
    when .name?, .age?, .department?, .salary?
      UIng::TableValueType::String
    when .progress?
      UIng::TableValueType::Int
    when .active?
      UIng::TableValueType::Int
    else
      UIng::TableValueType::String
    end
  end

  num_rows { |_, _| EMPLOYEES.size }

  cell_value do |_, _, row, column|
    next UIng::TableValue.new("").to_unsafe if row >= EMPLOYEES.size

    employee = EMPLOYEES[row]
    value = case Column.new(column)
            when .avatar?
              avatar = employee.avatar || DEFAULT_AVATAR
              UIng::TableValue.new(avatar)
            when .name?
              UIng::TableValue.new(employee.name)
            when .age?
              UIng::TableValue.new(employee.age.to_s)
            when .department?
              UIng::TableValue.new(employee.department)
            when .salary?
              UIng::TableValue.new(employee.salary.to_s)
            when .progress?
              UIng::TableValue.new(employee.progress)
            when .active?
              UIng::TableValue.new(employee.active ? 1 : 0)
            else
              UIng::TableValue.new("")
            end
    value.to_unsafe
  end

  set_cell_value do |_, model_ptr, row, column, value|
    next if row >= EMPLOYEES.size

    table_value = UIng::TableValue.new(value, borrowed: true)

    case Column.new(column)
    when .avatar?, .progress?
      # Read-only columns
    when .name?
      if name = table_value.string
        EMPLOYEES[row].name = name
      end
    when .age?
      if age_str = table_value.string
        EMPLOYEES[row].age = age_str.to_i? || EMPLOYEES[row].age
      end
    when .department?
      if dept = table_value.string
        EMPLOYEES[row].department = dept
      end
    when .salary?
      if salary_str = table_value.string
        EMPLOYEES[row].salary = salary_str.to_i? || EMPLOYEES[row].salary
      end
    when .active?
      EMPLOYEES[row].active = table_value.int != 0
    end
  end
end

# Create table model and table
table_model = UIng::TableModel.new(model_handler)
table_params = UIng::TableParams.new(table_model)

table = UIng::Table.new(table_params) do
  # Add columns with different types
  append_image_column("Avatar", 0)          # Image column (read-only)
  append_text_column("Name", 1, 1)          # Editable text
  append_text_column("Age", 2, 2)           # Editable number (as text)
  append_text_column("Department", 3, 3)    # Editable text
  append_text_column("Salary", 4, 4)        # Editable number (as text)
  append_progress_bar_column("Progress", 5) # Progress bar (read-only)
  append_checkbox_column("Active", 6, 6)    # Editable checkbox
end

# Configure table
table.header_visible = true
table.selection_mode = UIng::TableSelectionMode::ZeroOrMany

vbox.append(table, true)

# Table event handlers
table.on_selection_changed do |selection|
  count = selection.num_rows
  if count == 0
    status_label.text = "No selection"
  elsif count == 1
    row = selection.rows[0]
    employee = EMPLOYEES[row]
    status_label.text = "Selected: #{employee.name} (#{employee.department})"
  else
    status_label.text = "Selected #{count} employees"
  end
end

table.on_row_clicked do |row|
  employee = EMPLOYEES[row]
  puts "Clicked: #{employee.name}"
end

table.on_row_double_clicked do |row|
  employee = EMPLOYEES[row]
  puts "Double-clicked: #{employee.name} - Salary: $#{employee.salary}"
end

table.on_header_clicked do |column|
  puts "Header clicked: #{COLUMN_NAMES[column]? || "Unknown"}"

  # Skip sorting for non-sortable columns
  column_enum = Column.new(column)
  next unless SORTABLE_COLUMNS.includes?(column_enum)

  # Clear previous sort indicators
  (0...7).each do |col|
    table.header_set_sort_indicator(col, UIng::SortIndicator::None) if col != column
  end

  # Determine new sort direction
  current = table.header_sort_indicator(column)
  ascending = case current
              when UIng::SortIndicator::None
                true
              when UIng::SortIndicator::Ascending
                false
              else
                true
              end

  # Sort the data
  case column_enum
  when .name?
    EMPLOYEES.sort! { |a, b| ascending ? a.name <=> b.name : b.name <=> a.name }
  when .age?
    EMPLOYEES.sort! { |a, b| ascending ? a.age <=> b.age : b.age <=> a.age }
  when .department?
    EMPLOYEES.sort! { |a, b| ascending ? a.department <=> b.department : b.department <=> a.department }
  when .salary?
    EMPLOYEES.sort! { |a, b| ascending ? a.salary <=> b.salary : b.salary <=> a.salary }
  when .active?
    EMPLOYEES.sort! { |a, b| ascending ? (a.active ? 1 : 0) <=> (b.active ? 1 : 0) : (b.active ? 1 : 0) <=> (a.active ? 1 : 0) }
  end

  # Update sort indicator
  new_indicator = ascending ? UIng::SortIndicator::Ascending : UIng::SortIndicator::Descending
  table.header_set_sort_indicator(column, new_indicator)

  # Refresh the entire table
  (0...EMPLOYEES.size).each do |row|
    table_model.row_changed(row)
  end

  status_label.text = "Sorted by #{COLUMN_NAMES[column]} (#{ascending ? "ascending" : "descending"})"
end

# Button event handlers
add_button.on_clicked do
  new_employee = Employee.new("New Employee", 25, "Unknown", 50000)
  EMPLOYEES << new_employee
  table_model.row_inserted(EMPLOYEES.size - 1)
  status_label.text = "Added new employee"
end

delete_button.on_clicked do
  selection = table.selection
  if selection.num_rows > 0
    # Delete in reverse order to maintain indices
    rows_to_delete = [] of Int32
    (0...selection.num_rows).each do |i|
      rows_to_delete << selection.rows[i]
    end
    rows_to_delete.sort!.reverse!

    rows_to_delete.each do |row|
      # Free avatar image before deleting the employee, but not if it's DEFAULT_AVATAR or nil
      if avatar = EMPLOYEES[row].avatar
        unless avatar.same?(DEFAULT_AVATAR)
          avatar.free
        end
      end
      EMPLOYEES.delete_at(row)
      table_model.row_deleted(row)
    end

    status_label.text = "Deleted #{rows_to_delete.size} employee(s)"
  else
    status_label.text = "No employees selected for deletion"
  end
  selection.free
end

toggle_button.on_clicked do
  selection = table.selection
  if selection.num_rows > 0
    (0...selection.num_rows).each do |i|
      row = selection.rows[i]
      if row < EMPLOYEES.size
        EMPLOYEES[row].active = !EMPLOYEES[row].active
        table_model.row_changed(row)
      end
    end
    status_label.text = "Toggled active status for #{selection.num_rows} employee(s)"
  else
    status_label.text = "No employees selected"
  end
  selection.free
end

# Selection mode change handler
single_radio.on_selected do
  mode = single_radio.selected == 0 ? UIng::TableSelectionMode::ZeroOrOne : UIng::TableSelectionMode::ZeroOrMany
  table.selection_mode = mode
  mode_name = single_radio.selected == 0 ? "Single" : "Multiple"
  status_label.text = "Selection mode changed to: #{mode_name}"
end

# Window event handlers
main_window.on_closing do
  puts "Cleaning up resources..."

  # Free all avatar images
  EMPLOYEES.each do |employee|
    if avatar = employee.avatar
      avatar.free
    end
  end

  # Free the default avatar
  DEFAULT_AVATAR.free

  table_model.free
  UIng.quit
  true
end

# Show window and start main loop
main_window.show

UIng.main
UIng.uninit
