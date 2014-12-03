module RpiMarca
  class ClasseNacional
    attr_reader :classe, :subclasse1, :subclasse2, :subclasse3, :especificacao

    def initialize(classe:, subclasse1:, subclasse2:, subclasse3:, especificacao:)
      fail ParseError, "Classe nacional #{classe} inválida" unless (1..41).include?(classe.to_i)

      @classe = classe
      @subclasse1 = subclasse1 if subclasse1 > 0
      @subclasse2 = subclasse2 if subclasse2 > 0
      @subclasse3 = subclasse3 if subclasse3 > 0
      @especificacao = especificacao
    end

    def self.parse(el)
      return unless el

      subclasses = el.xpath(".//sub-classe-nacional").map { |s| s["codigo"] }
      fail ParseError, "Classe nacional possui mais de 3 subclasses" if subclasses.length > 3

      new(
        classe: Helpers.get_attribute_value(el, "codigo").to_i,
        subclasse1: subclasses[0].to_i,
        subclasse2: subclasses[1].to_i,
        subclasse3: subclasses[2].to_i,
        especificacao: Helpers.get_element_value(el.at_xpath(".//especificacao"))
      )
    end
  end
end
