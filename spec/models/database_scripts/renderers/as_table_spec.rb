# frozen_string_literal: true

require 'rails_helper'

class AsTableDummy < DatabaseScripts::DatabaseTestScript
  def as_table
    renderer = DatabaseScripts::Renderers::AsTable.new(cached_results)
    yield renderer
    renderer.render
  end
end

describe DatabaseScripts::Renderers::AsTable do
  let(:dummy) { AsTableDummy.new }

  describe "#render" do
    context 'with results' do
      let!(:taxon_1) { create :any_taxon }

      it 'renders the supplied `results` as an HTML table' do
        rendered =
          dummy.as_table do |t|
            t.header 'Taxon', 'Status'

            t.rows(Taxon.all) do |taxon|
              [taxon.id, taxon.status]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="table-striped" data-controller="tablesort">
            <thead>
              <tr>
                <th>Taxon</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody><tr><td>#{taxon_1.id}</td><td>#{taxon_1.status}</td></tr>
            </tbody>
          </table>
        HTML
      end
    end

    context 'with `caption` and `info`' do
      specify do
        rendered =
          dummy.as_table do |t|
            t.caption "caption field"
            t.info "info field"
            t.header 'header1', 'header2'

            t.rows(['pizza']) do |string|
              [string]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="table-striped" data-controller="tablesort">
            <caption>caption field</caption>
            <caption>info field</caption>
            <thead>
              <tr>
                <th>header1</th>
                <th>header2</th>
              </tr>
            </thead>
            <tbody><tr><td>pizza</td></tr>
            </tbody>
          </table>
        HTML
      end
    end

    context 'with HTML in plain strings' do
      let(:payload) { %(Lasius <img src=x onerror="alert(1)"> <script>alert(2)</script>) }

      it 'removes active content from cells, headers and captions' do
        rendered =
          dummy.as_table do |t|
            t.caption payload
            t.header payload

            t.rows(['pizza']) do |_string|
              [payload, %(<a href="javascript:alert(3)" onclick="alert(4)">link</a>)]
            end
          end

        expect(rendered).not_to include '<img', '<script', 'onerror', 'onclick', 'javascript:', 'alert(2)'
        expect(rendered).to include 'Lasius', '>link</a>'
      end

      it 'keeps formatting tags and links built by the app' do
        taxon = create :any_taxon
        cell = "<i>#{taxon.name.name}</i><br>#{CatalogFormatter.link_to_taxon(taxon)}"

        rendered = dummy.as_table { |t| t.rows(['pizza']) { [cell] } }

        expect(rendered).to include "<i>#{taxon.name.name}</i><br>", %(data-controller="hover-preview"),
          %(data-hover-preview-url-value="/catalog/#{taxon.id}/hover_preview.json"), %(href="/catalog/#{taxon.id}")
      end

      it 'does not change values marked as html_safe' do
        cell = %(<span data-testid="x">trusted</span>).html_safe

        rendered = dummy.as_table { |t| t.rows(['pizza']) { [cell] } }

        expect(rendered).to include cell
      end

      it 'drops `data-method` and `data-remote` from plain strings, also on quick-fix links' do
        quick_fix = %(<a data-method="post" data-remote="true" rel="nofollow" ) +
          %(href="/quick_and_dirty_fixes/delete_history_item_quick_and_dirty_fix?history_item_id=1">Fix</a>)
        other = %(<a data-method="patch" href="/users/1?user%5Bsuperadmin%5D=1">Other</a>)

        rendered = dummy.as_table { |t| t.rows(['pizza']) { [quick_fix, other] } }

        expect(rendered).to include '<a href="/users/1?user%5Bsuperadmin%5D=1">Other</a>',
          'href="/quick_and_dirty_fixes/delete_history_item_quick_and_dirty_fix?history_item_id=1">Fix</a>'
        expect(rendered).not_to include 'data-method', 'data-remote'
      end

      it 'keeps `data-method` and `data-remote` on html_safe quick-fix links' do
        quick_fix = %(<a data-method="post" data-remote="true" rel="nofollow" ) +
          %(href="/quick_and_dirty_fixes/delete_history_item_quick_and_dirty_fix?history_item_id=1">Fix</a>)

        rendered = dummy.as_table { |t| t.rows(['pizza']) { [quick_fix.html_safe] } }

        expect(rendered).to include 'data-method="post"', 'data-remote="true"'
      end

      it 'drops attributes containing catalog tags' do
        taxon = create :any_taxon
        cell = %(<span title="{#{Taxt::TAX_TAG} #{taxon.id}}<img src=x onerror=alert(1)>">x</span>)

        rendered = dummy.as_table { |t| t.rows(['pizza']) { [cell] } }

        expect(rendered).not_to include 'onerror'
        expect(rendered).to include '<span>x</span>'
      end
    end

    context 'when the block yields a falsey value' do
      let!(:taxon_1) { create :any_taxon }
      let!(:taxon_2) { create :any_taxon }

      it 'skips that row' do
        rendered =
          dummy.as_table do |t|
            t.header 'Taxon', 'Status'

            t.rows(Taxon.all) do |taxon|
              next if taxon.id == taxon_1.id
              [taxon.id, taxon.status]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="table-striped" data-controller="tablesort">
            <thead>
              <tr>
                <th>Taxon</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody><tr><td>#{taxon_2.id}</td><td>#{taxon_2.status}</td></tr>
            </tbody>
          </table>
        HTML
      end
    end
  end
end
