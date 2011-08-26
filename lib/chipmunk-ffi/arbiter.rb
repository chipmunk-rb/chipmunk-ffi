module CP
  callback :cpCollisionBeginFunc, [:pointer]*3, :int
  callback :cpCollisionPreSolveFunc, [:pointer]*3, :int
  callback :cpCollisionPostSolveFunc, [:pointer]*3, :void
  callback :cpCollisionSeparateFunc, [:pointer]*3, :void

  class CollisionHandlerStruct < NiceFFI::Struct
    layout :a, :uint,
           :b, :uint,
           :begin_func, :cpCollisionBeginFunc,
           :pre_solve, :cpCollisionPreSolveFunc,
           :postSolve, :cpCollisionPostSolveFunc,
           :separate, :cpCollisionSeparateFunc,
           :data, :pointer
  end

  enum :arbiter_state, [:first_collision,
                        :normal,
                        :ignore,
                        :cached]

  class ArbiterThread < NiceFFI::Struct
    layout :next_arbiter, :pointer,
           :prev_arbiter, :pointer
  end

  class ArbiterStruct < NiceFFI::Struct
    layout :e, CP_FLOAT,
           :u, CP_FLOAT,
           :surface_vr, VECT,
           #only private fields below
           :a, :pointer,
           :b, :pointer,
           :body_a, :pointer,
           :body_b, :pointer,
           :thread_a, ArbiterThread,
           :thread_b, ArbiterThread,
           :num_contacts, :int,
           :contacts, :pointer,
           :stamp, :uint,
           :handler, :pointer,
           :swapped_col, :int,
           :state, :arbiter_state
  end

  func :cpArbiterTotalImpulse, [:pointer], VECT
  func :cpArbiterTotalImpulseWithFriction, [:pointer], VECT
  func :cpArbiterIgnore, [:pointer], :void

  cp_static_inline :cpArbiterGetShapes, [:pointer]*3, :void
  cp_static_inline :cpArbiterGetBodies, [:pointer]*3, :void
  cp_static_inline :cpArbiterIsFirstContact, [:pointer], :int
  cp_static_inline :cpArbiterGetCount, [:pointer], :int

  class ContactPointSet < NiceFFI::Struct
    class ContactPoint < NiceFFI::Struct
      layout :point, VECT,
             :normal, VECT,
             :dist, CP_FLOAT
    end
    layout :count, :int,
           :points, [ContactPoint, 4]
    #TODO consider constants for types and numbers like CP_MAX_CONTACTS_PER_ARBITER = 4
    #that would be mostly copying chipmunk_types.h
  end

  func :cpArbiterGetContactPointSet, [:pointer], ContactPointSet.by_value
  func :cpArbiterGetNormal, [:pointer, :int], VECT
  func :cpArbiterGetPoint, [:pointer, :int], VECT
  func :cpArbiterGetDepth, [:pointer, :int], CP_FLOAT

  class Arbiter
    attr_reader :struct
    def initialize(ptr)
      @struct = ArbiterStruct.new(ptr)
      @shapes = nil
      
      # Temporary workaround for a bug in chipmunk, fixed in r342.
      @struct.num_contacts = 0 if @struct.contacts.null? #TODO check if still needed
    end
    
    def first_contact?
      @struct.state == :first_collision
    end
    
    def point(index = 0)
      raise IndexError unless (0...@struct.num_contacts).include? index
      Vec2.new CP.cpArbiterGetPoint(@struct.pointer, index)
    end
    
    def normal(index = 0)
      raise IndexError unless (0...@struct.num_contacts).include? index
      Vec2.new CP.cpArbiterGetNormal(@struct.pointer, index)
    end
    
    def impulse with_friction = false
      if with_friction
        Vec2.new CP.cpArbiterTotalImpulseWithFriction(@struct.pointer)
      else
        Vec2.new CP.cpArbiterTotalImpulse(@struct.pointer)
      end
    end
    
    def shapes
      return @shapes if @shapes

      swapped = @struct.swapped_col.nonzero?
      arba = swapped ? @struct.b : @struct.a
      arbb = swapped ? @struct.a : @struct.b

      as = ShapeStruct.new(arba)
      a_obj_id = as.data.get_long 0
      rb_a = ObjectSpace._id2ref a_obj_id

      bs = ShapeStruct.new(arbb)
      b_obj_id = bs.data.get_long 0
      rb_b = ObjectSpace._id2ref b_obj_id

      @shapes = [ rb_a, rb_b ]
    end
    
    def a
      self.shapes[0]
    end
    
    def b
      self.shapes[1]
    end
    
    def e
      @struct.e
    end
    def e=(new_e)
      @struct.e = new_e
    end
    
    def u
      @struct.u
    end
    def u=(new_u)
      @struct.u = new_u
    end
    
    def each_contact
      (0...@struct.num_contacts).each do |index|
        yield CP.cpArbiterGetPoint(@struct, index), CP.cpArbiterGetNormal(@struct, index)
      end
    end
  end
  
end

