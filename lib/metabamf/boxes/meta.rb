require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Meta = Structure::Definition.new('meta') do |d|
      d.full_box!
      d.contains :hdlr, required: true

      d.deserializer = ->(box, attrs) {
        children = box.parse_children
        attrs.merge({
          hdlr: children.fetch('hdlr')
        })
      }
    end
  end
end
