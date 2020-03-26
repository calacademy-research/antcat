# frozen_string_literal: true

require 'rails_helper'

describe Detax do
  describe "#call" do
    specify { expect(described_class['string'].html_safe?).to eq true }

    context 'when content contains non-catalog tags' do
      specify { expect(described_class['%github1']).to eq '%github1' }
      specify { expect(Markdowns::ParseAntcatHooks['%github1']).to include 'github.com' }
    end

    context 'with unsafe tags' do
      let(:reference) { create :unknown_reference, citation: 'Latreille, 1809 <script>xss</script>' }

      it "sanitizes them" do
        expect(described_class["{ref #{reference.id}} <script>xss</script>"]).to_not include 'script'
      end
    end

    context "when input is nil" do
      specify { expect(described_class[nil]).to eq '' }
    end
  end
end
