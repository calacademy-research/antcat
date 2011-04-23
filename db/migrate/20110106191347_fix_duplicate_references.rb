class FixDuplicateReferences < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      [18, 223, 27, 225, 23, 226, 24, 227, 16, 221, 229, 222, 228, 67, 7, 77, 78, 239, 109, 111, 112, 117, 241,
      121, 242, 243, 220, 244, 246, 240, 247, 248, 108, 136, 84, 238, 250, 81, 147, 148, 154, 255, 256,
      54, 160, 168, 95, 257, 178, 199, 215, 167
      ].each do |id|
        DuplicateReference.find(id).resolve
      end

      DuplicateReference.merge 124506, 124530
      DuplicateReference.merge 122730, 127267
      DuplicateReference.merge 127252, 128644
      DuplicateReference.merge 122454, 124093
      DuplicateReference.merge 123954, 123424
      DuplicateReference.merge 129164, 123963
      DuplicateReference.merge 122684, 127847
      DuplicateReference.merge 131775, 131777
      DuplicateReference.merge 127918, 127921
      DuplicateReference.merge 131579, 132510
      DuplicateReference.merge 122484, 123365
      DuplicateReference.merge 125123, 124656

      DuplicateReference.merge 123023, 122499
    end
  end

  def self.down
  end
end
