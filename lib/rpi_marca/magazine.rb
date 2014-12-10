require 'rpi_marca/helpers'
require 'rpi_marca/publication'
require 'nokogiri'

module RpiMarca
  class Magazine
    include Enumerable

    attr_reader :number, :date

    def initialize(src)
      @source = Nokogiri::XML(src).root

      @number = Helpers.get_attribute_value(@source, 'numero').to_i
      @date = Helpers.parse_date(
        Helpers.get_attribute_value(@source, 'data')
      )
    end

    def each
      if block_given?
        @source.xpath('//processo').each { |el| yield Publication.new(el) }
      else
        to_enum(:each)
      end
    end

    def valid?
      schema = File.join(
        File.dirname(File.expand_path(__FILE__)),
        'magazine.xsd'
      )

      File.open(schema, 'r') do |f|
        Nokogiri::XML::Schema(f).valid?(@source.document)
      end
    end
  end
end
