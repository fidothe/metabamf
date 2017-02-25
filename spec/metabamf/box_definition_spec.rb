require 'metabamf/box_definition'
require 'stringio'

module Metabamf
  RSpec.describe BoxDefinition do
    it "has a boxtype" do
      subject = BoxDefinition.new('moov')

      expect(subject.boxtype).to eq('moov')
    end

    it "can specify a mandatory simple attribute" do
      subject = BoxDefinition.new('fltc') do |d|
        d.attr :blah, required: true
      end

      expect(subject.simple_attributes[:blah]).to eq(required: true)
    end

    it "can specify an optional simple attribute" do
      subject = BoxDefinition.new('fltc') do |d|
        d.attr :blah
      end

      expect(subject.simple_attributes[:blah]).to eq(required: false)
    end

    context "a child box which can only occur once" do
      it "can be specified as mandatory" do
        subject = BoxDefinition.new('fltc') do |d|
          d.contains :blah, required: true
        end

        expected = {required: true, boxtype: 'blah'}
        expect(subject.contained_single_boxes[:blah]).to eq(expected)
      end

      it "can be specifed as optional" do
        subject = BoxDefinition.new('fltc') do |d|
          d.contains :blah
        end

        expected = {required: false, boxtype: 'blah'}
        expect(subject.contained_single_boxes[:blah]).to eq(expected)
      end

      it "can have the boxtype explicitly specified" do
        subject = BoxDefinition.new('fltc') do |d|
          d.contains :blah, boxtype: 'oflc'
        end

        expected = {required: false, boxtype: 'oflc'}
        expect(subject.contained_single_boxes[:blah]).to eq(expected)
      end
    end

    context "child boxes which can occur multiple times" do
      it "can be specified as mandatory" do
        subject = BoxDefinition.new('fltc') do |d|
          d.contains_multiple :blah, boxtype: 'oflc', required: true
        end

        expected = {required: true, boxtype: 'oflc'}
        expect(subject.contained_multiple_boxes[:blah]).to eq(expected)
      end

      it "can be specifed as optional" do
        subject = BoxDefinition.new('fltc') do |d|
          d.contains_multiple :blah, boxtype: 'oflc'
        end

        expected = {required: false, boxtype: 'oflc'}
        expect(subject.contained_multiple_boxes[:blah]).to eq(expected)
      end

      it "must have the boxtype explicitly specified" do
        expect {
          BoxDefinition.new('fltc') do |d|
            d.contains_multiple :blah
          end
        }.to raise_error(ExplicitBoxtypeRequired)
      end
    end

    context "specifying a §4.2 FullBox" do
      subject = BoxDefinition.new('fltc') do |d|
        d.full_box!
      end

      it "has a version field" do
        expect(subject.simple_attributes[:version]).to eq(required: true)
      end

      it "has a flags field" do
        expect(subject.simple_attributes[:flags]).to eq(required: true)
      end

      it "reports its a full box" do
        expect(subject.full_box?).to be(true)
      end
    end

    context "generating an entity class" do
      let(:definition) {
        BoxDefinition.new('fltc') do |d|
          d.attr :hello, required: true
          d.attr :what
          d.contains :blah
          d.contains :also, required: true
          d.contains_multiple :fings, boxtype: 'fing'
        end
      }
      let(:other_box) { double }
      let(:entity_class) { definition.entity }
      let(:attrs) { Hash[
        boxtype: 'fltc',
        size: 42,
        hello: 'hello',
        what: 'what',
        also: other_box,
      ] }
      subject { entity_class.new(attrs) }

      it "provides optional attributes with a query method" do
        expect(subject.what?).to be(true)
        expect(subject.blah?).to be(false)
      end

      it "represents multiply-occuring child boxes as an array" do
        expect(subject.fings).to eq([])
      end

      it "raises an error if instantiated missing a mandatory attribute" do
        bad_attrs = attrs.dup
        bad_attrs.delete(:hello)
        expect {
          entity_class.new(bad_attrs)
        }.to raise_error(Metabamf::Entity::MissingRequiredAttribute)
      end

      it "raises an error if instantiated missing a mandatory child" do
        bad_attrs = attrs.dup
        bad_attrs.delete(:also)
        expect {
          entity_class.new(bad_attrs)
        }.to raise_error(Metabamf::Entity::MissingRequiredAttribute)
      end

      it "compares equal to another instance with the same attrs" do
        expect(subject).to eq(entity_class.new(attrs))
      end
    end

    context "the deserializer" do
      let(:box) {
        instance_double('Metabamf::Parser::Box', {
          boxtype: 'fltc', size: 100
        })
      }
      it "defaults to a no-op lambda" do
        subject = BoxDefinition.new('fltc')
        expected = subject.entity.new(boxtype: 'fltc', size: 100)

        result = subject.deserializer.call(box)

        expect(result).to eq(expected)
      end

      it "allows a proper deserializer to be specified" do
        subject = BoxDefinition.new('fltc') do |d|
          d.attr :blah, required: true
          d.deserializer = ->(box, attrs) {
            attrs.merge(blah: 'blah')
          }
        end
        expected = subject.entity.new({
          boxtype: 'fltc', size: 100, blah: 'blah'
        })

        result = subject.deserializer.call(box)

        expect(result).to eq(expected)
      end
    end
  end
end
