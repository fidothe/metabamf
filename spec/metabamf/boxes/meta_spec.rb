require 'metabamf/boxes/meta'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Meta do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('meta.mp4').open('rb') }
    let(:definitions) { Hash['meta' => subject] }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }

    subject { Meta }

    it "has the correct boxtype" do
      expect(subject.boxtype).to eq('meta')
    end

    context "deserializing to an entity object" do
      let(:entity) { parser.deserialize }

      it "has the right boxtype" do
        expect(entity.boxtype).to eq('meta')
      end

      it "has the right size" do
        expect(entity.size).to eq(409)
      end

      it "has an `hdlr` child" do
        expect(entity.hdlr.boxtype).to eq('hdlr')
      end
    end
  end
end
