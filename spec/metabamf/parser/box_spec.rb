require 'pathname'
require 'json'
require 'metabamf/parser/box'

module Metabamf::Parser
  RSpec.describe Box do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures') }
    let(:io) { fixture_dir.join('bbb_1s.mp4').open('rb') }
    let(:dumped_boxes) { JSON.load(fixture_dir.join('bbb_1s.json').open) }
    let(:result) { double }
    let(:deserializer) {
      ->(io, start_offset, boxtype, size) {
        result
      }
    }
    let(:deserializer_registry) {
      {'ftyp' => deserializer}
    }

    subject { Box.new(io, deserializer_registry) }

    context "a leaf box" do
      let(:dumped_box) { dumped_boxes.first }

      it "extracts the correct size and boxtype" do
        expect(subject.size).to eq(dumped_box['size'])
      end

      it "extracts the correct boxtype" do
        expect(subject.boxtype).to eq(dumped_box['name'])
      end

      it "looks up the correct box deserializer" do
        expect(subject.deserializer).to be(deserializer)
      end

      it "correctly invokes the deserializer and returns the result" do
        expect(subject.deserialize).to be(result)
      end

      it "ensures the IO is positioned at the end of the box" do
        subject.deserialize
        expect(io.pos).to eq(28)
      end
    end
  end
end
