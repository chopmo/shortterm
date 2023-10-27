require_relative "src/runner"

# Change to the directory the user ran this script from. See `run`.
Dir.chdir(ARGV[0])

runner = Runner.new
runner.load_initial_data
runner.loop
