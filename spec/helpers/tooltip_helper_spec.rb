require 'spec_helper'

describe TooltipHelper do
  describe "#db_tooltip_icon" do
    context 'when tooltip exists' do
      context 'with unsafe tags' do
        let!(:tooltip) { create :tooltip, key: 'xss', scope: 'injection', text: '<script>xss</script>' }

        it "sanitizes them" do
          results = helper.db_tooltip_icon('xss', scope: 'injection')
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include '"xss"'
        end
      end
    end
  end
end
