require 'metabamf/parser'

module Metabamf
  RSpec.describe Parser do
    it "has a hash of box definitions" do
      expect(Parser.definitions['ftyp']).to be(Metabamf::Boxes::Ftyp)
    end

    it "can construct a Steam parser and returns the parse_stream! result" do
      io = double
      definitions = double
      result = double
      allow(Parser).to receive(:definitions) { definitions }

      expect(Parser::Stream).to receive(:parse_stream!).with(io, definitions) { result }

      expect(Parser.parse(io)).to be(result)
    end
  end
end
