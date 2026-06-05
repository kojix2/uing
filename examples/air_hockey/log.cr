# Set AIR_HOCKEY3D_DEBUG=1 to see lifecycle and input logs while debugging.
module AirHockey3DLog
  @@first_draw_logged = false
  @@tick_count = 0

  def self.info(message : String)
    return unless AirHockey3DConfig::DEBUG

    STDERR.puts("[air_hockey3d] #{Time.local} #{message}")
  end

  def self.exception(context : String, error : Exception)
    STDERR.puts("[air_hockey3d] #{Time.local} #{context} failed: #{error.class}: #{error.message}")
    error.backtrace?.try do |backtrace|
      backtrace.each { |line| STDERR.puts("[air_hockey3d]   #{line}") }
    end
  end

  def self.log_environment
    info("Crystal #{Crystal::VERSION} on #{Crystal::DESCRIPTION}")
    %w[DISPLAY WAYLAND_DISPLAY XAUTHORITY GDK_BACKEND GTK_PATH LD_LIBRARY_PATH].each do |key|
      info("ENV #{key}=#{ENV[key]? || "(unset)"}")
    end
  end

  def self.log_first_draw(width : Float64, height : Float64)
    return if @@first_draw_logged

    @@first_draw_logged = true
    info("first draw: area=#{width}x#{height}")
  end

  def self.tick
    @@tick_count += 1
    return unless @@tick_count == 1 || @@tick_count % AirHockey3DConfig::FPS == 0

    info("timer tick: #{@@tick_count}, draw_seen=#{@@first_draw_logged}")
  end
end
