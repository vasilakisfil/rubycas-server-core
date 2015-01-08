require 'yaml'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

module RubyCAS
  module Server
    module Core
      module Settings
        extend self

        @_settings = HashWithIndifferentAccess.new
        attr_reader :_settings

        def load!(config)
          
          if config.is_a? String
            config_dir = File.join RubyCAS.root, config
            @_settings.merge! YAML::load_file(config_dir).with_indifferent_access
          elsif config.is_a? Hash
            @_settings.merge!(config)
          end
        end

        def method_missing(name, *args, &block)
          @_settings[name.to_sym] || fail(NoMethodError, "unknown configuration: #{name}", caller)
        end

      end
    end
  end
end
