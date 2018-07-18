module DatabaseScripts
  module EndData
    private

      # The script's description and tags are stored in `DATA`.
      def end_data
        @end_data ||= HashWithIndifferentAccess.new YAML.safe_load(read_end_data)
      end

      # For reading the script's `DATA` (everything under `__END__` in the source);
      # just calling `DATA` doesn't always work in subclasses, mixins, etc.
      def read_end_data
        data = StringIO.new
        File.open(script_path) do |f|
          begin
            line = f.gets
          end until line.nil? || line.match(/^__END__$/)
          while line = f.gets
            data << line
          end
        end
        data.rewind
        data
      end
  end
end
