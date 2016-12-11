module Metabamf
  class File
    attr_reader :entity_set
    private :entity_set

    def initialize(entity_set)
      @entity_set = entity_set
    end

    def each(&block)
      entity_set.each(&block)
    end

    def ftyp
      entity_set.fetch('ftyp')
    end

    def has_ftyp?
      has_box?('ftyp')
    end

    def pdin
      entity_set.fetch('pdin')
    end

    def has_pdin?
      has_box?('pdin')
    end

    def moov
      entity_set.fetch('moov')
    end

    def has_moov?
      has_box?('moov')
    end

    private

    def has_box?(boxtype)
      !!entity_set.fetch(boxtype)
    end
  end
end
