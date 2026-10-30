require "../../spec_helper"

describe UIng::Table::Params do
  it "keeps and returns the original Model from Table::Params" do
    model = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x210_u64))
    replacement = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x220_u64))
    params = UIng::Table::Params.new(model)

    params.model.same?(model).should be_true

    params.model = replacement
    params.model.same?(replacement).should be_true
  end

  it "keeps Table::Params model and row-color fields synchronized" do
    first = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x210_u64))
    second = UIng::Table::Model.unsafe_wrap(Pointer(UIng::LibUI::TableModel).new(0x220_u64))
    params = UIng::Table::Params.new(first, 3)

    params.model.should be(first)
    params.row_background_color_model_column.should eq(3)

    params.model = second
    params.row_background_color_model_column = 5

    params.model.should be(second)
    params.to_unsafe.value.model.should eq(second.to_unsafe)
    params.to_unsafe.value.row_background_color_model_column.should eq(5)
  end
end
