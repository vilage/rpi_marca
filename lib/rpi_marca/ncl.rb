module RpiMarca
  class Ncl
    attr_reader :classe, :edicao, :especificacao

    def initialize(classe:, edicao:, especificacao:)
      raise ParseError, "NCL #{classe} inválida" unless (1..45).include?(classe.to_i)

      @classe = classe
      @edicao = edicao if edicao > 0
      @especificacao = especificacao
    end
  end
end
