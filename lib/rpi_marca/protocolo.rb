module RpiMarca
  class Protocolo
    attr_reader :numero, :data, :codigo_servico, :procurador, :requerente, :cedente, :cessionario

    DESPACHOS_PROTOCOLO_NAO_OBRIGATORIO = [
      "IPAS005", "IPAS009", "IPAS024", "IPAS033", "IPAS029", "IPAS047",
      "IPAS091", "IPAS106", "IPAS112", "IPAS135", "IPAS136", "IPAS139",
      "IPAS142", "IPAS157", "IPAS158", "IPAS161", "IPAS289", "IPAS291",
      "IPAS304", "IPAS395", "IPAS402", "IPAS404", "IPAS409", "IPAS421",
      "IPAS423"
    ]

    def initialize(numero:, data:, codigo_servico: nil, procurador: nil, requerente: nil, cedente: nil, cessionario: nil)
      @numero = numero
      @data = data
      @codigo_servico = format_codigo_servico(codigo_servico)
      @procurador = procurador
      @requerente = requerente
      @cedente = cedente
      @cessionario = cessionario
    end

    def self.parse(el, codigo_despacho)
      return if el.nil? && DESPACHOS_PROTOCOLO_NAO_OBRIGATORIO.include?(codigo_despacho)

      numero = Publicacao.get_attribute_value(el, "numero") or raise ParseError, "Número do Protocolo é obrigatório. (Despacho: #{codigo_despacho}"
      data = Publicacao.get_attribute_value(el, "data") or raise ParseError, "Data do Protocolo é obrigatória. (Despacho: #{codigo_despacho}"

      new(
        numero: numero,
        data: Publicacao.parse_date(data),
        codigo_servico: Publicacao.get_attribute_value(el, "codigoServico"),
        procurador: Publicacao.get_element_value(el.at_xpath("procurador")),
        requerente: Titular.parse(el.at_xpath("requerente")),
        cedente: Titular.parse(el.at_xpath("cedente")),
        cessionario: Titular.parse(el.at_xpath("cessionario"))
      )
    end

    private
    def format_codigo_servico(codigo)
      return unless codigo

      "#{codigo[0...3]}.#{codigo[3..-1]}".chomp(".")
    end
  end
end
