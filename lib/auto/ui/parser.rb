require("auto/ui/session")
require("json")

module Auto
  module Ui
    class Parser
      def initialize(file)
        @session = Session.new
        @data = JSON.parse(File.read(file))
      end

      def run
        @data.each do |list|
          @session.send(list[0], *list.slice(1..-1))
        end
      end
    end
  end
end
