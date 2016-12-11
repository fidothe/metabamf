require 'pathname'

module Metabamf
  module Boxes
    class << self
      def all
        @all ||= Pathname.new(__dir__).join('boxes').children.map { |p|
          require p.to_s
          klass(p.basename('.rb').to_s)
        }
      end

      private

      def klass(name)
        klass_name = name[0].upcase + name[1..-1]
        const_get(klass_name)
      end
    end
  end
end
