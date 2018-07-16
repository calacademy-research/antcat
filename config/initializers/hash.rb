# This funny monkey patch became part of the main code by mistake (oops).
# TODO remove.

Hash.class_eval do
  def each_item_in_arrays options = {}
    return to_enum(:each_item_in_arrays, without_keys: true).to_a unless block_given?

    if options.fetch(:without_keys) { false }
      each { |_key, array| array.each { |item| yield item } }
    else
      each { |key, array| array.each { |item| yield item, key } }
    end
  end

  def each_item_in_arrays_alias name
    singleton_class.send :alias_method, name, :each_item_in_arrays
  end
end
