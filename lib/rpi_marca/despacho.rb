module RpiMarca
  class Despacho
    attr_reader :codigo, :descricao, :protocolo, :complemento, :protocolos_complemento

    PROTOCOLOS_TEXTO_COMPLEMENTAR = Regexp.new(%r{(?<protocolo>[0-9]{12,}) de (?<dataprotocolo>[0-9]{2}/[0-9]{2}/[0-9]{4})})

    def initialize(codigo:, descricao:, complemento:, protocolo:)
      @codigo = codigo or raise ParseError
      @descricao = descricao or raise ParseError
      @complemento = complemento
      @protocolo = protocolo
      @protocolos_complemento = []

      parse_texto_complementar if @complemento
    end

    def self.parse(el)
      codigo = Helpers.get_attribute_value(el, "codigo")

      new(
        codigo: codigo,
        descricao: Helpers.get_attribute_value(el, "nome"),
        complemento: Helpers.get_element_value(el.at_xpath("texto-complementar")),
        protocolo: Protocolo.parse(el.at_xpath("protocolo"), codigo)
      )
    end

    private

    def parse_texto_complementar
      @protocolos_complemento = @complemento.scan(PROTOCOLOS_TEXTO_COMPLEMENTAR).map do |protocolo, data|
        Protocolo.new(
          numero: protocolo,
          data: Helpers.parse_date(data)
        )
      end
    end
  end
end
