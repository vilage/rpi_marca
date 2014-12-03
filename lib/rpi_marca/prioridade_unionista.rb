module RpiMarca
  class PrioridadeUnionista
    attr_reader :numero, :data, :pais

    def initialize(numero:, data:, pais:)
      fail ParseError, "Publicação unionista deve ter data da prioridade" unless data

      @numero = numero
      @data = data
      @pais = pais
    end

    def self.parse(el)
      return unless el

      new(
        numero: Helpers.get_attribute_value(el, "numero"),
        data: Helpers.parse_date(Helpers.get_attribute_value(el, "data")),
        pais: Helpers.get_attribute_value(el, "pais")
      )
    end
  end
end
