require "../../src/uing"

enum Operation
  Add
  Subtract
  Multiply
  Divide

  def symbol
    case self
    when .add?      then "+"
    when .subtract? then "-"
    when .multiply? then "×"
    when .divide?   then "÷"
    end
  end

  def self.from_symbol(symbol : String) : Operation?
    case symbol
    when "+" then Add
    when "-" then Subtract
    when "×" then Multiply
    when "÷" then Divide
    else          nil
    end
  end
end

struct State
  property current_value : Float64 = 0.0
  property stored_value : Float64 = 0.0
  property operation : Operation? = nil
  property memory : Float64 = 0.0
  property waiting_for_operand : Bool = true
  property last_operation : Operation? = nil
  property last_operand : Float64 = 0.0

  def clear
    @current_value = 0.0
    @stored_value = 0.0
    @operation = nil
    @waiting_for_operand = true
    @last_operation = nil
    @last_operand = 0.0
    # Note: memory is intentionally preserved during clear
  end
end

class Calculator
  property state : State = State.new
  property display : UIng::Entry

  def initialize(@display : UIng::Entry)
  end

  # Safe arithmetic operations that return nil on error
  private def safe_sqrt(value : Float64) : Float64?
    return nil if value < 0
    Math.sqrt(value)
  end

  private def safe_operation(op : Operation, left : Float64, right : Float64) : Float64?
    result = case op
             when .add?      then left + right
             when .subtract? then left - right
             when .multiply? then left * right
             when .divide?   then right.zero? ? nil : left / right
             end

    result.try(&.finite?) ? result : nil
  end

  def input_digit(digit : String)
    if @state.waiting_for_operand || is_error_state?
      @display.text = digit
      @state.waiting_for_operand = false
    else
      current_text = @display.text || "0"
      @display.text = current_text == "0" ? digit : current_text + digit
    end
    @state.last_operation = nil
    @state.last_operand = 0.0
  end

  def input_dot
    if @state.waiting_for_operand || is_error_state?
      @display.text = "0."
      @state.waiting_for_operand = false
    else
      current_text = @display.text || "0"
      @display.text = current_text.includes?(".") ? current_text : current_text + "."
    end
    @state.last_operation = nil
    @state.last_operand = 0.0
  end

  def perform_operation(next_operation : String?)
    input_value = get_display_value

    if (op = @state.operation) && !@state.waiting_for_operand
      result = safe_operation(op, @state.stored_value, input_value)

      if result.nil?
        enter_error_state
        return
      end

      @display.text = format_result(result)
      @state.current_value = result
    else
      @state.current_value = input_value
    end

    @state.waiting_for_operand = true
    @state.operation = next_operation ? Operation.from_symbol(next_operation) : nil
    @state.stored_value = @state.current_value
    @state.last_operation = nil
    @state.last_operand = 0.0
  end

  def calculate
    lhs = get_display_value

    if op = @state.operation
      # If operator was just pressed, use stored_value as rhs
      rhs = @state.waiting_for_operand ? @state.stored_value : lhs

      result = safe_operation(op, @state.stored_value, rhs)

      if result.nil?
        enter_error_state
        return
      end

      @display.text = format_result(result)
      @state.last_operation = op # Store for = repeat
      @state.last_operand = rhs
      @state.operation = nil
      @state.stored_value = 0.0
      @state.waiting_for_operand = true
    elsif (last_op = @state.last_operation) && @state.waiting_for_operand
      # Repeat previous = operation (apply last_operand to lhs)
      result = safe_operation(last_op, lhs, @state.last_operand)

      if result.nil?
        enter_error_state
        return
      end

      @display.text = format_result(result)
      @state.waiting_for_operand = true
    end
  end

  def clear
    @state.clear
    @display.text = "0"
  end

  def plus_minus
    value = get_display_value
    @display.text = format_result(-value)
    @state.waiting_for_operand = false
  end

  def percent
    value = get_display_value
    result = @state.operation ? @state.stored_value * (value / 100.0) : value / 100.0
    @display.text = format_result(result)
    @state.waiting_for_operand = false
  end

  def square_root
    value = get_display_value
    result = safe_sqrt(value)

    if result.nil?
      enter_error_state
    else
      @display.text = format_result(result)
      @state.waiting_for_operand = false
    end
  end

  def memory_recall
    @display.text = format_result(@state.memory)
    @state.waiting_for_operand = false
  end

  def memory_add
    value = get_display_value
    @state.memory += value
    @state.waiting_for_operand = true
  end

  def memory_subtract
    value = get_display_value
    @state.memory -= value
    @state.waiting_for_operand = true
  end

  def memory_clear
    @state.memory = 0.0
  end

  private def is_error_state? : Bool
    @display.text == "Error"
  end

  private def get_display_value : Float64
    return 0.0 if is_error_state?
    text = @display.text
    return 0.0 if text.nil? || text.empty?
    text.to_f64? || 0.0
  end

  private def enter_error_state
    @display.text = "Error"
    @state.clear
  end

  # Helper methods for format_result
  private def nearly_integer?(value : Float64) : Bool
    (value % 1.0).abs < 1e-12
  end

  private def in_int64_range?(value : Float64) : Bool
    value >= Int64::MIN.to_f && value <= Int64::MAX.to_f
  end

  # Crystal-style method chaining with case expression
  private def format_result(value : Float64) : String
    return "Error" unless value.finite?

    if nearly_integer?(value)
      if in_int64_range?(value)
        value.trunc.to_i64.to_s # trunc avoids rounding up near MAX
      else
        "%.10g" % value # Use exponential notation for out-of-range values
      end
    else
      "%.10g" % value
    end
  end
