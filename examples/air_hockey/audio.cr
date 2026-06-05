{% if file_exists?("#{__DIR__}/lib/raudio/src/raudio.cr") %}
  require "./lib/raudio/src/raudio"
{% else %}
  require "raudio"
{% end %}

{% if flag?(:execution_context) %}
  require "fiber/execution_context"
{% end %}

# Audio runs outside the GUI thread. On macOS, libui must stay on the main
# thread, so the main program only sends small sound events through a Channel.
{% if flag?(:execution_context) %}
  class AirHockey3DAudio
    SAMPLE_RATE  = 44_100
    WAV_TYPE     = ".wav"
    PROBE_EVENTS = {
      "serve"  => AirHockey3DSoundEvent::Serve,
      "mallet" => AirHockey3DSoundEvent::MalletHit,
      "rail"   => AirHockey3DSoundEvent::RailHit,
      "goal"   => AirHockey3DSoundEvent::Goal,
      "match"  => AirHockey3DSoundEvent::MatchOver,
    }

    @commands : Channel(AirHockey3DSoundEvent)
    @context : Fiber::ExecutionContext::Isolated
    @closed = false

    def self.start : self
      new
    end

    def initialize
      @commands = Channel(AirHockey3DSoundEvent).new(64)
      @context = Fiber::ExecutionContext::Isolated.new("air-hockey-audio") do
        run_audio_loop(@commands)
      end
    end

    def play(event : AirHockey3DSoundEvent)
      return unless AirHockey3DConfig::AUDIO_ENABLED

      # Never let audio back pressure stall the UI timer or input callbacks.
      select
      when @commands.send(event)
      else
        AirHockey3DLog.info("audio event dropped: #{event}")
      end
    rescue Channel::ClosedError
    end

    def close
      return if @closed

      @closed = true
      @commands.close
      @context.wait
    rescue error
      AirHockey3DLog.exception("audio shutdown", error)
    end

    private def run_audio_loop(commands : Channel(AirHockey3DSoundEvent))
      return unless AirHockey3DConfig::AUDIO_ENABLED

      AirHockey3DLog.info("audio context starting")
      Raudio::AudioDevice.open do
        Raudio::AudioDevice.master_volume = 0.72_f32
        sounds = SoundBank.new
        music = bgm_enabled? ? BgmPlayer.load : nil

        begin
          start_music(music)
          run_probe(sounds, music)

          loop do
            select
            when event = commands.receive?
              break unless event
              sounds.play(event) if sfx_enabled?
            when timeout(10.milliseconds)
            end

            music.try(&.update)
          end
        ensure
          music.try(&.release)
          sounds.release
        end
      end
    rescue error
      AirHockey3DLog.exception("audio context", error)
    ensure
      AirHockey3DLog.info("audio context stopped")
    end

    private def start_music(music : BgmPlayer?)
      return unless music

      music.play
    end

    private def bgm_enabled? : Bool
      ENV["AIR_HOCKEY3D_BGM"]? != "0"
    end

    private def sfx_enabled? : Bool
      ENV["AIR_HOCKEY3D_SFX"]? != "0"
    end

    private def run_probe(sounds : SoundBank, music : BgmPlayer?)
      probe = ENV["AIR_HOCKEY3D_AUDIO_PROBE"]?.try(&.downcase)
      return unless probe

      AirHockey3DLog.info("audio probe: #{probe}")
      events =
        case probe
        when "all"
          PROBE_EVENTS.values
        when "music", "bgm"
          [] of AirHockey3DSoundEvent
        else
          event = PROBE_EVENTS[probe]?
          event ? [event] : [] of AirHockey3DSoundEvent
        end

      events.each do |event|
        AirHockey3DLog.info("audio probe playing: #{event}")
        sounds.play(event)
        pump_music(music, 900.milliseconds)
      end

      pump_music(music, 2.seconds) if probe == "music" || probe == "bgm" || probe == "all"
    end

    private def pump_music(music : BgmPlayer?, duration : Time::Span)
      started_at = Time.instant
      while Time.instant - started_at < duration
        music.try(&.update)
        sleep 10.milliseconds
      end
    end

    private class BgmPlayer
      DEFAULT_FILE = File.join(__DIR__, "assets", "bgm.wav")

      def self.load : self?
        path = ENV["AIR_HOCKEY3D_BGM_FILE"]? || DEFAULT_FILE
        unless File.exists?(path)
          AirHockey3DLog.info("BGM file not found: #{path}")
          return nil
        end

        new(path)
      rescue error
        AirHockey3DLog.exception("BGM load", error)
        nil
      end

      def initialize(path : String)
        @music = Raudio::Music.load(path)
        @music.volume = 0.30_f32
        @music.looping = true
      end

      def play
        @music.play
      end

      def update
        @music.update
      end

      def release
        @music.release
      end
    end

    private class SoundBank
      def initialize
        @sounds = {
          AirHockey3DSoundEvent::Serve     => Synth.tone(0.16, 540.0, 0.34, 9.0),
          AirHockey3DSoundEvent::MalletHit => Synth.tone(0.09, 230.0, 0.48, 22.0),
          AirHockey3DSoundEvent::RailHit   => Synth.tone(0.06, 760.0, 0.22, 30.0),
          AirHockey3DSoundEvent::Goal      => Synth.chime(0.70),
          AirHockey3DSoundEvent::MatchOver => Synth.chime(1.10),
        }
      end

      def play(event : AirHockey3DSoundEvent)
        @sounds[event]?.try(&.play)
      end

      def release
        @sounds.each_value(&.release)
      end
    end

    private module Synth
      extend self

      def tone(seconds : Float64, frequency : Float64, volume : Float64, decay : Float64) : Raudio::Sound
        sound_from_wav(seconds) do |time|
          envelope = Math.exp(-decay * time)
          Math.sin(2.0 * Math::PI * frequency * time) * volume * envelope
        end
      end

      def chime(seconds : Float64) : Raudio::Sound
        sound_from_wav(seconds) do |time|
          a = Math.sin(2.0 * Math::PI * 440.0 * time)
          b = Math.sin(2.0 * Math::PI * 660.0 * time) * 0.55
          c = Math.sin(2.0 * Math::PI * 880.0 * time) * 0.28
          (a + b + c) * 0.22 * Math.exp(-3.2 * time)
        end
      end

      private def sound_from_wav(seconds : Float64, &block : Float64 -> Float64) : Raudio::Sound
        bytes = wav_bytes(seconds) { |time| yield time }
        wave = Raudio::Wave.load_from_memory(WAV_TYPE, bytes)
        Raudio::Sound.from_wave(wave)
      ensure
        wave.try(&.release)
      end

      private def wav_bytes(seconds : Float64, &block : Float64 -> Float64) : Bytes
        frames = (seconds * SAMPLE_RATE).to_i
        data_size = frames * sizeof(Int16)
        io = IO::Memory.new(44 + data_size)

        write_ascii(io, "RIFF")
        io.write_bytes((36 + data_size).to_u32, IO::ByteFormat::LittleEndian)
        write_ascii(io, "WAVE")
        write_ascii(io, "fmt ")
        io.write_bytes(16_u32, IO::ByteFormat::LittleEndian)
        io.write_bytes(1_u16, IO::ByteFormat::LittleEndian)
        io.write_bytes(1_u16, IO::ByteFormat::LittleEndian)
        io.write_bytes(SAMPLE_RATE.to_u32, IO::ByteFormat::LittleEndian)
        io.write_bytes((SAMPLE_RATE * sizeof(Int16)).to_u32, IO::ByteFormat::LittleEndian)
        io.write_bytes(sizeof(Int16).to_u16, IO::ByteFormat::LittleEndian)
        io.write_bytes(16_u16, IO::ByteFormat::LittleEndian)
        write_ascii(io, "data")
        io.write_bytes(data_size.to_u32, IO::ByteFormat::LittleEndian)

        frames.times do |frame|
          time = frame / SAMPLE_RATE
          sample = yield(time).clamp(-1.0, 1.0)
          io.write_bytes((sample * Int16::MAX).to_i16, IO::ByteFormat::LittleEndian)
        end

        io.to_slice
      end

      private def write_ascii(io : IO, text : String)
        io.write(text.to_slice)
      end
    end
  end
{% else %}
  {% puts "Audio disabled; build with -Dpreview_mt -Dexecution_context to enable sound." %}

  class AirHockey3DAudio
    def self.start : self
      AirHockey3DLog.info("audio disabled: build with -Dpreview_mt -Dexecution_context")
      new
    end

    def play(event : AirHockey3DSoundEvent)
    end

    def close
    end
  end
{% end %}
