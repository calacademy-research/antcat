# frozen_string_literal: true

require 'rails_helper'

describe PaperTrail::VersionDecorator do
  subject(:decorated) { version.decorate }

  describe "#revision_history_link" do
    let(:item) { build_stubbed :issue }
    let(:version) { build_stubbed :version, item: item }

    specify do
      expect(decorated.revision_history_link).
        to eq %(<a class="btn-normal btn-tiny" href="/issues/#{item.id}/history">History</a>)
    end
  end
end
