# coding: utf-8
require 'spec_helper'
require "yaml"

describe GreekStemmer do
  describe "#stem" do
    let(:words) { YAML.load_file('spec/fixtures/examples.yml') }
    it "stems words correctly" do
      words.each_pair do |word, stem|
        expect(described_class.stem(word)).to eq(stem)
      end
    end
  end
end
