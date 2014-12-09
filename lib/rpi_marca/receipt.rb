module RpiMarca
  class Receipt
    attr_reader :number, :date, :service_code, :agent,
                :applicant, :assignor, :assignee

    IPAS_RECEIPT_NOT_REQUIRED = %w(
      IPAS005 IPAS009 IPAS024 IPAS033 IPAS029 IPAS047 IPAS091 IPAS106 IPAS112
      IPAS135 IPAS136 IPAS139 IPAS142 IPAS157 IPAS158 IPAS161 IPAS289 IPAS291
      IPAS304 IPAS395 IPAS402 IPAS404 IPAS409 IPAS421 IPAS423
    )

    def initialize(number:, date:, service_code: nil, agent: nil,
                   applicant: nil, assignor: nil, assignee: nil)
      @number = number
      @date = date
      @service_code = format_service_code(service_code)
      @agent = agent
      @applicant = applicant
      @assignor = assignor
      @assignee = assignee
    end

    def self.parse(el, rule_code)
      return if el.nil? && IPAS_RECEIPT_NOT_REQUIRED.include?(rule_code)

      number = Helpers.get_attribute_value(el, 'numero') or
        fail ParseError, 'Receipt number is required'
      date = Helpers.get_attribute_value(el, 'data') or
        fail ParseError, 'Receipt date is required'

      new(
        number: number,
        date: Helpers.parse_date(date),
        **optional_params(el)
      )
    end

    def self.optional_params(el)
      {
        service_code: Helpers.get_attribute_value(el, 'codigoServico'),
        agent: Helpers.get_element_value(el.at_xpath('procurador')),
        applicant: Titular.parse(el.at_xpath('requerente')),
        assignor: Titular.parse(el.at_xpath('cedente')),
        assignee: Titular.parse(el.at_xpath('cessionario'))
      }
    end

    private_class_method :optional_params

    private

    def format_service_code(code)
      "#{code[0...3]}.#{code[3..-1]}".chomp('.') if code
    end
  end
end
