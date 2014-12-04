module RpiMarca
  class ClasseVienna
    attr_reader :edicao, :classe1, :classe2, :classe3, :classe4, :classe5

    def initialize(edicao:, classe1:, classe2: nil, classe3: nil,
                   classe4: nil, classe5: nil)
      @edicao = edicao
      @classe1 = classe1
      @classe2 = classe2
      @classe3 = classe3
      @classe4 = classe4
      @classe5 = classe5
    end

    def self.parse(el)
      return unless el

      subclasses = parse_subclasses(el)

      new(
        edicao: Helpers.get_attribute_value(el, "edicao").to_i,
        **subclasses
      )
    end

    def self.parse_subclasses(el)
      subclasses = el.xpath(".//classe-vienna").map { |s| s["codigo"] }
      fail ParseError, "Classe Vienna possui mais de 5 subclasses" if
        subclasses.length > 5

      {
        classe1: subclasses[0],
        classe2: subclasses[1],
        classe3: subclasses[2],
        classe4: subclasses[3],
        classe5: subclasses[4]
      }
    end

    private_class_method :parse_subclasses
  end
end
