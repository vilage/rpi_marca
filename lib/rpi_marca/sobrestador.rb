module RpiMarca
  class Sobrestador
    attr_reader :processo, :marca

    def initialize(processo:, marca:)
      @processo = processo
      @marca = marca
    end
  end
end
