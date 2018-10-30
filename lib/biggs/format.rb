module Biggs
  class Format
    attr_reader :iso_code, :format_string, :school_country_id

    def initialize(iso_code, country_id)
      @iso_code = iso_code
      @format_string = Biggs.formats[@iso_code]
      @school_country_id = country_id
    end

    def country_name
      if @school_country_id == Concerns::DomainDataCache::CHINA_COUNTRY_ID
        Biggs.china_country_names[@iso_code]
      else
        Biggs.country_names[@iso_code]
      end
    end

    class << self
      def find(country_id, iso_code)
        entries_cache[iso_code] ||= new(iso_code, country_id)
      end

      private

      def entries_cache
        @entries_cache ||= {}
      end
    end
  end
end
