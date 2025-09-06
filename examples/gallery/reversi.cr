require "../../src/uing"

# Reversi game with GUI

module Reversi
  BOARD_SIZE    =          8
  INITIAL_ALPHA = -1_000_000
  INITIAL_BETA  =  1_000_000

  DIRECTIONS = [
    {-1, -1}, {-1, 0}, {-1, 1},
    {0, -1}, {0, 1},
    {1, -1}, {1, 0}, {1, 1},
  ]

  enum Cell
    Empty
    Black
    White

    def opponent : Cell
      case self
      when .black? then Cell::White
      when .white? then Cell::Black
      else              Cell::Empty
      end
    end

    def stone? : Bool
      self != Cell::Empty
    end
  end

  alias Board = Array(Array(Cell))

  struct Pos
    getter board : Board
    getter to_move : Cell

    def initialize(@board : Board, @to_move : Cell)
    end

    def self.initial : Pos
      b = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, Cell::Empty) }
      b[3][3] = Cell::White
      b[4][4] = Cell::White
      b[3][4] = Cell::Black
      b[4][3] = Cell::Black
      Pos.new(b, Cell::Black)
    end

    private def in_bounds?(r : Int32, c : Int32) : Bool
      (0 <= r && r < BOARD_SIZE) && (0 <= c && c < BOARD_SIZE)
    end

    # Check if placing a stone at (r,c) is legal for the given side
    # Reversi rule: must sandwich opponent stones in at least one direction
    def legal_at?(r : Int32, c : Int32, side : Cell) : Bool
      return false unless in_bounds?(r, c)
      return false unless @board[r][c] == Cell::Empty

      opp = side.opponent

      DIRECTIONS.any? do |dr, dc|
        rr = r + dr
        cc = c + dc
        seen_opp = false

        while in_bounds?(rr, cc) && @board[rr][cc] == opp
          seen_opp = true
          rr += dr; cc += dc
        end

        seen_opp && in_bounds?(rr, cc) && @board[rr][cc] == side
      end
    end

    def legal_moves_for(side : Cell) : Array({Int32, Int32})
      (0...BOARD_SIZE).flat_map do |r|
        (0...BOARD_SIZE).compact_map do |c|
          {r, c} if legal_at?(r, c, side)
        end
      end
    end

    def legal_moves : Array({Int32, Int32})
      legal_moves_for(@to_move)
    end

    def play(r : Int32, c : Int32) : Pos
      raise "illegal move" unless legal_at?(r, c, @to_move)

      newb = deep_copy(@board)
      side = @to_move
      opp = side.opponent

      newb[r][c] = side

      DIRECTIONS.each do |dr, dc|
        rr = r + dr
        cc = c + dc
        path = [] of {Int32, Int32}

        while in_bounds?(rr, cc) && newb[rr][cc] == opp
          path << {rr, cc}
          rr += dr; cc += dc
        end

        if path.size > 0 && in_bounds?(rr, cc) && newb[rr][cc] == side
          path.each { |(pr, pc)| newb[pr][pc] = side }
        end
      end

      Pos.new(newb, side.opponent)
    end

    def pass : Pos
      Pos.new(deep_copy(@board), @to_move.opponent)
    end

    def terminal? : Bool
      legal_moves.empty? && legal_moves_for(@to_move.opponent).empty?
    end

    def count(side : Cell) : Int32
      @board.sum(&.count(side))
    end

    WEIGHTS = [
      [120, -20, 20, 5, 5, 20, -20, 120],
      [-20, -40, -5, -5, -5, -5, -40, -20],
      [20, -5, 15, 3, 3, 15, -5, 20],
      [5, -5, 3, 3, 3, 3, -5, 5],
      [5, -5, 3, 3, 3, 3, -5, 5],
      [20, -5, 15, 3, 3, 15, -5, 20],
      [-20, -40, -5, -5, -5, -5, -40, -20],
      [120, -20, 20, 5, 5, 20, -20, 120],
    ]

    # Evaluate position from the given side's perspective
    # Components: Material (stone count) + Positional (corner/edge values) + Mobility (move options)
    def evaluate_for(side : Cell) : Int32
      opp = side.opponent
      material = positional = 0

      @board.each_with_index do |row, r|
        row.each_with_index do |cell, c|
          weight = WEIGHTS[r][c]
          case cell
          when side
            material += 10
            positional += weight
          when opp
            material -= 10
            positional -= weight
          end
        end
      end

      # Optimized mobility calculation
      my_moves = legal_moves_for(side).size
      opp_moves = legal_moves_for(opp).size
      mobility = (my_moves - opp_moves) * 2

      material + positional + mobility
    end

    def pretty : String
      String.build do |io|
        # Display rank 8 at top (flip row order for standard chess notation)
        8.times do |rr|
          r = 7 - rr
          io << (r + 1).to_s << ' '
          8.times do |c|
            ch = case @board[r][c]
                 when .black? then 'B'
                 when .white? then 'W'
                 else              '.'
                 end
            io << ch
          end
          io << '\n'
        end
        io << "  abcdefgh\n"
        io << "To move: " << (@to_move == Cell::Black ? "B\n" : "W\n")
      end
    end

    private def deep_copy(b : Board) : Board
      b.map(&.dup)
    end
  end

  def self.negamax(pos : Pos, depth : Int32, alpha : Int32, beta : Int32) : Int32
    return pos.evaluate_for(pos.to_move) if depth <= 0 || pos.terminal?

    moves = pos.legal_moves

    if moves.empty?
      return -negamax(pos.pass, depth, -beta, -alpha)
    end

    # best: the best score we have actually seen at this node
    # a   : local copy of alpha (lower bound for pruning)
    best = Int32::MIN
    a = alpha

    moves.each do |(r, c)|
      child = pos.play(r, c)
      score = -negamax(child, depth - 1, -beta, -a)

      # update best-so-far
      if score > best
        best = score
      end
      # update local alpha (lower bound)
      if best > a
        a = best
      end

      break if a >= beta
    end

    best
  end

  def self.search_best_move(pos : Pos, depth : Int32) : {Int32, Int32}?
    moves = pos.legal_moves
    return nil if moves.empty?

    alpha = INITIAL_ALPHA
    beta = INITIAL_BETA
    best_score = INITIAL_ALPHA
    best_move = moves.first

    moves.each do |(r, c)|
      child = pos.play(r, c)
      score = -negamax(child, depth - 1, -beta, -alpha)
      if score > best_score
        best_score = score
        best_move = {r, c}
      end
      alpha = best_score if best_score > alpha
      break if alpha >= beta
    end

    best_move
  end

  def self.rc_from_alg(s : String) : {Int32, Int32}
    raise "bad coord" unless s.size == 2
    file_ch = s[0]
    rank_ch = s[1]
    raise "bad coord" unless ('a'..'h').includes?(file_ch) && ('1'..'8').includes?(rank_ch)
    file = file_ch.ord - 'a'.ord
    rank = rank_ch.ord - '1'.ord
    {rank, file}
  end

  def self.alg_from_rc(r : Int32, c : Int32) : String
    "#{('a'.ord + c).chr}#{('1'.ord + r).chr}"
  end
