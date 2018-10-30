require 'biggs/format'
require 'biggs/formatter'
require 'yaml'

module Biggs
  class << self
    def formats
      @@formats ||= YAML.load_file(File.join(File.dirname(__FILE__), '..', 'formats.yml')) || {}
    end

    def country_names
      Rails.cache.fetch("biggs_#{lang_prefix}") do
        DataCountry.where.not(alpha2: nil).pluck(:alpha2, "#{lang_prefix}name").to_h
      end
    end

    def china_country_names
      Rails.cache.fetch("biggs_#{lang_prefix}_CN") do
        DataCountry.where.not(alpha2: nil).pluck(:alpha2, "#{lang_prefix}name").to_h
                   .each_with_object({}) do |(k, v), h|
          h[k] = v.political_name(Concerns::DomainDataCache::CHINA_COUNTRY_ID)
        end
      end
    end

    private

    def lang_prefix
      if ApplicationRecord.locale_in_english?
        ''
      else
        I18n.locale.to_s.underscore + '_'
      end
    end
  end
end

if defined?(ActiveRecord) and defined?(ActiveRecord::Base) and !ActiveRecord::Base.respond_to?(:biggs_formatter)
  require 'biggs/activerecord'
  ActiveRecord::Base.send :include, Biggs::ActiveRecordAdapter
end
