require 'rails_helper'

describe Unitalicize do
  describe "#call" do
    it "removes <i> tags" do
      results = described_class['Attini <i>Atta major</i> r.'.html_safe]
      expect(results).to eq 'Attini Atta major r.'
      expect(results.html_safe?).to eq true
    end

    it "handles multiple <i> tags" do
      results = described_class['Attini <i>Atta</i> <i>major</i> r.'.html_safe]
      expect(results).to eq 'Attini Atta major r.'
      expect(results.html_safe?).to eq true
    end

    it "raises if called on unsafe strings" do
      expect { described_class['Attini <i>Atta major</i> r.'] }.
        to raise_error("Can't unitalicize an unsafe string")
    end
  end
end
