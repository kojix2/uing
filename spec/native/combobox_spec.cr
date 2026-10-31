require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Combobox do
    before_all { UIng.init }
    after_all { UIng.uninit }

    describe "selection" do
      it "represents an empty selection as nil and can clear a selected index" do
        SpecSupport.with_native_control(UIng::Combobox.new(["first", "second"])) do |combobox|
          combobox.selected.should be_nil
          combobox.selected = 1
          combobox.selected.should eq(1)
          combobox.selected = nil
          combobox.selected.should be_nil
        end
      end
    end

    describe "item management" do
      it "keeps item counts and selection usable after insertion, deletion, and clearing" do
        SpecSupport.with_native_control(UIng::Combobox.new) do |combobox|
          combobox.num_items.should eq(0)
          combobox.append("first")
          combobox.append("third")
          combobox.insert_at(1, "second")
          combobox.num_items.should eq(3)
          combobox.selected = 2
          combobox.selected.should eq(2)

          combobox.selected = nil
          combobox.delete(1)
          combobox.num_items.should eq(2)
          combobox.selected = 1
          combobox.selected.should eq(1)
          combobox.clear
          combobox.num_items.should eq(0)
          combobox.selected.should be_nil

          combobox.append("replacement")
          combobox.selected = 0
          combobox.selected.should eq(0)
        end
      end
    end
  end
{% end %}
