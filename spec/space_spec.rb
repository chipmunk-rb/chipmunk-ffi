require File.dirname(__FILE__)+'/spec_helper'
describe 'Space in chipmunk, creation check'do
  it 'can be created' do
    CP::Space.new.should_not be_nil
  end
end
describe 'Space in chipmunk' do
  before(:each) do
    @s = CP::Space.new
    @b = CP::Body.new 90, 76
  end
  it 'can set its iterations' do
    @s.iterations = 9
    @s.iterations.should == 9
  end
  it 'can set its gravity' do
    @s.gravity = vec2(4,5)
    @s.gravity.x.should == 4
    @s.gravity.y.should == 5
  end

  it 'can have a shape added to it' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    @s.add_shape shapy
  end

  it 'can have old style callbacks' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @b_2 = CP::Body.new 90, 76
    shapy_one = CP::Shape::Circle.new @b_2, 40, CP::ZERO_VEC_2
    shapy_one.collision_type = :bar
    @s.add_shape shapy
    @s.add_shape shapy_one

    called = false
    @s.add_collision_func :foo, :bar do |a,b|
      a.should_not be_nil
      b.should_not be_nil
      called = true
      1
    end

    @s.step 1
    called.should be_true
  end

  class CollisionHandler
    attr_reader :begin_called
    def begin(a,b)
      @begin_called = [a,b]
    end
  end

  it 'can have new style callbacks' do
    ch = CollisionHandler.new

    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @b_2 = CP::Body.new 90, 76
    shapy_one = CP::Shape::Circle.new @b_2, 40, CP::ZERO_VEC_2
    shapy_one.collision_type = :bar
    @s.add_shape shapy
    @s.add_shape shapy_one

    @s.add_collision_handler :foo, :bar, ch

    @s.step 1
    
    ch.begin_called[0].should == shapy
    ch.begin_called[1].should == shapy_one
  end

  it 'can have lots of shapes no GC corruption' do
    bodies = []
    shapes = []
    5.times do |i|
      bodies[i] = CP::Body.new(90, 76)
      shapes[i] = CP::Shape::Circle.new(bodies[i], 40, CP::ZERO_VEC_2)
      shapes[i].collision_type = "bar#{i}".to_sym
      @s.add_shape(shapes[i])
      @s.add_body(bodies[i])
    end

    GC.start

    @s.step 1
  end

  it 'can have constraints added' do
    body_a = Body.new 90, 46
    body_b = Body.new 9, 6
    pj = CP::PinJoint.new(body_a,body_b,ZERO_VEC_2,ZERO_VEC_2)

    @s.add_constraint pj
  end

  it 'can do a first point query finds the shape' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape shapy

    obj = @s.point_query_first(vec2(20,20),CP::ALL_ONES,0)
    obj.should == shapy

  end

  it 'can do a first point query does not find anything' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape shapy

    all_ones = 2**32-1
    obj = @s.point_query_first(vec2(20,50),all_ones,0)
    obj.should be_nil

  end

  it 'can do a point query' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape shapy
    
    all_ones = 2**32-1
		
    shapes = []
    @s.point_query vec2(20,20), all_ones,0 do |shape|
      shapes << shape
    end
    
    shapes.size.should == 1
    shapes.first.should == shapy
  end

  it 'can do a point query finds the shape' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape shapy

    obj = @s.shape_point_query(vec2(20,20))
    obj.should == shapy

  end

  it 'can do a bb query' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.use_spatial_hash 1, 2
    @s.add_shape shapy

    index = @s.active_shapes_index

    #query_func = Proc.new do |_, other, _|
    #    s = ShapeStruct.new other
    #    obj_id = s.data.get_long 0
    #    @shapes <<  ObjectSpace._id2ref(obj_id)
    #end

    shapes = index.query nil, BB.new(0,0,5,5)

    shapes.size.should == 1
    shapes.first.should == shapy
  end

  it 'can do a segment query' do
    shapy = CP::Shape::Circle.new @b, 40, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape shapy

    all_ones = 2**32-1

    shapes = []
    @s.segment_query(vec2(100,100),vec2(-100,-100), all_ones,0) do |shape, t, n|
      shapes << shape
    end

    shapes.size.should == 1
    shapes.first.should == shapy
  end

  it 'can do a segment query that returns info' do
    shapy = CP::Shape::Circle.new @b, 20, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape(shapy)

    all_ones = 2**32-1

    info = @s.info_segment_query(vec2(-100,10),vec2(0,10), all_ones, 0)
    info.hit.should be_true
    info.shape.should be shapy
    info.t.should be_close(0.827,0.001)
    info.n.x.should be_close(-0.866, 0.001)
    info.n.y.should be_close(0.5, 0.001)
  end

  it 'can do a segment query that returns a shape' do
    shapy = CP::Shape::Circle.new @b, 20, CP::ZERO_VEC_2
    shapy.collision_type = :foo

    @s.add_shape shapy

    query_result = @s.shape_segment_query(vec2(-100,10),vec2(0,10))
    query_result.should == shapy
  end

  it 'can do a segment query that finds no shape' do
    query_result = @s.shape_segment_query(vec2(-100,10),vec2(0,10))

    query_result.should be_nil
  end

  it 'can do a segment query that finds no info' do
    info = @s.info_segment_query(vec2(-100,10),vec2(0,10))

    info.hit.should be_false
    info.shape.should be_nil
    info.t.should be_nil
    info.n.should be_nil
  end
  
  

end
