module CP

  enum :shape_type, [:circle_shape,
                     :segment_shape,
                     :poly_shape,
                     :num_shapes]

  callback :cacheData, [:pointer, VECT, VECT], BBStruct.by_value
  callback :destroy, [:pointer], :void
  callback :pointQuery, [:pointer, VECT], :int
  callback :segmentQuery, [:pointer, VECT, VECT,:pointer], :void

  class ShapeClassStruct < NiceFFI::Struct
    layout :type, :shape_type,
           :cacheData, :pointer,
           :destroy, :pointer,
           :pointQuery, :pointer,
           :segmentQuery, :pointer
  end

  class ShapeStruct < NiceFFI::Struct
    layout :klass, :pointer,
           :body, :pointer,
           :bb, BBStruct,
           :sensor, :int,
           :e, CP_FLOAT,
           :u, CP_FLOAT,
           :surface_v, VECT,
           :data, :pointer,
           :collision_type, :uint,
           :group, :uint,
           :layers, :uint,
           :hash_value, :size_t,
           #CP_PRIVATE values below, ergo unused.
           #Can't omit them, ShapeStruct is part of other structs
           :space, :pointer,
           :next, :pointer,
           :prev, :pointer,
           :hash_value, :uint
  end

  class SegmentQueryInfoStruct < NiceFFI::Struct
    layout :shape, :pointer,
           :t, CP_FLOAT,
           :n, VECT
  end

  class CircleShapeStruct < NiceFFI::Struct
    layout :shape, ShapeStruct,
           :c, VECT,
           :tc, VECT,
           :r, CP_FLOAT
  end

  class SegmentShapeStruct < NiceFFI::Struct
    layout :shape, ShapeStruct,
           :a, VECT,
           :b, VECT,
           :n, VECT,
           :ta, VECT,
           :tb, VECT,
           :tn, VECT,
           :r, CP_FLOAT
  end


  func :cpCircleShapeNew, [BodyStruct,CP_FLOAT, VECT], ShapeStruct
	func :cpCircleShapeGetRadius, [ShapeStruct], CP_FLOAT
  func :cpSegmentShapeNew, [BodyStruct, VECT, VECT,CP_FLOAT], ShapeStruct
  func :cpPolyShapeNew, [BodyStruct,:int,:pointer, VECT], ShapeStruct
  func :cpShapeCacheBB, [ShapeStruct], BBStruct.by_value
  func :cpResetShapeIdCounter, [], :void
  func :cpShapePointQuery, [:pointer, VECT], :int
	func :cpShapeSegmentQuery, [:pointer, VECT, VECT, :pointer], :int
  func :cpPolyValidate, [:pointer, :int], :int

  module Shape
    class SegmentQueryInfo
      attr_reader :hit, :t, :n
      def initialize(hit,t=nil,n=nil,info=nil,ptr=nil)
        @hit = hit
        @t = t
        @n = n
        @info = info
        @ptr = ptr
      end
    end

    attr_reader :struct

    def initialize(body, struct)
      super()
      @body = body
      @struct = struct
      @shape_struct = struct.shape
      @coll_type = @shape_struct.collision_type
      @group = @shape_struct.group
    end

    [:e, :u, :data, :layers].each do |f| #TODO consider implementing accessor using NiceFFI means
      define_method(f) { @shape_struct[f] }
      define_method("#{f}=") { |new_f| @shape_struct[f] = new_f }
    end

    def body
      @body
    end
    def body=(new_body)
      @body = new_body
      @shape_struct.body = new_body.struct.pointer
    end

    def collision_type
      @coll_type
    end
    def collision_type=(coll_type)
      @coll_type = coll_type
      @shape_struct.collision_type = coll_type.object_id
    end

    def group
      @group
    end
    def group=(group_obj)
      @group = group_obj
      @shape_struct.group = group_obj.object_id
    end

    def bb
      bb_ptr = FFI::MemoryPointer.new BBStruct.size
      bb_ptr.put_bytes 0, @shape_struct.bb.to_bytes, 0, BBStruct.size
      BB.new BBStruct.new bb_ptr
    end

    def cache_bb
      CP::BB.new CP.cpShapeCacheBB(@struct)  #TODO
    end

    def surface_v
      Vec2.new @shape_struct.surface_v
    end 
    def surface_v=(new_sv)
      @shape_struct.surface_v.pointer.put_bytes 0, new_sv.struct.to_bytes, 0, Vect.size
    end

    def sensor?
      @shape_struct.sensor != 0
    end
    def sensor=(new_sensor)
      @shape_struct.sensor = new_sensor ? 1 : 0
    end

    def point_query(point)
      bool_int = CP.cpShapePointQuery(@shape_struct.pointer, point.struct)
      bool_int == 0 ? false : true
    end

    def set_data_pointer
      mem = FFI::MemoryPointer.new(:long)
      mem.put_long 0, object_id
      # this is needed to prevent data corruption by GC
      @shape_pointer = mem
      @shape_struct.data = mem
    end

    def self.reset_id_counter
      CP.cpResetShapeIdCounter
    end

    def segment_query(a,b)
      ptr = FFI::MemoryPointer.new(SegmentQueryInfoStruct.size)
      info = SegmentQueryInfoStruct.new ptr
	
      bool_int = CP.cpShapeSegmentQuery(@struct.pointer, a.struct.pointer, b.struct.pointer, ptr)
      hit = bool_int == 0 ? false : true
      if hit
        #obj_id = info.shape.data.get_long 0
        #shape = ObjectSpace._id2ref obj_id
        # TODO prob need to dup these things
        n = Vec2.new(info.n)
        SegmentQueryInfo.new hit, info.t, n, info, ptr
      else
        SegmentQueryInfo.new hit
      end
    end

    class Circle
      include Shape

      def initialize(body, rad, offset_vec)
        ptr = CP.cpCircleShapeNew body.struct.pointer, rad, offset_vec.struct
        super body, CircleShapeStruct.new(ptr)
        set_data_pointer
      end

      def radius
        @shape_struct.r
      end
    end

    class Segment
      include Shape
      def initialize(body, v1, v2, r)
        ptr = CP.cpSegmentShapeNew body.struct.pointer, v1.struct, v2.struct, r
        super body, SegmentShapeStruct.new(ptr)
        set_data_pointer
      end
    end

    class Poly
      include Shape
      def initialize(body, verts, offset_vec)
        verts = CP::Shape::Poly.make_vertices_valid(verts)
        mem_pointer = CP::Shape::Poly.pointer_for_verts(verts)
        ptr = CP.cpPolyShapeNew body.struct.pointer, verts.size, mem_pointer, offset_vec.struct
        super body, SegmentShapeStruct.new(ptr)
        set_data_pointer
      end
      
      def self.pointer_for_verts(verts)
        mem_pointer = FFI::MemoryPointer.new Vect, verts.size
        vert_structs = verts.collect{|s|s.struct}

        size = Vect.size
        tmp = mem_pointer
        vert_structs.each_with_index {|i, j|
          tmp.send(:put_bytes, 0, i.to_bytes, 0, size)
          tmp += size unless j == vert_structs.length-1 # avoid OOB
        }
        return mem_pointer
      end
      
      def self.strictly_valid_vertices?(verts)
        mem_pointer = CP::Shape::Poly.pointer_for_verts(verts)
        result = CP.cpPolyValidate(mem_pointer,verts.size)
        return (result != 0)
      end
      
      def self.valid_vertices?(verts)
        CP::Shape::Poly.strictly_valid_vertices?(verts) || 
        CP::Shape::Poly.strictly_valid_vertices?(verts.reverse)
      end
      
      def self.make_vertices_valid(verts)
        if CP::Shape::Poly.strictly_valid_vertices?(verts)
          return verts
        elsif CP::Shape::Poly.strictly_valid_vertices?(verts.reverse)
          return verts.reverse
        else
          raise "Chipmunk-FFI Error: Vertices do not form convex polygon."
        end
      end
    end
  end


end
