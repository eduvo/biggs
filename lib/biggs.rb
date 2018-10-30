require 'biggs/format'
require 'biggs/formatter'
require 'yaml'

module Biggs
  class << self
    def formats
      @@formats ||= YAML.load_file(File.join(File.dirname(__FILE__), '..', 'formats.yml')) || {}
    end

    def country_names
      @@country_names ||= YAML.load_file(File.join(File.dirname(__FILE__), '..', 'country_names.yml')) || {}
    end

    def china_country_names
      lang_prefix = if ApplicationRecord.locale_in_english?
        ''
      else
        I18n.locale.to_s.underscore + '_'
      end
      Rails.cache.fetch("biggs_#{lang_prefix}_CN") do
        DataCountry.where.not(alpha2: nil).pluck("#{lang_prefix}name", :alpha2).inject({}) do |res, i|
          res[i[1].downcase] = i[0]
        end
      end
    end
  end
end

if defined?(ActiveRecord) and defined?(ActiveRecord::Base) and !ActiveRecord::Base.respond_to?(:biggs_formatter)
  require 'biggs/activerecord'
  ActiveRecord::Base.send :include, Biggs::ActiveRecordAdapter
end
