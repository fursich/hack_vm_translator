require 'ostruct'

module Configurable
  def self.included(klass)
    klass.extend ClassMethods
  end

  def config
    @_config ||= self.class.config
  end

  module ClassMethods
    def config
      @_config ||= Configuration.new
    end

    def configure
      yield config
    end

    class Configuration < ::OpenStruct; end
  end
end