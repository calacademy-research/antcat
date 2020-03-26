# frozen_string_literal: true

require 'rails_helper'

describe Unitalicize do
  describe "#call" do
    specify { expect(described_class['<i>Atta</i>'.html_safe].html_safe?).to eq true }

    it "removes <i> tags" do
      expect(described_class['Attini <i>Atta major</i> r.'.html_safe]).to eq 'Attini Atta major r.'
    end

    it "handles multiple <i> tags" do
      expect(described_class['Attini <i>Atta</i> <i>major</i> r.'.html_safe]).to eq 'Attini Atta major r.'
    end

    it "raises if called on unsafe strings" do
      expect { described_class['Attini <i>Atta major</i> r.'] }.
        to raise_error("Can't unitalicize an unsafe string")
    end
  end
end
