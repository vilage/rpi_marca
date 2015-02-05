module RpiMarca
  class ViennaClass
    attr_reader :edition, :subclass1, :subclass2, :subclass3, :subclass4,
                :subclass5

    def initialize(edition:, subclass1:, subclass2: nil, subclass3: nil,
                   subclass4: nil, subclass5: nil)
      @edition = edition
      @subclass1 = subclass1
      @subclass2 = subclass2
      @subclass3 = subclass3
      @subclass4 = subclass4
      @subclass5 = subclass5
    end

    def to_s
      [
        @subclass1,
        @subclass2,
        @subclass3,
        @subclass4,
        @subclass5
        ].compact.join(' / ')
    end

    def self.parse(el)
      return unless el

      subclasses = parse_subclasses(el)

      new(
        edition: Helpers.get_attribute_value(el, 'edicao').to_i,
        **subclasses
      )
    end

    def self.parse_subclasses(el)
      subclasses = el.xpath('.//classe-vienna').map { |s| s['codigo'] }
      fail ParseError, "Vienna class can't have more than 5 subclasses" if
        subclasses.length > 5

      {
        subclass1: subclasses[0],
        subclass2: subclasses[1],
        subclass3: subclasses[2],
        subclass4: subclasses[3],
        subclass5: subclasses[4]
      }
    end

    private_class_method :parse_subclasses
  end
end
