module CP
  # used for layers; will only work on 32 bit values 
  # (chipmunk cheats and sets these to -1)
  ALL_ONES = 2**32-1

  callback :cpCollisionBeginFunc, [:pointer,:pointer,:pointer], :int
  callback :cpCollisionPreSolveFunc, [:pointer,:pointer,:pointer], :int
  callback :cpCollisionPostSolveFunc, [:pointer,:pointer,:pointer], :int
  callback :cpCollisionSeparateFunc, [:pointer,:pointer,:pointer], :int
	callback :cpSpacePointQueryFunc, [:pointer,:pointer], :void
	callback :cpSpaceSegmentQueryFunc, [:pointer, :float, Vect.by_value, :pointer], :void
	callback :cpSpaceBBQueryFunc, [:pointer,:pointer], :void

  class CollisionHandlerStruct < NiceFFI::Struct
    layout(
      :a, :uint,
      :b, :uint,
      :begin, :cpCollisionBeginFunc,
      :pre_solve, :cpCollisionPreSolveFunc,
      :post_solve, :cpCollisionPostSolveFunc,
      :separate, :cpCollisionSeparateFunc,
      :data, :pointer
    )
  end

  class SpaceStruct < NiceFFI::Struct
    layout( :iterations, :int,
      :elastic_iterations, :int,
      :gravity, Vect.by_value,
      :damping, CP_FLOAT,
      :locked, :int,
      :stamp, :int,
      :static_shapes, :pointer,
      :active_shapes, :pointer,
      :bodies, :pointer,
      :arbiters, :pointer,
      :contact_set, :pointer,
      :constraints, :pointer,
      :coll_func_set, :pointer,
      :default_handler, CollisionHandlerStruct.by_value,
      :post_step_callbacks, :pointer,
      :collisionBias, CP_FLOAT,
      :collisionSlop, CP_FLOAT
    )
    def self.release(ptr)
      CP.cpSpaceFree(ptr)
    end
  end

  func :cpSpaceNew, [], :pointer
  func :cpSpaceFree, [:pointer], :void
  
  func :cpSpaceAddShape, [:pointer, :pointer], :pointer
  func :cpSpaceAddStaticShape, [:pointer, :pointer], :pointer
  func :cpSpaceAddBody, [:pointer, :pointer], :pointer
  func :cpSpaceAddConstraint, [:pointer, :pointer], :pointer

  func :cpSpaceRemoveShape, [:pointer, :pointer], :void
  func :cpSpaceRemoveStaticShape, [:pointer, :pointer], :void
  func :cpSpaceRemoveBody, [:pointer, :pointer], :void
  func :cpSpaceRemoveConstraint, [:pointer, :pointer], :void

  #func :cpSpaceRehashStatic, [:pointer], :void  #TODO
  func :cpSpaceStep, [:pointer,:double], :void
  #func :cpSpaceResizeActiveHash, [:pointer,CP_FLOAT,:int], :void #TODO
  #func :cpSpaceResizeStaticHash, [:pointer,CP_FLOAT,:int], :void #TODO


  func :cpSpaceSetDefaultCollisionHandler, [:pointer, :uint, :uint,
   :pointer, :pointer, :pointer, :pointer, :pointer], :void
  func :cpSpaceAddCollisionHandler, [:pointer, :uint, :uint,
   :cpCollisionBeginFunc, :cpCollisionPreSolveFunc, :cpCollisionPostSolveFunc, :cpCollisionSeparateFunc, :pointer], :void
  func :cpSpaceRemoveCollisionHandler, [:pointer, :uint, :uint], :void

  func :cpSpacePointQuery, [:pointer, Vect.by_value, :uint, :uint, :cpSpacePointQueryFunc, :pointer], :pointer
  func :cpSpacePointQueryFirst, [:pointer, Vect.by_value, :uint, :uint], :pointer

  func :cpSpaceSegmentQuery, [:pointer, Vect.by_value, Vect.by_value, :uint, :uint, :cpSpaceSegmentQueryFunc, :pointer], :int
  func :cpSpaceSegmentQueryFirst, [:pointer, Vect.by_value, Vect.by_value, :uint, :uint, :pointer], :pointer
  
  func :cpSpaceBBQuery, [:pointer, :pointer, :uint, :uint, :cpSpaceBBQueryFunc, :pointer], :void



  class Space 
    attr_reader :struct
    def initialize
      @struct = SpaceStruct.new(CP.cpSpaceNew)
      @static_shapes = []
      @active_shapes = []
      @bodies = []
      @constraints = []
      @blocks = {}
      @callbacks = {}
      @test_callbacks = Hash.new {|h,k| h[k] = {:begin => nil, :pre => nil, :post => nil, :sep => nil}}
    end
    
    def iterations
      @struct.iterations
    end
    def iterations=(its)
      @struct.iterations = its
    end

    def elastic_iterations
      @struct.elastic_iterations
    end
    def elastic_iterations=(elastic_its)
      @struct.elastic_iterations = elastic_its
    end

    def damping
      @struct.damping
    end
    def damping=(damp)
      @struct.damping = damp
    end

    def gravity
      Vec2.new @struct.gravity
    end
    def gravity=(v)
      @struct.gravity.pointer.put_bytes 0, v.struct.to_bytes, 0,Vect.size
    end

    #def add_collision_func(a,b,&block)
    #  beg = nil
    #  pre = nil
    #  unless block.nil?
    #    pre = Proc.new do |arb_ptr,space_ptr,data_ptr|
    #      begin
    #        arb = ArbiterStruct.new(arb_ptr)
    #
    #        swapped = arb.swapped_col == 0 ? false : true
    #        arba = swapped ? arb.b : arb.a
    #        arbb = swapped ? arb.a : arb.b
    #
    #        as = ShapeStruct.new(arba)
    #        a_obj_id = as.data.get_long 0
    #        rb_a = ObjectSpace._id2ref a_obj_id
    #
    #        bs = ShapeStruct.new(arbb)
    #        b_obj_id = bs.data.get_long 0
    #        rb_b = ObjectSpace._id2ref b_obj_id
    #
    #        block.call rb_a, rb_b
    #        1
    #      rescue Exception => ex
    #        puts ex.message
    #        puts ex.backtrace
    #        0
    #      end
    #    end
    #  else
    #    # needed for old chipmunk style 
    #    pre = Proc.new do |arb_ptr,space_ptr,data_ptr|
    #      0
    #    end
    #  end
    #  post = nil
    #  sep = nil
    #  data = nil
    #  a_id = a.object_id
    #  b_id = b.object_id
    #  CP.cpSpaceAddCollisionHandler(@struct.pointer, a_id, b_id,
    #      beg,pre,post,sep,data)
    #  @blocks[[a_id,b_id]] = pre
    #  nil
    #end

    #def remove_collision_func(a,b)
    #  a_id = a.object_id
    #  b_id = b.object_id
    #  CP.cpSpaceRemoveCollisionHandler(@struct.pointer, a_id, b_id)
    #  @blocks.delete [a_id,b_id]
    #  nil
    #end

    def set_default_collision_func(&block)
      raise "Not Implmented yet"
      @blocks[:default] = block 
    end

    def wrap_collision_callback(a,b,type,handler)
      arity = handler.method(type).arity
      callback = Proc.new do |arb_ptr,space_ptr,data_ptr|
        arbiter = Arbiter.new(arb_ptr)
        
        ret = case arity
        when 1 then handler.send type, arbiter
        when 2 then handler.send type, *arbiter.shapes
        when 3 then handler.send type, arbiter, *arbiter.shapes
        else raise ArgumentError
        end
        ret ? 1 : 0
      end
      @callbacks[[a,b,type]] = [handler,callback]
      @test_callbacks[[a,b]][type] = callback
      callback
    end

    # handler should have methods [beg,pre,post,sep] defined
    def add_collision_handler(a,b,handler)
      a_id = a.object_id
      b_id = b.object_id

      beg = handler.respond_to?(:begin) ? wrap_collision_callback(a, b, :begin, handler) : nil
      pre = handler.respond_to?(:pre) ? wrap_collision_callback(a, b, :pre, handler) : nil
      post = handler.respond_to?(:post) ? wrap_collision_callback(a, b, :post, handler) : nil
      sep = handler.respond_to?(:sep) ? wrap_collision_callback(a, b, :sep, handler) : nil
      data = nil

      CP.cpSpaceAddCollisionHandler(@struct.pointer, 
        a_id, b_id, beg,pre,post,sep,data)
    end

    def add_collision_func(a,b,type=:pre,&block)
      arity = block.arity
      callback = Proc.new do |arb_ptr,space_ptr,data_ptr|
        arbiter = Arbiter.new(arb_ptr)
        ret = case arity
        when 1 then block.call(arbiter)
        when 2 then block.call(*arbiter.shapes)
        when 3 then block.call(arbiter,*arbiter.shapes)
        else raise ArgumentError
        end
        ret ? 1 : 0
      end
      @test_callbacks[[a,b]][type] = callback
      setup_callbacks(a,b)
    end

    def remove_collision_func(a,b,type=:pre)
      @test_callbacks[[a,b]][type] = nil
      setup_callbacks(a,b)
    end

    def setup_callbacks(a,b)
      a_id = a.object_id
      b_id = b.object_id
      cbs = @test_callbacks[[a,b]]
      CP.cpSpaceAddCollisionHandler(@struct.pointer,a_id,b_id,
      cbs[:begin],cbs[:pre],cbs[:post],cbs[:sep],nil)
    end

    def add_shape(shape)
      CP.cpSpaceAddShape(@struct.pointer, shape.struct.pointer)
      @active_shapes << shape
      shape
    end

    def add_static_shape(shape)
      CP.cpSpaceAddStaticShape(@struct.pointer, shape.struct.pointer)
      @static_shapes << shape
      shape
    end

    def add_body(body)
      CP.cpSpaceAddBody(@struct.pointer, body.struct.pointer)
      @bodies << body
      body
    end

    def add_constraint(con)
      CP.cpSpaceAddConstraint(@struct.pointer, con.struct.pointer)
      @constraints << con
      con
    end

    def remove_shape(shape)
      CP.cpSpaceRemoveShape(@struct.pointer, shape.struct.pointer)
      @active_shapes.delete shape
      shape
    end

    def remove_static_shape(shape)
      CP.cpSpaceRemoveStaticShape(@struct.pointer, shape.struct.pointer)
      @static_shapes.delete shape
      shape
    end

    def remove_body(body)
      CP.cpSpaceRemoveBody(@struct.pointer, body.struct.pointer)
      @bodies.delete body
      body
    end

    def remove_constraint(con)
      CP.cpSpaceRemoveConstraint(@struct.pointer, con.struct.pointer)
      @constraints.delete con
      con
    end

    def resize_static_hash(dim, count)
      CP.cpSpaceResizeStaticHash @struct.pointer, dim, count
    end

    def resize_active_hash(dim, count)
      CP.cpSpaceResizeActiveHash @struct.pointer, dim, count
    end

    def rehash_static
      CP.cpSpaceRehashStatic @struct.pointer
    end

    def step(dt)
      CP.cpSpaceStep @struct.pointer, dt
    end

    def each_body(&block)
      @bodies.each &block
