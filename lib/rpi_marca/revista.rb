require "rpi_marca/publicacao"
require "nokogiri"

module RpiMarca
  class Revista
    include Enumerable

    attr_reader :numero, :data_publicacao

    def initialize(src)
      @source = Nokogiri::XML(src).root

      @numero = Publicacao.get_attribute_value(@source, "numero").to_i
      @data_publicacao = Publicacao.parse_date(
        Publicacao.get_attribute_value(@source, "data")
      )
    end

    def each &block
      @source.xpath("//processo").each do |processo|
        if block_given?
          block.call Publicacao.new(processo)
        else
          yield Publicacao.new(processo)
        end
      end
    end

    def valid?
      schema = File.join(File.dirname(File.expand_path(__FILE__)), "rpi_marca.xsd")
      File.open(schema, "r") do |f|
        Nokogiri::XML::Schema(f).valid?(@source.document)
      end
    end
  end
end
