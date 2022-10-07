# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScriptsPresenter do
  subject(:presenter) { described_class.new }

  describe '#tallied_tags' do
    it 'returns a tally of all tags actually used in database script files' do
      expect(presenter.tallied_tags).to include ['slow', be_a(Integer)]
    end
  end
end
