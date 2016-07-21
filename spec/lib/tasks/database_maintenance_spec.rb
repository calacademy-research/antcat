# TODO test tasks
#
#  # Moved from spec/models/protonym_spec.rb
#  # TODO worth maintaining?
#  describe "Orphans" do
#    it "should delete the orphaned protonym(s) when the taxon is deleted" do
#      genus = create_genus
#      original_protonym_count = Protonym.count
#
#      orphan_protonym = create :protonym
#      expect(Protonym.count).to eq(original_protonym_count + 1)
#
#      Protonym.destroy_orphans
#
#      expect(Protonym.count).to eq(original_protonym_count)
#      expect(Protonym.all).not_to include(orphan_protonym)
#    end
#  end
