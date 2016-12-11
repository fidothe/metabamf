require 'metabamf/boxes'

module Metabamf
  RSpec.describe Boxes do
    it "provides a list of all box classes in lib/metabamf/boxes" do
      expect(Boxes.all).to include(Metabamf::Boxes::Ftyp)
    end
  end
end
