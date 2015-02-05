module RpiMarca
  class NationalClass
    attr_reader :number, :subclass1, :subclass2, :subclass3, :goods_services

    def initialize(number:, subclass1:, subclass2:, subclass3:,
                   goods_services:)
      fail ParseError, "National class #{classe} out of range (1-41)" unless
        (1..41).include?(number.to_i)

      @number = number
      @subclass1 = subclass1 if subclass1 > 0
      @subclass2 = subclass2 if subclass2 > 0
      @subclass3 = subclass3 if subclass3 > 0
      @goods_services = goods_services
    end

    def to_s
      subclasses = [
        @subclass1,
        @subclass2,
        @subclass3
      ].compact.join('.')

      "#{@number}/#{subclasses}"
    end

    def self.parse(el)
      return unless el

      subclass = parse_subclass(el)

      new(
        number: Helpers.get_attribute_value(el, 'codigo').to_i,
        **subclass,
        goods_services: Helpers.get_element_value(
          el.at_xpath('.//especificacao')
        )
      )
    end

    def self.parse_subclass(el)
      subclass = el.xpath('.//sub-classe-nacional').map { |s| s['codigo'] }
      fail ParseError, "National class can't have more than 3 subclasses" if
        subclass.length > 3

      {
        subclass1: subclass[0].to_i,
        subclass2: subclass[1].to_i,
        subclass3: subclass[2].to_i

      }
    end

    private_class_method :parse_subclass
  end
end
