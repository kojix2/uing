require "../../spec_helper"

describe UIng::Table::TextColumnOptionalParams do
  it "keeps optional text-column parameters synchronized" do
    params = UIng::Table::TextColumnOptionalParams.new(2)
    params.color_model_column.should eq(2)

    params.color_model_column = 4

    params.color_model_column.should eq(4)
    params.to_unsafe.value.color_model_column.should eq(4)
  end
end
