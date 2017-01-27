require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Meta = Structure::Definition.new('meta') do |d|
      d.full_box!
      d.contains :hdlr, required: true
      d.contains :dinf
      d.contains :iloc
      d.contains :ipro
      d.contains :iinf
      d.contains :xml
      d.contains :bxml
      d.contains :pitm
      d.contains :fiin
      d.contains :idat
      d.contains :iref

      d.deserializer = ->(box, attrs) {
        children = box.parse_children
        attrs.merge({
          hdlr: children.fetch('hdlr'),
          dinf: children.fetch('dinf'),
          iloc: children.fetch('iloc'),
          ipro: children.fetch('ipro'),
          iinf: children.fetch('iinf'),
          xml: children.fetch('xml'),
          bxml: children.fetch('bxml'),
          pitm: children.fetch('pitm'),
          fiin: children.fetch('fiin'),
          idat: children.fetch('idat'),
          iref: children.fetch('iref'),
        })
      }
    end
  end
end
