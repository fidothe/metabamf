require 'metabamf/parser/box'
require 'metabamf/parser/entity_set'
require 'metabamf/file'
require 'metabamf/null_box'

module Metabamf
  module Parser
    class Stream
      attr_reader :io, :definitions, :start_offset

      def self.parse_stream!(io, definitions)
        new(io, definitions).parse_stream!
      end

      def initialize(io, definitions)
        @io = io
        @definitions = definitions
        @start_offset = io.pos
      end

      def definition(boxtype)
        definitions.fetch(boxtype, NullBox)
      end

      def deserializer(boxtype)
        definition(boxtype).deserializer
      end

      def parse_next_box
        Box.new(self).deserialize
      end

      def parse_boxes_until(end_pos)
        entity_set = EntitySet.new
        while pos < end_pos
          entity_set << parse_next_box
        end
        entity_set
      end

      def parse_boxes
        entity_set = EntitySet.new
        while !io.eof?
          entity_set << parse_next_box
        end
        entity_set
      end

      def parse_stream!
        Metabamf::File.new(parse_boxes)
      end

      def read(*args)
        io.read(*args)
      end

      def pos
        io.pos
      end

      def seek_to(pos)
        io.seek(pos, IO::SEEK_SET)
      end

      def seek_to_end
        io.seek(0, IO::SEEK_END)
      end
    end
  end
end

