module AirHockey
  module Config
    # Window and timer settings.
    SCREEN_W = 960.0
    SCREEN_H = 680.0
    FPS      =    60
    TICK_MS  = (1000.0 / FPS).to_i

    # Table-space dimensions. The simulation uses x for left/right and z for
    # far/near, then projects those coordinates onto the 2D Area when drawing.
    TABLE_W  = 520.0
    TABLE_D  = 760.0
    GOAL_W   = 190.0
    PUCK_R   =  18.0
    MALLET_R =  36.0
    CORNER_R =  64.0

    # Perspective scale at the far and near rails. Their ratio defines the
    # projective transform used by Game#project.
    FAR_SCALE  = 0.56
    NEAR_SCALE = 1.28

    # Gameplay tuning.
    WINNING_SCORE        =      7
    EPSILON              = 0.0001
    SLEEP_SPEED          =   0.08
    PUCK_MAX_SPEED       =   24.5
    MALLET_IMPULSE_SCALE =   0.84
    PUCK_REBOUND_SCALE   =   0.74
    MALLET_KICK          =    2.6
    LOOSE_PUCK_SPEED     =   3.25
    LATERAL_PUCK_Z_SPEED =   0.85
    OPPONENT_GUARD_STEP  =   13.5
    OPPONENT_ATTACK_STEP =   17.5

    # Audio is enabled by default. Set AIR_HOCKEY_AUDIO=0 when running in CI or
    # on machines without an audio device.
    AUDIO_ENABLED = ENV["AIR_HOCKEY_AUDIO"]? != "0"

    DEBUG = ENV["AIR_HOCKEY_DEBUG"]? == "1"
  end

  # High-level match state. Keeping this explicit makes the update loop easier to
  # reason about than scattering booleans like "playing" and "game_over".
  enum State
    Serving
    Playing
    Point
    Finished
  end

  # Gameplay only emits these events. The audio system decides how each one
  # sounds, which keeps raudio out of the simulation code.
  enum SoundEvent
    Serve
    MalletHit
    RailHit
    Goal
    MatchOver
  end
end
