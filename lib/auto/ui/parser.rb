require("auto/ui/session")
require("json")

module Auto
  module Ui
    class Parser
      def initialize(file)
        @session = Session.new
        @data = JSON.parse(File.read(file))
        @macros = []
      end

      def run
        run_steps(@data)
      end

      def run_steps(steps)
        if steps.kind_of? Array
          steps.each do |step|
            run_action(step)
          end
        else
          @macros.unshift(steps["macros"]) if steps["macros"]
          run_steps(steps["steps"])
          @macros.shift() if steps["macros"]
        end
      end

      def run_action(step, is_macro = false)
        if step.kind_of? Array
          @session.send(step[0], *step.slice(1..-1))
        elsif !is_macro && step.kind_of?(String)
          run_macro(step)
        elsif step.kind_of? String
          @session.send(step)
        else
          run_steps(step)
        end
      end

      def run_macro(name)
        list = @macros.find { |list| list[name] }
        list ? run_action(list[name]) : @session.send(name)
      end
    end
  end
end
