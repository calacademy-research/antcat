module TestOperations
  class NestedSaveJournal
    include Operation

    def initialize journal_1, new_name_1, journal_2, new_name_2
      @journal_1 = journal_1
      @new_name_1 = new_name_1
      @journal_2 = journal_2
      @new_name_2 = new_name_2
    end

    def execute
      TestOperations::SaveJournal.new(journal_1, new_name_1).run(context)
      TestOperations::SaveJournal.new(journal_2, new_name_2).run(context)
    end

    private

      attr_reader :journal_1, :new_name_1, :journal_2, :new_name_2
  end
end