end

class ReversiGame
  property pos : Reversi::Pos
  property ai_depth : Int32
  property human_color : Reversi::Cell
  property game_over : Bool
  property last_move : {Int32, Int32}?
  property ai_thinking : Bool

  def initialize
    @pos = Reversi::Pos.initial
    @ai_depth = 4
    @human_color = Reversi::Cell::Black
    @game_over = false
    @last_move = nil
    @ai_thinking = false
  end

  def reset
    @pos = Reversi::Pos.initial
    @game_over = false
    @last_move = nil
    @ai_thinking = false
  end

  def is_human_turn? : Bool
    @pos.to_move == @human_color && !@game_over
  end

  def is_ai_turn? : Bool
    @pos.to_move != @human_color && !@game_over
  end

  def make_move(row : Int32, col : Int32) : Bool
    return false unless @pos.legal_at?(row, col, @pos.to_move)

    @pos = @pos.play(row, col)
    @last_move = {row, col}

    if @pos.terminal?
      @game_over = true
    end

    true
  end

  def pass_turn
    @pos = @pos.pass
    if @pos.terminal?
      @game_over = true
    end
  end

  def get_winner : String
    return "Game in progress" unless @game_over

    black_count = @pos.count(Reversi::Cell::Black)
    white_count = @pos.count(Reversi::Cell::White)

    if black_count > white_count
      "Black wins! (#{black_count}-#{white_count})"
    elsif white_count > black_count
      "White wins! (#{white_count}-#{black_count})"
    else
      "Draw! (#{black_count}-#{white_count})"
    end
  end
