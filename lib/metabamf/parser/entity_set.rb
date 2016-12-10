module Metabamf
  module Parser
    class EntitySet
      def initialize
        @entities = []
      end

      def <<(entity)
        @entities << entity
        self
      end

      def to_a
        @entities
      end

      def fetch(boxtype)
        @entities.find { |entity| entity.boxtype == boxtype }
      end

      def fetch_group(boxtype)
        @entities.select { |entity| entity.boxtype == boxtype }
      end
    end
  end
end
