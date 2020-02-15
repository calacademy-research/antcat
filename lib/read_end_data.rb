class ReadEndData
  def initialize file
    @file = file
  end

  def call
    HashWithIndifferentAccess.new YAML.safe_load(read_end_data)
  end

  private

    attr_reader :file

    # For reading `DATA` (everything under `__END__` in the source file);
    # just calling `DATA` doesn't always work in subclasses, mixins, etc.
    def read_end_data
      _app, data = File.read(file).split(/^__END__$/, 2)
      data || ''
    end
end
