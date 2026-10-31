require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::EditableCombobox do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "accepts free text independently of the suggested items" do
      SpecSupport.with_native_control(UIng::EditableCombobox.new(["first", "second"])) do |combobox|
        combobox.text = "候補にない値"
        combobox.text.should eq("候補にない値")
        combobox.append("third")
        combobox.text.should eq("候補にない値")
        combobox.text = ""
        combobox.text.should eq("")
      end
    end

    it "supports adding suggestions to an initially empty control" do
      SpecSupport.with_native_control(UIng::EditableCombobox.new) do |combobox|
        combobox.text.should eq("")

        combobox.append("日本語")
        combobox.text = "日本語"
        combobox.text.should eq("日本語")
      end
    end
  end
{% end %}
