module RpiMarca
  class Ncl
    attr_reader :number, :edition, :goods_services

    def initialize(number:, edition:, goods_services:)
      fail ParseError, "NCL class #{number} out of range (1-45)" unless
        (1..45).include?(number.to_i)

      @number = number
      @edition = edition if edition > 0
      @goods_services = goods_services
    end

    def self.parse(el)
      return unless el

      new(
        number: Helpers.get_attribute_value(el, 'codigo'),
        edition: Helpers.get_attribute_value(el, 'edicao').to_i,
        goods_services: Helpers.get_element_value(
          el.at_xpath('.//especificacao')
        )
      )
    end
  end
end
