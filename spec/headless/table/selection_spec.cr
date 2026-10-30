require "../../spec_helper"

describe UIng::Table::Selection do
  it "keeps a snapshot of rows in user-created Table::Selection objects" do
    rows = [1, 3]
    selection = UIng::Table::Selection.new(rows)

    rows[0] = 9
    rows << 11

    selection.rows.should eq([1, 3])
    selection.num_rows.should eq(2)

    copied_rows = selection.rows
    copied_rows[0] = 7
    selection.rows.should eq([1, 3])
  end
end
