require "logger"
require "r18n-core"
require "rubycas-server-core/version"
require "rubycas-server-core/error"
require "rubycas-server-core/authenticator"
require "rubycas-server-core/settings"
require "rubycas-server-core/database"
require "rubycas-server-core/util"
require "rubycas-server-core/tickets/generations"
require "rubycas-server-core/tickets/validations"
require "rubycas-server-core/tickets"

module RubyCAS
  def self.root
    File.dirname __dir__
  end

  module Server
    module Core
      extend self

      # Read configuration from given file
      # and setup database.
      # Database object is provided by one of the adapter.
      # Please visit: https://github.com/rubycas/rubycas-server-core/wiki
      # for available adapters.
      def setup(config_file)
        Settings.load!(config_file)
        R18n.default_places = '../locales'
        R18n.set(Settings.default_locale)
        $LOG = Logger.new(Settings.log[:output] || STDOUT)
        $LOG.level = Logger.const_get(Settings.log[:level]) || Logger::ERROR
        Database.setup(Settings.database)
      end
    end
  end
end
