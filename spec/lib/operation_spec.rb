# frozen_string_literal: true

require 'rails_helper'

describe Operation do
  describe '#run' do
    context 'when `#execute` is not implemented' do
      let(:dummy_class) { Class.new { include Operation } }

      specify { expect { dummy_class.new.run }.to raise_error(NotImplementedError) }
    end
  end

  describe 'delegation' do
    let(:dummy_class) { Class.new { include Operation } }
    let(:dummy) { dummy_class.new }

    it { expect(dummy).to delegate_method(:success?).to(:context) }
    it { expect(dummy).to delegate_method(:failure?).to(:context) }
  end
end
