# frozen_string_literal: true

require 'spec_helper'
require 'slug'

RSpec.describe Slug do
  it 'raises an exception generating a slug out of nil' do
    expect do
      Slug.generate(nil)
    end.to raise_error(ArgumentError)
  end

  it 'normalizes Unicode characters' do
    string = 'Càfé'
    expect(
      Slug.generate(string.unicode_normalize(:nfd))
    ).to eq('càfé'.unicode_normalize(:nfkc))
  end

  it 'folds ASCII characters down' do
    expect(Slug.generate('HELLO')).to eq('hello')
  end

  it 'folds Unicode characters down' do
    expect(Slug.generate('ĲLAND')).to eq('ĳland')
    expect(Slug.generate('Århüs')).to eq('århüs')
  end

  it 'removes control characters' do
    expect(Slug.generate("\x00\x1fbel")).to eq('bel')
  end

  it 'strips ASCII space from the front' do
    expect(Slug.generate("  \tbel")).to eq('bel')
  end

  it 'strips ASCII space from the end' do
    expect(Slug.generate("bel\n  ")).to eq('bel')
  end

  it 'strips Unicode space from the front' do
    expect(Slug.generate("#{unicode_whitespace}bel")).to eq('bel')
  end

  it 'strips Unicode space from the end' do
    expect(Slug.generate("bel#{unicode_whitespace}")).to eq('bel')
  end

  it 'replaces ASCII space characters with a single dash' do
    expect(Slug.generate("Tubular Bells")).to eq('tubular-bells')
    expect(Slug.generate("Tubular  Bells")).to eq('tubular-bells')
  end

  it 'replaces Unicode space characters with a single dash' do
    expect(
      Slug.generate("Tubular#{unicode_whitespace}Bells")
    ).to eq('tubular-bells')
  end

  it 'works' do
    [
      ['All Things Fall Apart', 'all-things-fall-apart'],
      [
        "It's Always Raining in Connecticut",
        "it's-always-raining-in-connecticut"
      ],
      ['NeoTokyo', 'neotokyo'],
      ['مرحبا', 'مرحبا'],
      ['नमस्कार', 'नमस्कार'],
      ['Привет дженя', 'привет-дженя']
    ].each do |example, expected|
      expect(Slug.generate(example)).to eq(expected)
    end
  end

  def unicode_whitespace
    [0x2002, 0x2009].pack('U*')
  end
end
