module RpiMarca
  class Protocolo
    attr_reader :numero, :data, :codigo_servico, :procurador,
                :requerente, :cedente, :cessionario

    DESPACHOS_SEM_PROTOCOLO = %w(
      IPAS005 IPAS009 IPAS024 IPAS033 IPAS029 IPAS047 IPAS091 IPAS106 IPAS112
      IPAS135 IPAS136 IPAS139 IPAS142 IPAS157 IPAS158 IPAS161 IPAS289 IPAS291
      IPAS304 IPAS395 IPAS402 IPAS404 IPAS409 IPAS421 IPAS423
    )

    def initialize(numero:, data:, codigo_servico: nil, procurador: nil,
                   requerente: nil, cedente: nil, cessionario: nil)
      @numero = numero
      @data = data
      @codigo_servico = format_codigo_servico(codigo_servico)
      @procurador = procurador
      @requerente = requerente
      @cedente = cedente
      @cessionario = cessionario
    end

    def self.parse(el, codigo_despacho)
      return if el.nil? && DESPACHOS_SEM_PROTOCOLO.include?(codigo_despacho)

      numero = Helpers.get_attribute_value(el, "numero") or
        fail ParseError, "Número do Protocolo é obrigatório"
      data = Helpers.get_attribute_value(el, "data") or
        fail ParseError, "Data do Protocolo é obrigatória"

      new(
        numero: numero,
        data: Helpers.parse_date(data),
        **optional_params(el)
      )
    end

    def self.optional_params(el)
      {
        codigo_servico: Helpers.get_attribute_value(el, "codigoServico"),
        procurador: Helpers.get_element_value(el.at_xpath("procurador")),
        requerente: Titular.parse(el.at_xpath("requerente")),
        cedente: Titular.parse(el.at_xpath("cedente")),
        cessionario: Titular.parse(el.at_xpath("cessionario"))
      }
    end

    private_class_method :optional_params

    private

    def format_codigo_servico(codigo)
      return unless codigo

      "#{codigo[0...3]}.#{codigo[3..-1]}".chomp(".")
    end
  end
end
