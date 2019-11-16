require 'rails_helper'

class AsCSVDummy < DatabaseScripts::DatabaseTestScript
  include DatabaseScripts::Renderers::AsCSV
end

describe DatabaseScripts::Renderers::AsCSV do
  let(:dummy) { AsCSVDummy.new }

  describe "#as_csv" do
    let!(:reference) { create :article_reference }

    context "with implicit `results`" do
      it 'renders the scripts `#results` as CSV' do
        rendered =
          dummy.as_csv do |c|
            c.header :reference, :reference_type

            c.rows do |reference|
              [reference.id, reference.type]
            end
          end

        expect(rendered).to eq <<~CSV
          reference,reference_type
          #{reference.id},#{reference.type}
        CSV
      end
    end

    context "with explicit `results`" do
      let!(:taxon) { create :family }

      it 'renders the supplied `results` as CSV' do
        rendered =
          dummy.as_csv do |c|
            c.header :taxon, :status

            c.rows(Taxon.all) do |taxon|
              [taxon.id, taxon.status]
            end
          end

        expect(rendered).to eq <<~CSV
          taxon,status
          #{taxon.id},#{taxon.status}
        CSV
      end
    end
  end
end
