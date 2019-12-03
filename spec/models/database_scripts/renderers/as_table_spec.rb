require 'rails_helper'

class AsTableDummy < DatabaseScripts::DatabaseTestScript
  include DatabaseScripts::Renderers::AsTable
end

describe DatabaseScripts::Renderers::AsTable do
  let(:dummy) { AsTableDummy.new }

  describe "#as_as_table" do
    context "with explicit `results`" do
      let!(:taxon) { create :family }

      it 'renders the supplied `results` as an HTML table' do
        rendered =
          dummy.as_table do |t|
            t.caption "My favorite ants"
            t.header :taxon, :status

            t.rows(Taxon.all) do |taxon|
              [taxon.id, taxon.status]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="tablesorter hover margin-top">
            <caption>My favorite ants</caption>
            <thead><tr>
              <th>Taxon</th>
              <th>Status</th>
              </tr>
            </thead>
            <tbody><tr><td>#{taxon.id}</td><td>#{taxon.status}</td></tr>
            </tbody>
          </table>
        HTML
      end
    end
  end
end
