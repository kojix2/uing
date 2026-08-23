require "./spec_helper"

describe UIng::Table::ModelColumn do
  it "maps the libui-ng editability sentinels" do
    UIng::Table::ModelColumn::Never.value.should eq(-1)
    UIng::Table::ModelColumn::Always.value.should eq(-2)
  end
end
