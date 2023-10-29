require_relative "src/runner"

runner = Runner.new
runner.load_initial_data
runner.init_curses
runner.loop
