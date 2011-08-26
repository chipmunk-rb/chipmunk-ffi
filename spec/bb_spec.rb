require File.dirname(__FILE__)+'/spec_helper'
describe 'BB' do
  before(:all) do
    @bb_1 = CP::BB.new 1, 2, 3, 4
    @bb_2 = CP::BB.new 2, 3, 4, 5
    @bb_3 = CP::BB.new 1, 2, 2, 3
    @bb_4 = CP::BB.new 0, 0, 1, 1
  end

  it 'can be checked for intersection with another BB' do
    @bb_1.intersects?(@bb_2).should be_true
    @bb_2.intersects?(@bb_4).should be_false
  end

  it 'can be checked if contains another BB' do
    @bb_1.contains_bb?(@bb_3).should be_true
    @bb_3.contains_bb?(@bb_1).should be_false
    @bb_1.contains_bb?(@bb_2).should be_false
    @bb_2.contains_bb?(@bb_3).should be_false
  end

  it 'can be checked if contains a Vect' do
    v = vec2 2, 3
    @bb_1.contains_vect?(v).should be_true
    @bb_4.contains_vect?(v).should be_false
  end

  it 'can be merged with another BB' do
    @bb_1.merge(@bb_2).should == CP::BB.new(1, 2, 4, 5)
  end

  it 'can be expanded by Vect' do
    v = vec2 3, 4
    @bb_3.expand(v).should == @bb_1
  end

  it 'can calculate its area' do
    @bb_1.area.should == 4
  end

  it 'can calculate its merged area with another bb' do
    @bb_1.merged_area(@bb_2).should == 9
  end

  it 'can be checked if intersects a segment' do
    v1 = vec2 0, 4
    v2 = vec2 3, 0
    @bb_1.intersects_segment?(v1, v2).should be_true
    @bb_2.intersects_segment?(v1, v2).should be_false
  end

  it 'can clamp a Vect' do
    v = vec2 0, 3
    @bb_1.clamp_vect(v).should == vec2(1, 3)
  end

  it 'can wrap a Vect' do
    v = vec2 1.5, 1.5
    @bb_4.wrap_vect(v).should == vec2(0.5, 0.5)
  end
end

