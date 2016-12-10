require 'metabamf/structure/definition'
require 'matrix'

module Metabamf
  module Boxes
    EPOCH_TIME = Time.utc(1904, 1, 1)

    Mvhd = Structure::Definition.new('mvhd') do |d|
      d.full_box!
      d.attr :creation_time, required: true
      d.attr :modification_time, required: true
      d.attr :timescale, required: true
      d.attr :duration, required: true
      d.attr :duration_in_s, required: true
      d.attr :rate, required: true
      d.attr :volume, required: true
      d.attr :matrix, required: true
      d.attr :next_track_id, required: true

      d.deserializer = ->(box, attrs) {
        v = attrs[:version]
        ct_int = (v == 0 ? box.read_uint32 : box.read_uint64)
        creation_time = EPOCH_TIME + ct_int
        mt_int = (v == 0 ? box.read_uint32 : box.read_uint64)
        modification_time = EPOCH_TIME + mt_int
        timescale = box.read_uint32
        duration = v == 0 ? box.read_uint32 : box.read_uint64
        rate = box.read_fixed_point_number(16, 16)
        volume = box.read_fixed_point_number(8, 8)
        box.read_ascii_bytes(10) # dead bytes
        matrix = Matrix[
          3.times.map {
            [
              box.read_fixed_point_number(16, 16),
              box.read_fixed_point_number(16, 16),
              box.read_fixed_point_number(2, 30)
            ]
          }
        ]
        box.read_ascii_bytes(24) # dead bytes
        next_track_id = box.read_uint32

        attrs.merge({
          creation_time: creation_time, modification_time: modification_time,
          timescale: timescale, duration: duration, rate: rate, volume: volume,
          matrix: matrix, next_track_id: next_track_id, duration_in_s: duration/timescale.to_f
        })
      }
    end
  end
end
