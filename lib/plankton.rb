require 'stringio'
require 'recursive-open-struct'
require 'docker_registry2'

module Plankton
  class EnvVarNotFoundError < StandardError; end

  module Command; end
end

require 'plankton/version'
require 'plankton/monkey_patches'
require 'plankton/env_vars'
require 'plankton/helpers'

require 'plankton/commands/tag'
require 'plankton/commands/tags'
require 'plankton/commands/rmtag'
require 'plankton/commands/cleanup'
