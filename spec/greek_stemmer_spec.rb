# coding: utf-8
require 'spec_helper'
require "yaml"

describe GreekStemmer do
  describe "#stem" do
    let(:words) { YAML.load_file('spec/fixtures/examples.yml') }
    let(:config) { YAML.load_file('config/stemmer.yml') }

    it "stems words correctly" do
      words.each_pair do |word, stem|
        expect(described_class.stem(word)).to eq(stem)
      end
    end

    context "when a non-greek word is used" do
      it "does not stem it" do
        expect(described_class.stem("englishΟΣ")).to eq("englishΟΣ")
      end
    end

    context 'exceptions' do
      it 'does not stem protected words' do
        config['protected_words'].each do |word|
          expect(described_class.stem(word)).to eq(word)
        end
      end

      it 'correctly stems 0-level exceptions' do
        config['step_0_exceptions'].each_pair do |word, stem|
          expect(described_class.stem(word)).to eq(stem)
        end
      end
    end
  end
end
