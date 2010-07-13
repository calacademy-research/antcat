Given 'the following entry exists in the bibliography' do |table|
  table.hashes.each do |hash|
    Reference.create! hash
  end
end
