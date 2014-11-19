module RpiMarca
  class ClasseLogotipo
    attr_reader :edicao, :classe1, :classe2, :classe3, :classe4, :classe5

    def initialize(edicao:, classe1:, classe2:, classe3:, classe4:, classe5:)
      @edicao = edicao
      @classe1 = classe1
      @classe2 = classe2
      @classe3 = classe3
      @classe4 = classe4
      @classe5 = classe5
    end
  end
end
