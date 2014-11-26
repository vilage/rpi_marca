module RpiMarca
  class PrioridadeUnionista
    attr_reader :numero, :data, :pais

    def initialize(numero:, data:, pais:)
      raise ParseError, "Publicação unionista deve ter data da prioridade" unless data

      @numero = numero
      @data = data
      @pais = pais
    end

    def self.parse(el)
      return unless el

      new(
        numero: Publicacao.get_attribute_value(el, "numero"),
        data: Publicacao.parse_date(Publicacao.get_attribute_value(el, "data")),
        pais: Publicacao.get_attribute_value(el, "pais")
      )
    end
  end
end
