require "funcify/version"
require 'dry/monads/result'
require 'dry/monads/try'


module Funcify
  autoload :Fn, 'funcify/fn'
  autoload :Afn, 'funcify/afn'
  autoload :Map, 'funcify/map'
  autoload :Record, 'funcify/record'
end
