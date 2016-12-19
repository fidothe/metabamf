module Metabamf
  class NullBox
    attr_reader :boxtype, :size

    def self.deserializer
      ->(box) {
        new(boxtype: box.boxtype, size: box.size)
      }
    end

    def initialize(attrs)
      @boxtype = attrs.fetch(:boxtype)
      @size = attrs.fetch(:size)
    end

    def ==(other)
      other.boxtype == boxtype && other.size == size
    end
  end
end
