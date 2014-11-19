module RpiMarca
  class Protocolo
    attr_reader :numero, :data, :codigo_servico, :procurador, :requerente, :cedente, :cessionario

    def initialize(numero:, data:, codigo_servico: nil, procurador: nil, requerente: nil, cedente: nil, cessionario: nil)
      @numero = numero
      @data = data
      @codigo_servico = format_codigo_servico(codigo_servico)
      @procurador = procurador
      @requerente = requerente
      @cedente = cedente
      @cessionario = cessionario
    end

    private
    def format_codigo_servico(codigo)
      return unless codigo

      "#{codigo[0...3]}.#{codigo[3..-1]}".chomp(".")
    end
  end
end
