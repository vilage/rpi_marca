module RpiMarca
  class Priority
    attr_reader :number, :date, :country

    def initialize(number:, date:, country:)
      fail ParseError,
           'Priority must have priority date' unless date

      @number = number
      @date = date
      @country = country
    end

    def self.parse(el)
      return unless el

      new(
        number: Helpers.get_attribute_value(el, 'numero'),
        date: Helpers.parse_date(Helpers.get_attribute_value(el, 'data')),
        country: Helpers.get_attribute_value(el, 'pais')
      )
    end
  end
end
