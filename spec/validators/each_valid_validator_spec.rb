# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EachValidValidator do
  class EachValidValidatorModel
    include ActiveModel::Validations

    attr_reader :books

    def initialize(books)
      @books = books
    end

    validates :books, each_valid: true
  end

  it 'allows nil' do
    record = EachValidValidatorModel.new(nil)
    expect(record).to be_valid
  end

  it 'allows empty' do
    record = EachValidValidatorModel.new([])
    expect(record).to be_valid
  end

  it 'disallows invalid record' do
    record = EachValidValidatorModel.new(
      [double(valid?: false)]
    )
    expect(record).to_not be_valid
    expect(record.errors.details).to eq(
      books: [
        {
          error: :invalid,
          invalid_count: 1
        }
      ]
    )
  end

  it 'disallows multiple invalid records' do
    record = EachValidValidatorModel.new(
      [
        double(valid?: false),
        double(valid?: false),
        double(valid?: false)
      ]
    )
    expect(record).to_not be_valid
    expect(record.errors.details).to eq(
      books: [
        {
          error: :invalid,
          invalid_count: 3
        }
      ]
    )
  end

  it 'disallows mixed valid and invalid records' do
    record = EachValidValidatorModel.new(
      [
        double(valid?: true),
        double(valid?: true),
        double(valid?: false)
      ]
    )
    expect(record).to_not be_valid
    expect(record.errors.details).to eq(
      books: [
        {
          error: :invalid,
          invalid_count: 1
        }
      ]
    )
  end

  it 'allows valid record' do
    record = EachValidValidatorModel.new(
      [double(valid?: true)]
    )
    expect(record).to be_valid
  end

  it 'allows multiple valid record' do
    record = EachValidValidatorModel.new(
      [
        double(valid?: true),
        double(valid?: true),
        double(valid?: true)
      ]
    )
    expect(record).to be_valid
  end
end