#      typedef void (*cpSpaceBodyIterator)(cpBody *body, void *data);
#      void cpSpaceEachBody(cpSpace *space, cpSpaceBodyIterator func, void *data);
    end

    def shape_point_query(pt)
      point_query_first pt, ALL_ONES, 0
    end

    def static_shape_point_query(pt)
      raise "Not Implmented yet"
    end

    def point_query_first(point, layers, group)
      shape_ptr = CP.cpSpacePointQueryFirst(@struct.pointer, point.struct, layers, group)
      if shape_ptr.null?
        nil
      else
        shape = ShapeStruct.new(shape_ptr)
        obj_id = shape.data.get_long 0
        ObjectSpace._id2ref obj_id
      end
    end

    def active_shapes_hash
      SpaceHash.new(SpaceHashStruct.new(@struct.active_shapes))
    end

    def point_query(point, layers, group, &block)
      return nil unless block_given?

      query_proc = Proc.new do |shape_ptr,data|
        shape = ShapeStruct.new(shape_ptr)
        obj_id = shape.data.get_long 0
        shape = ObjectSpace._id2ref obj_id
        block.call shape
      end

      CP.cpSpacePointQuery(@struct.pointer, point.struct, layers, group,query_proc,nil)
    end

    class SegmentQueryInfo
      attr_reader :hit,:shape, :t, :n
      def initialize(hit,shape,t=nil,n=nil,info=nil)
        @hit = hit
        @shape = shape
        @t = t
        @n = n
        @info = info
      end
    end

    def shape_segment_query(a,b,layers=ALL_ONES,group=0)
      segment_query_first(a,b,layers,group).shape
    end
    
    def info_segment_query(a,b,layers=ALL_ONES,group=0)
      segment_query_first(a,b,layers,group)
    end

    def segment_query_first(a,b,layers,group)
      out_ptr = FFI::MemoryPointer.new(SegmentQueryInfoStruct.size)
      info = SegmentQueryInfoStruct.new out_ptr

      shape_ptr = CP.cpSpaceSegmentQueryFirst(@struct.pointer, a.struct, b.struct,layers,group,out_ptr)
      if shape_ptr.null?
        SegmentQueryInfo.new(false,nil,nil,nil,info)
      else
        shape_struct = ShapeStruct.new(shape_ptr)
        obj_id = shape_struct.data.get_long(0)
        shape = ObjectSpace._id2ref(obj_id)
        n_vec = Vec2.new(info.n)
        SegmentQueryInfo.new(true,shape,info.t,n_vec,info)
      end
    end
    
    def segment_query(a,b,layers,group,&block)
      return nil unless block_given?
      query_proc = Proc.new do |shape_ptr,t,n,data|
        shape_struct = ShapeStruct.new(shape_ptr)
        obj_id = shape_struct.data.get_long(0)
        shape = ObjectSpace._id2ref(obj_id)
        block.call(shape,t,n)
      end
      
      CP.cpSpaceSegmentQuery(@struct.pointer, a.struct, b.struct, layers, group, query_proc, nil)
    end
    
    def bb_query(bb, layers, group, &block)
		query_proc = Proc.new do |shape_ptr, data|
			shape_struct = ShapeStruct.new(shape_ptr)
			obj_id = shape_struct.data.get_long(0)
	        shape = ObjectSpace._id2ref(obj_id)
	        block.call(shape)
		end
    
		CP.cpSpaceBBQuery(@struct.pointer, bb.struct, layers, group, query_proc ,nil)
    end

  end
end

