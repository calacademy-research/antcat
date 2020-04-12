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
      let(:reference) { create :any_reference, title: 'pizza <script>xss</script>' }

      it "sanitizes them" do
        results = described_class["{ref #{reference.id}} <script>xss</script>"]
        expect(results).to include 'pizza xss'
        expect(results).to_not include 'script'
      end
    end

    context "when input is nil" do
      specify { expect(described_class[nil]).to eq nil }
    end
  end
end
