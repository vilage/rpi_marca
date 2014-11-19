require 'rpi_marca/protocolo'

module RpiMarca
  class Despacho
    attr_reader :codigo, :descricao, :protocolo, :complemento, :protocolos_complemento

    PROTOCOLOS_TEXTO_COMPLEMENTAR = Regexp.new(/(?<protocolo>[0-9]{12,}) de (?<dataprotocolo>[0-9]{2}\/[0-9]{2}\/[0-9]{4})/)

    def initialize(codigo:, descricao:, complemento:, protocolo:)
      @codigo = codigo
      @descricao = descricao
      @complemento = complemento
      @protocolo = protocolo
      @protocolos_complemento = []

      parse_texto_complementar if @complemento
    end

    def parse_texto_complementar
      @complemento.scan(PROTOCOLOS_TEXTO_COMPLEMENTAR).each do |protocolo, data|
        @protocolos_complemento << Protocolo.new(
          numero: protocolo,
          data: Publicacao.parse_date(data)
        )
      end
    end
  end
end
