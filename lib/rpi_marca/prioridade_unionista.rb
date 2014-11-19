module RpiMarca
  class PrioridadeUnionista
    attr_reader :numero, :data, :pais

    def initialize(numero:, data:, pais:)
      @numero = numero
      @data = data
      @pais = pais
    end
  end
end
