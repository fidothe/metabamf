require 'metabamf/boxes/meta'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module BoxMatchers
  module ChildBoxMatcherCommon
    def self.included(base)
      base.class_eval do
        attr_reader :boxtype, :box
      end
    end

    def initialize(boxtype)
      @boxtype = boxtype
    end

    def matches?(box)
      @box = box
      match!
    end

    def failure_message
      "expected '#{box.boxtype}' box to #{description}"
    end

    def failure_message_when_negated
      "expected '#{box.boxtype}' box not to #{description}"
    end

    def description
      raise NotImplementedError
    end

    private

    def match!
      raise NotImplementedError
    end

    def can_have_child_box?
      box.respond_to?(boxtype.to_sym)
    end

    def has_child_box_query_method?
      box.respond_to?("#{boxtype}?")
    end

    def child_box_present?
      !child_box.nil? && child_box_correct?
    end

    def child_box_correct?
      child_box.boxtype == boxtype
    end

    def child_box_absent?
      child_box.nil?
    end

    def child_box
      box.send(boxtype.to_sym)
    end
  end

  class RequiredChildMatcher
    include ChildBoxMatcherCommon

    def description
      "have a '#{boxtype}' child"
    end

    private

    def match!
      can_have_child_box? && child_box.boxtype == boxtype
    end
  end

  class OptionalChildMatcher
    include ChildBoxMatcherCommon

    def description
      "have an (optional) '#{boxtype}' child"
    end

    private

    def match!
      can_have_child_box? && has_child_box_query_method? && child_box_present?
    end
  end

  class AbsentOptionalChildMatcher < OptionalChildMatcher
    def description
      "be able to have an (optional) '#{boxtype}' child"
    end

    private

    def match!
      can_have_child_box? && has_child_box_query_method? && child_box_absent?
    end
  end

  def have_child(boxtype)
    RequiredChildMatcher.new(boxtype)
  end

  def have_optional_child(boxtype)
    OptionalChildMatcher.new(boxtype)
  end

  def have_absent_optional_child(boxtype)
    AbsentOptionalChildMatcher.new(boxtype)
  end
end

module Metabamf::Boxes
  RSpec.describe Meta do
    include BoxMatchers

    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('meta.mp4').open('rb') }
    let(:definitions) { Hash['meta' => Meta] }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }


    it "has the correct boxtype" do
      expect(Meta.boxtype).to eq('meta')
    end

    context "deserializing to an entity object" do
      subject { parser.deserialize }

      it "has the right boxtype" do
        expect(subject.boxtype).to eq('meta')
      end

      it "has the right size" do
        expect(subject.size).to eq(409)
      end

      it { is_expected.to have_child('hdlr') }
      it { is_expected.to have_absent_optional_child('dinf') }
      it { is_expected.to have_absent_optional_child('iloc') }
      it { is_expected.to have_absent_optional_child('ipro') }
      it { is_expected.to have_absent_optional_child('iinf') }
      it { is_expected.to have_absent_optional_child('xml') }
      it { is_expected.to have_absent_optional_child('bxml') }
      it { is_expected.to have_absent_optional_child('pitm') }
      it { is_expected.to have_absent_optional_child('fiin') }
      it { is_expected.to have_absent_optional_child('idat') }
      it { is_expected.to have_absent_optional_child('iref') }
    end
  end
end
