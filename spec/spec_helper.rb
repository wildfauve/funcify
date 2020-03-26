require "bundler/setup"
require "funcify"
require 'pry'

M = Dry::Monads

Monad = Funcify::Monad
Cond  = Funcify::Cond
Fn    = Funcify::Fn
Map   = Funcify::Map
Str   = Funcify::Str
FSet  = Funcify::FSet

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
