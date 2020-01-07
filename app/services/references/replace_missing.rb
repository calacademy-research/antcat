module References
  class ReplaceMissing
    include Service

    def initialize missing_reference, target_reference
      @missing_reference = missing_reference
      @target_reference = target_reference
    end

    def call
      # These cases should not happen, but let's raise if that happens.
      raise 'must be missing' unless missing_reference.is_a? MissingReference
      raise 'cannot have nestees' if missing_reference.nestees.exists?
      raise 'cannot have linked citations' if Citation.where(reference: missing_reference).exists?

      replace_all!
    end

    private

      attr_reader :missing_reference, :target_reference

      def replace_all!
        Taxt::TAXTABLES.each do |(model, _table, field)|
          model.where("#{field} LIKE '%{ref #{missing_reference.id}}%'").find_each do |match|
            content = match.public_send(field)
            new_content = replace_ref_tags content
            match.public_send("#{field}=", new_content)
            match.save!
          end
        end
      end

      def replace_ref_tags content
        content.gsub("{ref #{missing_reference.id}}", "{ref #{target_reference.id}}")
      end
  end
end
