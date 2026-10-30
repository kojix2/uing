require "../spec_helper"

class UIng::ToolbarItem
  def retained_icon_for_spec : UIng::Image?
    @icon_copy
  end
end
