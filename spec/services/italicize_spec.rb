require 'rails_helper'

describe Italicize do
  describe "#call" do
    specify { expect(described_class['Atta'].html_safe?).to eq true }

    it "adds <i> tags" do
      expect(described_class['Atta']).to eq '<i>Atta</i>'
    end
  end
end
