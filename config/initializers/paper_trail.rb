# frozen_string_literal: true

# TODO: Hack for PaperTrail 12. See https://github.com/paper-trail-gem/paper_trail/issues/1305
#
# This can probably be removed if tests pass without it. Before adding it there were failures like these:
#   NoMethodError: undefined method `search' for #<Class:0x00005636cbee64b8>
#   NameError: uninitialized constant #<Class:0x00005636cbee64b8>::CREATE_EVENT

module PaperTrail
  remove_const :Version
end
