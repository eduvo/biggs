module Biggs
  class Formatter
    FIELDS = [:recipient, :street, :city, :state, :zip, :country].freeze

    def initialize(options = {})
      @blank_country_on = [options[:blank_country_on]].compact.flatten.map { |s| s.to_s.downcase }
      @school_country_id = options[:school_country_id]
    end

    def format(iso_code, values = {})
      values.symbolize_keys! if values.respond_to?(:symbolize_keys!)

      format = Biggs::Format.find(@school_country_id, iso_code)
      format_string = (format.format_string || default_format_string(values[:state])).dup.to_s
      country_name = blank_country_on.include?(format.iso_code) ? '' : format.country_name || format.iso_code

      (FIELDS - [:country]).each do |key|
        format_string.gsub!(/\{\{#{key}\}\}/, (values[key] || '').to_s)
      end
      format_string.gsub!(/\{\{country\}\}/, country_name.to_s)
      format_string.gsub(/\n$/, '')
    end

    attr_accessor :blank_country_on, :default_country_without_state, :default_country_with_state, :school_country_id

    private

    def default_format_string(state)
      state && state != '' ?
        Biggs.formats[default_country_with_state || 'us'] :
        Biggs.formats[default_country_without_state || 'fr']
    end
  end
end
