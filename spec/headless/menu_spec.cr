require "../spec_helper"
require "../support/menu_items"

class UIng::Menu
  def initialize(@ref_ptr : Pointer(UIng::LibUI::Menu), *, lifetime_spec : Bool)
    @@mutex.synchronize do
      @@menu << self
    end
  end

  def add_item_for_lifetime_spec(item : UIng::MenuItem) : Nil
    @menu_items << item
  end

  def self.reserve_special_items_for_lifetime_spec : Nil
    @@has_quit_item = true
    @@has_preferences_item = true
    @@has_about_item = true
  end

  def self.special_items_reserved_for_lifetime_spec? : Bool
    @@has_quit_item && @@has_preferences_item && @@has_about_item
  end

  def self.reset_after_uninit_for_spec : Nil
    reset_after_uninit
  end
end

describe UIng::Menu do
  it "invalidates menu wrappers and resets special items after uninit" do
    menu = UIng::Menu.new(Pointer(UIng::LibUI::Menu).null, lifetime_spec: true)
    item = SpecSupport::LifetimeSafetyMenuItem.new
    menu.add_item_for_lifetime_spec(item)
    UIng::Menu.reserve_special_items_for_lifetime_spec

    UIng::Menu.reset_after_uninit_for_spec

    UIng::Menu.special_items_reserved_for_lifetime_spec?.should be_false
    item.callback_retained?.should be_false
    expect_raises(Exception, /already been released/) { menu.to_unsafe }
    expect_raises(Exception, /already been released/) { menu.append_item("Item") }
    expect_raises(Exception, /already been released/) do
      menu.append_item("Item") { raise "must not configure a released menu" }
    end
    expect_raises(Exception, /already been released/) { item.to_unsafe }
    expect_raises(Exception, /already been released/) { item.enable }
  end

  it "supports implicit MenuItem receivers and returns MenuItem for every item kind" do
    # Instantiate the DSL blocks without creating native application menus.
    typeof(UIng::Menu.new("File").append_item("Open") do
      set_shortcut('O', UIng::Modifiers::Primary)
      on_clicked { |_window| }
    end).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("Edit").append_check_item("Check") { checked? }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("Edit").append_check_item("Check", checked: true) { checked? }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("File").append_preferences_item { on_clicked { |_window| } }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("Help").append_about_item { on_clicked { |_window| } }).should eq(UIng::MenuItem)
    typeof(UIng::Menu.new("File").append_quit_item { clear_on_clicked }).should eq(UIng::MenuItem)
  end
end
