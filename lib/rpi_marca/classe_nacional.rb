module RpiMarca
  class ClasseNacional
    attr_reader :classe, :subclasse1, :subclasse2, :subclasse3, :especificacao

    def initialize(classe:, subclasse1:, subclasse2:, subclasse3:, especificacao:)
      raise ParseError, "Classe nacional #{classe} inválida" unless (1..41).include?(classe.to_i)

      @classe = classe
      @subclasse1 = subclasse1 if subclasse1 > 0
      @subclasse2 = subclasse2 if subclasse2 > 0
      @subclasse3 = subclasse3 if subclasse3 > 0
      @especificacao = especificacao
    end
  end
end
