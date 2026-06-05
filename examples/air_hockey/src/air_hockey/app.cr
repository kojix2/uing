module AirHockey
  class App
    @area : UIng::Area?

    def self.run
      new.run
    end

    def initialize
      @game = Game.new
      @renderer = Renderer.new(@game)
      @audio = Audio.start
      @handler = UIng::Area::Handler.new
      @area = nil
      @shutting_down = false
    end

    def run
      Log.info("starting")
      Log.log_environment
      init_ui
      setup_area
      setup_window
      setup_timer
      run_main_loop
    end

    private def init_ui
      Log.info("calling UIng.init")
      UIng.init
      Log.info("UIng.init succeeded")
    rescue e
      Log.exception("UIng.init", e)
      raise e
    end

    private def setup_area
      register_area_callbacks
      @area = UIng::Area.new(@handler)
      Log.info("area created")
    end

    private def register_area_callbacks
      @handler.draw do |_area, params|
        Log.log_first_draw(params.area_width, params.area_height)
        @renderer.draw(params)
      end

      @handler.mouse_event do |area, event|
        Log.info("mouse event: x=#{event.x}, y=#{event.y}, down=#{event.down}, up=#{event.up}") if event.down != 0 || event.up != 0
        @game.handle_mouse(event.x, event.y)
        if event.down != 0
          Log.info("serve requested by mouse")
          @game.serve
        end
        area.queue_redraw_all unless @shutting_down || area.released?
        true
      end

      @handler.key_event do |area, event|
        if event.up == 0
          Log.info("key event: key=#{event.key.inspect}, ext_key=#{event.ext_key}")
          AirHockey.handle_key(@game, event)
        end
        area.queue_redraw_all unless @shutting_down || area.released?
        true
      end
    end

    private def setup_window
      area = active_area

      vbox = UIng::Box.new(:vertical, padded: false)
      vbox.append(area, stretchy: true)
      Log.info("layout box created")

      window = UIng::Window.new("Air Hockey", @game.screen_width.to_i, @game.screen_height.to_i) do
        on_closing do
          Log.info("window closing")
          @shutting_down = true
          UIng.quit
          true
        end
        on_content_size_changed do |width, height|
          Log.info("window content size changed: #{width}x#{height}")
        end
        set_child(vbox)
        Log.info("window child set")
        show
      end
      Log.info("window created and shown, content_size=#{window.content_size}")
    end

    private def setup_timer
      area = active_area

      UIng.timer(Config::TICK_MS) do
        next 0 if @shutting_down || area.released?

        Log.tick
        @game.update
        @game.drain_sound_events.each { |event| @audio.play(event) }
        area.queue_redraw_all unless area.released?
        1
      end
      Log.info("timer registered")
    end

    private def run_main_loop
      Log.info("entering UIng.main")
      UIng.main
      Log.info("UIng.main returned")
    rescue e
      Log.exception("UIng.main", e)
      raise e
    ensure
      Log.info("closing audio")
      @audio.close
      Log.info("calling UIng.uninit")
      UIng.uninit
      Log.info("stopped")
    end

    private def active_area : UIng::Area
      @area || raise "area has not been initialized"
    end
  end
end
