require 'forwardable'

module Metabamf
  module Parser
    class EntitySet
      extend Forwardable
      include Enumerable

      def_delegators :@entities, :[], :size, :length, :each, :last

      def initialize
        @entities = []
      end

      def <<(entity)
        @entities << entity
        self
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