end

# Button layout definition using NamedTuple for better structure
BUTTON_LAYOUT = {
  memory:     %w[MC MR M- M+ C],
  row2:       %w[7 8 9 % √],
  row3:       %w[4 5 6 × ÷],
  row4:       %w[1 2 3],
  row5:       %w[0 . +/- =],
  operations: %w[+ -],
}

# Explicit type definition for button actions
alias ButtonAction = Calculator ->

BUTTON_ACTIONS = Hash(String, ButtonAction).new.tap do |actions|
  # Digit buttons
  (0..9).each { |n| actions[n.to_s] = ->(calc : Calculator) { calc.input_digit(n.to_s) } }

  # Operation buttons
  actions["+"] = ->(calc : Calculator) { calc.perform_operation("+") }
  actions["-"] = ->(calc : Calculator) { calc.perform_operation("-") }
  actions["×"] = ->(calc : Calculator) { calc.perform_operation("×") }
  actions["÷"] = ->(calc : Calculator) { calc.perform_operation("÷") }

  # Other buttons
  actions["."] = ->(calc : Calculator) { calc.input_dot }
  actions["="] = ->(calc : Calculator) { calc.calculate }
  actions["C"] = ->(calc : Calculator) { calc.clear }
  actions["+/-"] = ->(calc : Calculator) { calc.plus_minus }
  actions["%"] = ->(calc : Calculator) { calc.percent }
  actions["√"] = ->(calc : Calculator) { calc.square_root }
  actions["MC"] = ->(calc : Calculator) { calc.memory_clear }
  actions["MR"] = ->(calc : Calculator) { calc.memory_recall }
  actions["M+"] = ->(calc : Calculator) { calc.memory_add }
  actions["M-"] = ->(calc : Calculator) { calc.memory_subtract }
end

# Helper method to create buttons with actions
def create_button(label : String, calc : Calculator) : UIng::Button
  button = UIng::Button.new(label)
  if action = BUTTON_ACTIONS[label]?
    button.on_clicked { action.call(calc) }
  end
  button
end

UIng.init

window = UIng::Window.new("Calculator", 300, 300, margined: true)
window.on_closing do
  UIng.quit
  true
end

grid = UIng::Grid.new(padded: true)

# Display entry (spans 5 columns)
display = UIng::Entry.new
display.text = "0"
display.read_only = true
grid.append(display, 0, 0, 5, 1, true, :fill, false, :fill)

# Create calculator instance
calc = Calculator.new(display)

# Create buttons using layout definition
BUTTON_LAYOUT.each_with_index do |row_name, labels, index|
  next if row_name == :operations # Special handling for operations

  row = index + 1
  labels.each_with_index do |label, col|
    next if row_name == :row5 && col == 3 # Skip position 3 (occupied by + button)

    button = create_button(label, calc)
    grid.append(button, col, row, 1, 1, true, :fill, true, :fill)
  end
end

# + button (spans 2 rows, from row 4 to row 5)
plus_button = create_button("+", calc)
grid.append(plus_button, 3, 4, 1, 2, true, :fill, true, :fill)

# - button (row 4, column 4)
minus_button = create_button("-", calc)
grid.append(minus_button, 4, 4, 1, 1, true, :fill, true, :fill)

# = button at position 4
equals_button = create_button("=", calc)
grid.append(equals_button, 4, 5, 1, 1, true, :fill, true, :fill)

window.child = grid
window.show

UIng.main
UIng.uninit
