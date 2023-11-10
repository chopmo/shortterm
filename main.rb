require_relative "src/runner"

runner = Runner.new
runner.init_curses
runner.loop
