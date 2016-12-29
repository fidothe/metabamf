require 'metabamf/boxes/hdlr'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Hdlr do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('hdlr.mp4').open('rb') }
    let(:definitions) { Hash['hdlr' => subject] }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }

    subject { Hdlr }

    it "has the correct boxtype" do
      expect(subject.boxtype).to eq('hdlr')
    end

    context "deserializing to an entity object" do
      let(:entity) { parser.deserialize }

      it "has the right boxtype" do
        expect(entity.boxtype).to eq('hdlr')
      end

      it "has the right version" do
        expect(entity.version).to eq(0)
      end

      it "has the right size" do
        expect(entity.size).to eq(34)
      end

      it "has the right handler_type" do
        expect(entity.handler_type).to eq('mdir')
      end

      it "has the right name" do
        expect(entity.name).to eq('appl')
      end
    end
  end
end
