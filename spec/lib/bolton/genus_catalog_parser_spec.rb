require 'spec_helper'

describe Bolton::GenusCatalogParser do
  it 'should do nothing, for now' do
    Bolton::GenusCatalogParser.parse('foo').should be_nil
  end
end