end

class ReversiUI
  BOARD_SIZE      = 480.0
  CELL_SIZE       = BOARD_SIZE / 8.0
  STONE_RADIUS    = CELL_SIZE * 0.35
  BOARD_COLOR     = {0.0, 0.5, 0.0, 1.0} # Green
  GRID_COLOR      = {0.0, 0.0, 0.0, 1.0} # Black
  BLACK_COLOR     = {0.1, 0.1, 0.1, 1.0} # Dark gray
  WHITE_COLOR     = {0.9, 0.9, 0.9, 1.0} # Light gray
  HINT_COLOR      = {0.8, 0.8, 0.0, 0.5} # Yellow with transparency
  HIGHLIGHT_COLOR = {1.0, 0.0, 0.0, 0.7} # Red with transparency

  @game : ReversiGame
  @window : UIng::Window
  @area : UIng::Area?
  @status_label : UIng::Label
  @score_label : UIng::Label
  @new_game_button : UIng::Button
  @pass_button : UIng::Button
  @difficulty_slider : UIng::Slider
  @color_selector : UIng::RadioButtons
  # True once the first move (human or AI) has started; prevents color switching mid-game
  @color_locked : Bool

  def initialize
    @game = ReversiGame.new
    @status_label = UIng::Label.new("Black to move")
    @score_label = UIng::Label.new("Black: 2, White: 2")
    @new_game_button = UIng::Button.new("New Game")
    @pass_button = UIng::Button.new("Pass")
    @difficulty_slider = UIng::Slider.new(1, 6)
    @color_selector = UIng::RadioButtons.new(["Play Black (first)", "Play White (second)"])
    @color_locked = false
    @area = create_area
    @window = create_window

    setup_ui
    update_status
  end

  private def create_window : UIng::Window
    window = UIng::Window.new("Reversi Example", 700, 600, margined: true)
    window.on_closing { UIng.quit; true }
    window
  end

  private def create_area : UIng::Area
    handler = UIng::Area::Handler.new

    handler.draw do |area, params|
      draw_board(params.context)
    end

    handler.mouse_event do |area, event|
      if event.down == 1 # Left click
        handle_click(event.x, event.y, area)
        area.queue_redraw_all
      end
    end

    UIng::Area.new(handler)
  end

  private def setup_ui
    main_box = UIng::Box.new(:horizontal, padded: true)

    # Left side: game board
    board_box = UIng::Box.new(:vertical, padded: true)
    if area = @area
      board_box.append(area, stretchy: true)
    end

    # Right side: controls
    control_box = UIng::Box.new(:vertical, padded: true)
    control_box.append(UIng::Label.new("Game Status:"), stretchy: false)
    control_box.append(@status_label, stretchy: false)
    control_box.append(UIng::Separator.new(:horizontal), stretchy: false)

    control_box.append(UIng::Label.new("Score:"), stretchy: false)
    control_box.append(@score_label, stretchy: false)
    control_box.append(UIng::Separator.new(:horizontal), stretchy: false)

    control_box.append(UIng::Label.new("AI Difficulty:"), stretchy: false)
    @difficulty_slider.value = @game.ai_depth
    @difficulty_slider.on_changed do
      @game.ai_depth = @difficulty_slider.value
    end
    control_box.append(@difficulty_slider, stretchy: false)
    control_box.append(UIng::Separator.new(:horizontal), stretchy: false)

    control_box.append(UIng::Label.new("Your Color:"), stretchy: false)
    @color_selector.on_selected do |idx|
      # Ignore changes after color is locked (first move started)
      next if @color_locked
      @game.human_color = (idx == 0) ? Reversi::Cell::Black : Reversi::Cell::White
      update_status
      # If human chooses White before any move, AI should start immediately and color locks
      if @game.human_color == Reversi::Cell::White && @game.last_move.nil?
        lock_color_selection
        check_ai_turn(nil)
      end
    end
    control_box.append(@color_selector, stretchy: false)
    control_box.append(UIng::Separator.new(:horizontal), stretchy: false)

    @new_game_button.on_clicked do
      @game.reset
      # Always reset to Black at the start of a new game so user explicitly re-chooses White.
      @color_selector.selected = 0
      @game.human_color = Reversi::Cell::Black
      unlock_color_selection
      update_status
      @area.try(&.queue_redraw_all)
    end
    control_box.append(@new_game_button, stretchy: false)

    @pass_button.on_clicked do
      if @game.is_human_turn? && @game.pos.legal_moves.empty?
        @game.pass_turn
        update_status
        @area.try(&.queue_redraw_all)
        check_ai_turn(nil)
      end
    end
    control_box.append(@pass_button, stretchy: false)

    main_box.append(board_box, stretchy: true)
    main_box.append(control_box, stretchy: false)

    @window.child = main_box
  end

  private def draw_board(ctx : UIng::Area::Draw::Context)
    # Draw board background
    board_brush = UIng::Area::Draw::Brush.new(:solid, *BOARD_COLOR)
    ctx.fill_path(board_brush) do |path|
      path.add_rectangle(0, 0, BOARD_SIZE, BOARD_SIZE)
    end

    # Draw grid lines
    grid_brush = UIng::Area::Draw::Brush.new(:solid, *GRID_COLOR)
    stroke_params = UIng::Area::Draw::StrokeParams.new(thickness: 1.0)

    ctx.stroke_path(grid_brush, stroke_params) do |path|
      # Vertical lines
      9.times do |i|
        x = i * CELL_SIZE
        path.new_figure(x, 0)
        path.line_to(x, BOARD_SIZE)
      end

      # Horizontal lines
      9.times do |i|
        y = i * CELL_SIZE
        path.new_figure(0, y)
        path.line_to(BOARD_SIZE, y)
      end
    end

    # Draw stones and hints
    8.times do |row|
      8.times do |col|
        cell_x = col * CELL_SIZE + CELL_SIZE / 2
        render_row = 7 - row # Flip coordinates for display
        cell_y = render_row * CELL_SIZE + CELL_SIZE / 2

        case @game.pos.board[row][col]
        when .black?
          draw_stone(ctx, cell_x, cell_y, BLACK_COLOR)
        when .white?
          draw_stone(ctx, cell_x, cell_y, WHITE_COLOR)
        when .empty?
          # Draw hint for legal moves
          if @game.is_human_turn? && @game.pos.legal_at?(row, col, @game.pos.to_move)
            draw_hint(ctx, cell_x, cell_y)
          end
        end

        # Highlight last move
        if @game.last_move == {row, col}
          draw_highlight(ctx, cell_x, cell_y)
        end
      end
    end
  end

  private def draw_stone(ctx : UIng::Area::Draw::Context, x : Float64, y : Float64, color : Tuple(Float64, Float64, Float64, Float64))
    brush = UIng::Area::Draw::Brush.new(:solid, *color)
    ctx.fill_path(brush) do |path|
      path.new_figure_with_arc(x, y, STONE_RADIUS, 0, Math::PI * 2, false)
    end
  end

  private def draw_hint(ctx : UIng::Area::Draw::Context, x : Float64, y : Float64)
    brush = UIng::Area::Draw::Brush.new(:solid, *HINT_COLOR)
    ctx.fill_path(brush) do |path|
      path.new_figure_with_arc(x, y, STONE_RADIUS * 0.5, 0, Math::PI * 2, false)
    end
  end

  private def draw_highlight(ctx : UIng::Area::Draw::Context, x : Float64, y : Float64)
    brush = UIng::Area::Draw::Brush.new(:solid, *HIGHLIGHT_COLOR)
    stroke_params = UIng::Area::Draw::StrokeParams.new(thickness: 3.0)
    ctx.stroke_path(brush, stroke_params) do |path|
      path.new_figure_with_arc(x, y, STONE_RADIUS + 5, 0, Math::PI * 2, false)
    end
  end

  private def handle_click(x : Float64, y : Float64, area : UIng::Area)
    return unless @game.is_human_turn?

    col = (x / CELL_SIZE).to_i
    row_view = (y / CELL_SIZE).to_i
    row = 7 - row_view # Convert display to model coordinates

    return unless (0..7).includes?(row) && (0..7).includes?(col)

    if @game.make_move(row, col)
      # First human move locks color selection
      lock_color_selection unless @color_locked
      update_status
      check_ai_turn(area)
    end
  end

  private def check_ai_turn(area : UIng::Area? = nil)
    return unless @game.is_ai_turn?
    if @game.pos.terminal?
      @game.game_over = true
      update_status
      return
    end

    if @game.pos.legal_moves.empty?
      @game.pass_turn
      update_status
      return
    end

    @game.ai_thinking = true
    # Once AI thinking begins for the first move, lock color to prevent switching
    lock_color_selection unless @color_locked
    update_status

    # Store area reference for timer callback
    area_ref = area || @area

    # Use timer to make AI move after a short delay
    UIng.timer(500) do
      if move = Reversi.search_best_move(@game.pos, @game.ai_depth)
        row, col = move
        @game.make_move(row, col)
      else
        @game.pass_turn
      end

      @game.ai_thinking = false
      update_status
      area_ref.try(&.queue_redraw_all)
      0 # Stop timer
    end
  end

  private def update_status
    if !@game.game_over && @game.pos.terminal?
      @game.game_over = true
    end

    if @game.game_over
      # Game finished: allow choosing color for the next game
      unlock_color_selection if @color_locked
      @status_label.text = @game.get_winner
      @pass_button.disable
    elsif @game.ai_thinking
      @status_label.text = "AI thinking..."
      @pass_button.disable
    else
      current_player = @game.pos.to_move == Reversi::Cell::Black ? "Black" : "White"
      @status_label.text = "#{current_player} to move"
      if @game.is_human_turn? && @game.pos.legal_moves.empty?
        @pass_button.enable
      else
        @pass_button.disable
      end
    end

    black_count = @game.pos.count(Reversi::Cell::Black)
    white_count = @game.pos.count(Reversi::Cell::White)
    @score_label.text = "Black: #{black_count}, White: #{white_count}"
  end

  def run
    @window.show
    check_ai_turn(nil) # Check if AI should move first
    UIng.main
  end

  private def lock_color_selection
    @color_locked = true
    @color_selector.disable
  end

  private def unlock_color_selection
    @color_locked = false
    @color_selector.enable
  end
end

# Initialize and run the game
UIng.init
game = ReversiUI.new
game.run
UIng.uninit
