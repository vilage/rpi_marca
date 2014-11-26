module RpiMarca
  class ClasseVienna
    attr_reader :edicao, :classe1, :classe2, :classe3, :classe4, :classe5

    def initialize(edicao:, classe1:, classe2:, classe3:, classe4:, classe5:)
      @edicao = edicao
      @classe1 = classe1
      @classe2 = classe2
      @classe3 = classe3
      @classe4 = classe4
      @classe5 = classe5
    end

    def self.parse(el)
      return unless el

      classes = el.xpath(".//classe-vienna").map { |s| s["codigo"] }
      raise ParseError, "Classe Vienna possui mais de 5 classes" if classes.length > 5

      new(
        edicao: Helpers.get_attribute_value(el, "edicao").to_i,
        classe1: classes[0],
        classe2: classes[1],
        classe3: classes[2],
        classe4: classes[3],
        classe5: classes[4]
      )
    end
  end
end
