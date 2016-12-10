require 'metabamf/boxes/pdin'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Pdin do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('pdin.mp4').open('rb') }
    let(:definitions) {
      {'pdin' => subject}
    }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }

    subject { Pdin }

    it "has the correct boxtype" do
      expect(subject.boxtype).to eq('pdin')
    end

    context "deserializing to an entity object" do
      let(:entity) { parser.deserialize }

      it "has the right boxtype" do
        expect(entity.boxtype).to eq('pdin')
      end

      it "has the right size" do
        expect(entity.size).to eq(28)
      end

      it "has the right version" do
        expect(entity.version).to eq(0)
      end

      it "has the right flags" do
        expect(entity.flags).to eq(0)
      end

      it "has the right rate, delay pairs" do
        expect(entity.rate_and_delay_pairs).to eq([[1024, 10], [2048, 5]])
      end
    end
  end
end
