module RpiMarca
  class Ncl
    attr_reader :classe, :edicao, :especificacao

    def initialize(classe:, edicao:, especificacao:)
      fail ParseError, "NCL #{classe} inválida" unless (1..45).include?(classe.to_i)

      @classe = classe
      @edicao = edicao if edicao > 0
      @especificacao = especificacao
    end

    def self.parse(el)
      return unless el

      new(
        classe: Helpers.get_attribute_value(el, "codigo"),
        edicao: Helpers.get_attribute_value(el, "edicao").to_i,
        especificacao: Helpers.get_element_value(el.at_xpath(".//especificacao"))
      )
    end
  end
end
