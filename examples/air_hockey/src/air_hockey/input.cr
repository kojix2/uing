module AirHockey
  def self.handle_key(game : Game, event : UIng::Area::KeyEvent)
    case event.key
    when ' ', '\r'
      Log.info("serve requested by keyboard")
      game.serve
    when 'a', 'A'
      game.nudge_player(-30.0, 0.0)
    when 'd', 'D'
      game.nudge_player(30.0, 0.0)
    when 'w', 'W'
      game.nudge_player(0.0, -30.0)
    when 's', 'S'
      game.nudge_player(0.0, 30.0)
    end

    case event.ext_key
    when UIng::Area::ExtKey::Left
      game.nudge_player(-30.0, 0.0)
    when UIng::Area::ExtKey::Right
      game.nudge_player(30.0, 0.0)
    when UIng::Area::ExtKey::Up
      game.nudge_player(0.0, -30.0)
    when UIng::Area::ExtKey::Down
      game.nudge_player(0.0, 30.0)
    end
  end
end
