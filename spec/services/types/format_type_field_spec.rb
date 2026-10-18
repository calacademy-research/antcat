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

    context 'with tags inside attribute values' do
      let(:taxon) { create :family }

      it 'does not expand them inside attributes' do
        create :institution, :casc

        [
          %(<b title="CASENT0000001 <img src=x onerror=1>">x</b>),
          %(<b title="{#{Taxt::TAX_TAG} #{taxon.id}} <img src=x onerror=1>">x</b>),
          %(<abbr title="CASC CASENT0000001 <img src=x onerror=1>">x</abbr>)
        ].each do |content|
          formatted = described_class[content]
          fragment = Nokogiri::HTML5.fragment(formatted)

          expect(fragment.css('img, [onerror], a')).to be_empty
          expect(formatted).not_to include '<img'
        end
      end

      it 'still expands them in text' do
        formatted = described_class[%(<b title="hint">CASENT0000001 {#{Taxt::TAX_TAG} #{taxon.id}}</b>)]

        expect(formatted).to include %(<b title="hint">), "specimen.do?name=CASENT0000001", %(href="/catalog/#{taxon.id}")
      end

      it 'does not expand catalog tags in institution names' do
        create :institution, abbreviation: 'XYZ', name: "{#{Taxt::TAX_TAG} #{taxon.id}} <img src=x onerror=1>"

        formatted = described_class['XYZ']

        expect(Nokogiri::HTML5.fragment(formatted).css('img, [onerror], a')).to be_empty
      end
    end
  end
end
