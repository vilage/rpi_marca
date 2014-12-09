module RpiMarca
  class Rule
    attr_reader :ipas, :description, :receipt, :complement,
                :complementary_receipts

    # 850130127025 de 02/07/2013, 850130131596 de 08/07/2013
    COMPLEMENTARY_RECEIPTS = %r{
      (?<receipt>[0-9]{12,})              # 850130127025
      \s                                  # space
      de
      \s
      (?<data>[0-9]{2}/[0-9]{2}/[0-9]{4}) # 02/07/2013
    }x

    def initialize(ipas:, description:, complement:, receipt:)
      @ipas = ipas or fail ParseError
      @description = description or fail ParseError
      @complement = complement
      @receipt = receipt
      @complementary_receipts = []

      parse_complementary_text if @complement
    end

    def self.parse(el)
      ipas = Helpers.get_attribute_value(el, 'codigo')

      new(
        ipas: ipas,
        description: Helpers.get_attribute_value(el, 'nome'),
        receipt: Receipt.parse(el.at_xpath('protocolo'), ipas),
        complement: Helpers.get_element_value(
          el.at_xpath('texto-complementar')
        )
      )
    end

    private

    def parse_complementary_text
      @complementary_receipts =
        @complement.scan(COMPLEMENTARY_RECEIPTS).map do |number, date|
          Receipt.new(
            number: number,
            date: Helpers.parse_date(date)
          )
        end
    end
  end
end
