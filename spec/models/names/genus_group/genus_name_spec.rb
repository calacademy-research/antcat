require 'spec_helper'

describe GenusName do
  describe "#genus_epithet" do
    let(:name) { described_class.new(name: 'Atta') }

    specify { expect(name.genus_epithet).to eq 'Atta' }
  end
end
