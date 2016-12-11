require 'metabamf/boxes'
require 'metabamf/parser/stream'

module Metabamf
  module Parser
    class << self
      def definitions
        Hash[Metabamf::Boxes.all.map { |box| [box.boxtype, box] }]
      end

      def parse(io)
        Stream.parse_stream!(io, definitions)
      end
    end
  end
end
