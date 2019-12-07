module TestOperations
  class SaveJournal
    include Operation

    def initialize journal, new_name
      @journal = journal
      @new_name = new_name
    end

    def execute
      unless journal.update(name: new_name)
        fail! journal.errors.full_messages.to_sentence
      end
    end

    private

      attr_reader :journal, :new_name
  end
end
