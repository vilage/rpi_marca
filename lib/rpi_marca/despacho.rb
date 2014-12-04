module RpiMarca
  class Despacho
    attr_reader :codigo, :descricao, :protocolo, :complemento,
                :protocolos_complemento

    # 850130127025 de 02/07/2013, 850130131596 de 08/07/2013
    PROTOCOLOS_TEXTO_COMPL = %r{
      (?<protocolo>[0-9]{12,})            # 850130127025
      \s                                  # espaço
      de
      \s
      (?<data>[0-9]{2}/[0-9]{2}/[0-9]{4}) # 02/07/2013
    }x

    def initialize(codigo:, descricao:, complemento:, protocolo:)
      @codigo = codigo or fail ParseError
      @descricao = descricao or fail ParseError
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
        protocolo: Protocolo.parse(el.at_xpath("protocolo"), codigo),
        complemento: Helpers.get_element_value(
          el.at_xpath("texto-complementar")
        )
      )
    end

    private

    def parse_texto_complementar
      @protocolos_complemento =
        @complemento.scan(PROTOCOLOS_TEXTO_COMPL).map do |protocolo, data|
          Protocolo.new(
            numero: protocolo,
            data: Helpers.parse_date(data)
          )
        end
    end
  end
end
