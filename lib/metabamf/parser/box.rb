module Metabamf
  module Parser
    class Box
      attr_reader :parser, :start_pos

      def initialize(parser)
        @parser = parser
        @start_pos = parser.pos
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
        @result = deserializer.call(self)
        ensure_io_at_end_of_box
        @result
      end

      def deserializer
        parser.deserializer(boxtype)
      end

      def read_uint8
        parser.read(1).unpack("C").first
      end

      def read_uint16
        parser.read(2).unpack("n").first
      end

      def read_uint32
        parser.read(4).unpack("N").first
      end

      def read_uint64
        parser.read(8).unpack("Q>").first
      end

      def read_ascii_bytes(n)
        parser.read(n)
      end

      def read_fixed_point_number(m, f)
        total_size = m + f
        meth = {16 => :read_uint16, 32 => :read_uint32}.fetch(total_size)
        int = send(meth)
        int / (2**f).to_f
      end

      def pos
        parser.pos
      end

      def parse_children
        final_pos = start_pos + size
        children = parser.parse_boxes_until(final_pos)
      end

      private

      # see ISO 14496-12:2015 §4.2
      def read_size_and_boxtype
        @size = read_compact_size
        @boxtype = read_ascii_bytes(4)
        @size = read_extended_size if @size == 1
      end

      def read_compact_size
        read_uint32
      end

      def read_extended_size
        read_uint64
      end

      def ensure_io_at_end_of_box
        if size == 0 # last box magic number, seek to EOF
          parser.seek_to_end
        else
          parser.seek_to(start_pos + size)
        end
      end
    end
  end
end
