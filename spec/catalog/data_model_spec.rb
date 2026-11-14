# frozen_string_literal: true

require 'rails_helper'

# docs/data-model.md has a section ("### `table`") for every table of db/schema.rb. This spec fails when a table is
# added without one, or a section names a table that is gone.
describe "Data model (docs/data-model.md)" do # rubocop:disable RSpec/DescribeClass
  let(:schema_tables) { Rails.root.join("db/schema.rb").read.scan(/create_table "(\w+)"/).flatten.sort }
  let(:documented_tables) { Rails.root.join("docs/data-model.md").read.scan(/^### `(\w+)`$/).flatten.sort }

  it "has a section for every table of the schema" do
    missing = schema_tables - documented_tables
    expect(missing).to be_empty, "tables without a section in docs/data-model.md: #{missing.join(', ')}"
  end

  it "has no section for a table that is not in the schema" do
    extra = documented_tables - schema_tables
    expect(extra).to be_empty, "sections of docs/data-model.md for tables not in db/schema.rb: #{extra.join(', ')}"
  end

  it "has each table once" do
    expect(documented_tables.tally.select { |_table, n| n > 1 }.keys).to be_empty
  end
end
