require File.dirname(__FILE__)+'/spec_helper'
describe 'SpaceHashStruct in chipmunk' do
  describe 'SpaceHash class' do
    it 'can be created' do
      bb_func = Proc.new do |shape|
       	puts "hi" 
      end
      sh = CP::SpaceHash.new(1,2,&bb_func)
      sh.cell_dim.should == 1
      prime_that_fits = 5
      sh.num_cells.should == prime_that_fits
    end

    #TODO add specs for the new API from cpSpatialIndex.h

    it 'can lookup query by BB empty' do
      bb_func = Proc.new {|_| puts "hi"}
      sh = CP::SpaceHash.new(1,2,&bb_func)
      bb = BB.new(1,2,3,4)

      objects = sh.query(bb)
      objects.size.should == 0
    end

  end
end
