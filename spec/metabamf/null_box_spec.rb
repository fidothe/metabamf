require 'metabamf/null_box'
require 'metabamf/parser/box'

module Metabamf
  RSpec.describe NullBox do
    context "an instance" do
      subject { NullBox.new(boxtype: 'unkn', size: 42) }

      it "can return its boxtype" do
        expect(subject.boxtype).to eq('unkn')
      end

      it "can return its size" do
        expect(subject.size).to eq(42)
      end

      it "compares equal to another instance with the same boxtype and size" do
        expect(subject).to eq(NullBox.new(boxtype: 'unkn', size: 42))
      end
    end

    it "provides a no-op deserializer that returns a sensible instance" do
      box = instance_double(Parser::Box, boxtype: 'unkn', size: 42)
      result = NullBox.deserializer.call(box)
      expect(result).to eq(NullBox.new(boxtype: 'unkn', size: 42))
    end
  end
end
