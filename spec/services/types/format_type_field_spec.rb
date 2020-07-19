# frozen_string_literal: true

require 'rails_helper'

describe Types::FormatTypeField do
  describe '#call' do
    context 'with unsafe tags' do
      it "sanitizes them" do
        content = '<script>xss</script>'
        expect(described_class[content]).to eq "xss"
      end

      it "does not remove <i> tags" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content]).to eq "<i>italics<i><i>xss</i></i></i>"
      end
    end

    context 'when there are institutions in the database' do
      before do
        create :institution, :casc
      end

      it 'expands institution abbreviations' do
        expect(described_class['CASC']).to eq "<abbr title='California Academy of Sciences'>CASC</abbr>"
      end
    end
  end
end
