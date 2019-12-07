module TestOperations
  class BangSaveJournal
    include Operation

    def initialize journal, new_name
      @journal = journal
      @new_name = new_name
    end

    def execute
      journal.update!(name: new_name)
    end

    private

      attr_reader :journal, :new_name
  end
end
