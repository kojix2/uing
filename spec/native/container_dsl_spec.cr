require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe "container block DSL" do
    before_all { UIng.init }
    after_all { UIng.uninit }

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

    it "inserts a Tab page between existing pages and applies its margins" do
      tab = UIng::Tab.new
      first = UIng::Label.new("first")
      last = UIng::Label.new("last")
      middle = UIng::Label.new("middle")
      begin
        tab.append("first", first)
        tab.append("last", last)
        tab.insert_at("middle", index: 1, margined: true) { middle }

        tab.num_pages.should eq(3)
        tab.margined?(1).should be_true
        middle.parent.should be(tab)
        tab.delete(1)
        middle.parent.should be_nil
        first.parent.should be(tab)
        last.parent.should be(tab)
        tab.num_pages.should eq(2)
        middle.destroy
      ensure
        first.destroy unless first.released? || first.parent
        last.destroy unless last.released? || last.parent
        middle.destroy unless middle.released? || middle.parent
        tab.destroy
      end
      first.released?.should be_true
      last.released?.should be_true
    end
  end
{% end %}
