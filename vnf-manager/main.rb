#
# TeNOR - VNF Manager
#
# Copyright 2014-2016 i2CAT Foundation, Portugal Telecom Inovação
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 
#
# Set environment
ENV['RACK_ENV'] ||= 'development'

require 'sinatra'
require 'sinatra/config_file'
require 'yaml'
require 'logstash-logger'

# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
# Bundler is really important for this class
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

class VNFManager < Sinatra::Application

  require_relative 'routes/init'
  require_relative 'helpers/init'
  require_relative 'models/serviceModel'

  register Sinatra::ConfigFile
# Load configurations
  config_file 'config/config.yml'
  Mongoid.load!('config/mongoid.yml')

  configure do
    # Configure logging
    logger = LogStashLogger.new(
        type: :multi_logger,
        outputs: [
            {type: :stdout, formatter: ::Logger::Formatter},
            {type: :file, path: "log/#{settings.environment}.log", sync: true},
            {host: settings.logstash_host, port: settings.logstash_port, sync: false}
        ])
    LogStashLogger.configure do |config|
      config.customize_event do |event|
        event["module"] = settings.servicename
      end
    end
    set :logger, logger
  end

  before do
    env['rack.logger'] = settings.logger
  end

  helpers ManagerHelper
end
