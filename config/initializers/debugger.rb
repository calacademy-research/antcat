# coding: UTF-8
module Debugger
  class QuitCommand
    def execute
      # patch so debugger doesn't prompt to quit
      #if @match[1] or confirm(pr("quit.confirmations.really"))
        @state.interface.finalize
        exit! # exit -> exit!: No graceful way to stop threads...
      #end
    end
  end
end
