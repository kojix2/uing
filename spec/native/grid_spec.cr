require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Grid do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "adds and inserts Grid children using block results and layout options" do
      grid = UIng::Grid.new
      first = UIng::Label.new("first")
      second = UIng::Label.new("second")
      begin
        grid.append(left: 0, top: 0, xspan: 2, yspan: 2,
          hexpand: true, halign: :center, vexpand: true, valign: :end) { first }
        grid.insert_at(first, :trailing, xspan: 2, yspan: 2,
          hexpand: true, halign: :start, vexpand: true, valign: :center) { second }

        first.parent.should be(grid)
        second.parent.should be(grid)
        first.detach
        first.parent.should be_nil
        first.destroy
      ensure
        first.destroy unless first.released? || first.parent
        second.destroy unless second.released? || second.parent
        grid.destroy
      end
      second.released?.should be_true
    end
  end
{% end %}
