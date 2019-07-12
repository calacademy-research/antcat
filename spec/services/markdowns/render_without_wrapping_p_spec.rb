require 'spec_helper'

describe Markdowns::RenderWithoutWrappingP do
  describe "#call" do
    let!(:content) { '*pizza*' }

    specify { expect(described_class[content]).to eq "<em>pizza</em>" }
  end
end
