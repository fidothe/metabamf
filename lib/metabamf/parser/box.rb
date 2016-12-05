module Metabamf
  module Parser
    class Box
      attr_reader :io, :deserializer_registry, :start_offset

      def initialize(io, deserializer_registry)
        @io = io
        @deserializer_registry = deserializer_registry
        @start_offset = io.pos
      end

      def size
        return @size if @size
        read_size_and_boxtype
        @size
      end

      def boxtype
        return @boxtype if @boxtype
        read_size_and_boxtype
        @boxtype
      end

      def deserialize
        return @result if @result
        @result = deserializer.call(io, start_offset, boxtype, size)
        ensure_io_at_end_of_box
        @result
      end

      def deserializer
        deserializer_registry[boxtype]
      end

      private

      # see ISO 14496-12:2015 §4.2
      def read_size_and_boxtype
        @size = read_compact_size
        @boxtype = io.read(4)
        @size = read_extended_size if @size == 1
      end

      def read_compact_size
        io.read(4).unpack("N").first
      end

      def read_extended_size
        io.read(8).unpack("Q").first
      end

      def ensure_io_at_end_of_box
        if size == 0 # last box magic number, seek to EOF
          io.seek(0, IO::SEEK_END)
        else
          io.seek(start_offset + size, IO::SEEK_SET)
        end
      end
    end
  end
end
