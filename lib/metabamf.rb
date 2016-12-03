require "metabamf/version"

module Metabamf

  class File
    attr_reader :boxes

    def initialize
      @boxes = []
    end

    def <<(box)
      boxes << box
    end
  end

  class Box
    attr_reader :size, :boxtype, :extended_type, :boxes

    def initialize(attrs)
      @size = attrs.fetch(:size)
      @boxtype = attrs.fetch(:boxtype)
      @extended_type = attrs[:extended_type]
      @boxes = []
    end

    def <<(box)
      boxes << box
    end
  end

  class FullBox < Box
    attr_reader :version, :flags

    def initialize(attrs)
      super(attrs)
      @version = attrs[:version]
      @flags = attrs[:flags]
    end
  end

  class FileTypeBox < Box
    attr_reader :major_brand, :minor_version, :compatible_brands
  end

  BoxDef = Struct.new(:boxtype, :allows_children)

  class Parser
    BOXEN = [
      BoxDef.new('ftyp', false),
      BoxDef.new('mdat', false),
      BoxDef.new('free', false),
      BoxDef.new('skip', false),
      BoxDef.new('pdin', false),
      BoxDef.new('moov', true),
      BoxDef.new('mvhd', false),
      BoxDef.new('meta', true),
      BoxDef.new('trak', true),
    ]

    BOXEN_LOOKUP = Hash[BOXEN.map { |b| [b.boxtype, b] }

    attr_reader :io

    private :io

    def initialize(io)
      @io = io
    end

    def parse
      f = File.new

      while not io.eof?
        read_box(f)
      end

      f
    end

    def read_box(parent)
      # note byte offset
      offset = io.pos
      # read size
      size = io.read(4).unpack("N").first
      extended_size = nil
      # read boxtype
      boxtype = io.read(4)
      size = io.read(8).unpack("Q").first if size == 0
      parent << Box.new(size: size, boxtype: boxtype)
      # seek to end of box
      puts "#{boxtype}: #{offset.inspect}, #{size.inspect}"
      if size == 0 # last box, seek to EOF
        io.seek(0, IO::SEEK_END)
      else
        io.seek(offset + size, IO::SEEK_SET)
      end
    end
  end
end
