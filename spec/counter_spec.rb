require File.expand_path '../../lib/counter.rb', __FILE__

describe Counter do
  before(:each) do
    Counter::reset
  end

  describe '#increment' do
    it 'adds one to a number' do
      expect(Counter::increment).to eq 1
      expect(Counter::increment).to eq 2
    end
  end

  describe '#decrement' do
    it 'substracts one from a number' do
      expect(Counter::decrement).to eq -1
      expect(Counter::decrement).to eq -2
    end
  end
end