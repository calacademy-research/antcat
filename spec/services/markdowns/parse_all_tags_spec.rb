# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ParseAllTags do
  describe "#call" do
    context 'with unsafe tags' do
      it "does not sanitize them" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content.dup]).to eq content
      end
    end
  end
end
