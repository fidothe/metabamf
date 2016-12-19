require 'pathname'
require 'metabamf/parser/stream'
require 'metabamf/structure/definition'
require 'metabamf/parser/box'

module Metabamf::Parser
  RSpec.describe Box do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures') }
    let(:io) { fixture_dir.join('box.mp4').open('rb') }
    let(:definition) {
      Metabamf::Structure::Definition.new('fltc') do |d|
        d.attr :field, required: true

        d.deserializer = ->(box, attrs) {
          attrs.merge(field: box.read_uint32)
        }
      end
    }
    let(:definitions) {
      {'fltc' => definition}
    }
    let(:parser) { Stream.new(io, definitions) }

    subject { Box.new(parser) }

    context "reading data from the stream" do
      def io(array, template)
        StringIO.new(array.pack(template))
      end

      def stream(io)
        Stream.new(io, definitions)
      end

      it "can read a uint8 from the io" do
        subject = Box.new(stream(io([42], "C")))
        expect(subject.read_uint8).to eq(42)
      end

      it "can read a uint16 from the io" do
        subject = Box.new(stream(io([42], "n")))
        expect(subject.read_uint16).to eq(42)
      end

      it "can read a uint32 from the io" do
        subject = Box.new(stream(io([42], "N")))
        expect(subject.read_uint32).to eq(42)
      end

      it "can read a uint64 from the io" do
        subject = Box.new(stream(io([42], "Q>")))
        expect(subject.read_uint64).to eq(42)
      end

      it "can read n bytes of an ascii string" do
        subject = Box.new(stream(StringIO.new('hello')))
        expect(subject.read_ascii_bytes(3)).to eq('hel')
      end

      it "reports the position within the stream" do
        subject = Box.new(stream(StringIO.new('hello')))
        subject.read_ascii_bytes(3)
        expect(subject.pos).to eq(3)
      end

      context "reading fixed-point numbers" do
        subject {
          Box.new(stream(StringIO.new([0xffffffff].pack('N'))))
        }

        it "correctly reads a 16.16 number" do
          expect(subject.read_fixed_point_number(16, 16)).to eq(65535.99998474121)
        end

        it "correctly reads an 8.8 number" do
          expect(subject.read_fixed_point_number(8, 8)).to eq(255.99609375)
        end

        it "correctly reads a 2.30 number" do
          expect(subject.read_fixed_point_number(2, 30)).to eq(3.9999999990686774)
        end
      end
    end

    context "a leaf box" do
      it "extracts the correct size and boxtype" do
        expect(subject.size).to eq(12)
      end

      it "extracts the correct boxtype" do
        expect(subject.boxtype).to eq('fltc')
      end

      it "correctly invokes the deserializer and returns a sane entity" do
        result = subject.deserialize
        expect(result.field).to eq(1234)
      end

      it "ensures the IO is positioned at the end of the box" do
        subject.deserialize
        expect(io.pos).to eq(12)
      end
    end

    context "an unknown box" do
      let(:io) { fixture_dir.join('unknown_box.mp4').open('rb') }

      it "returns a NullBox with the appropriate box_type and size" do
        actual = subject.deserialize
        expect(actual).to eq(Metabamf::NullBox.new(boxtype: 'unkn', size: 42))
      end
    end
  end
end
