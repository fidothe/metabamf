require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Hdlr = Structure::Definition.new('hdlr') do |d|
      d.full_box!
      d.attr :handler_type, required: true
      d.attr :name, required: true

      d.deserializer = ->(box, attrs) {
        box.read_ascii_bytes(4) # dead bytes
        handler_type = box.read_ascii_bytes(4)
        offset = box.pos
        header_size = offset - box.start_pos
        remaining_bytes = attrs[:size] - header_size
        name = box.read_ascii_bytes(remaining_bytes).unpack('Z*').first

        attrs.merge({
          handler_type: handler_type,
          name: name
        })
      }
    end
  end
end
