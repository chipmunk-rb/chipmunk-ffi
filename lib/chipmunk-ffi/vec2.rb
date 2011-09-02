module CP
  class Vect < FFI::Struct
    layout(:x, CP_FLOAT,
           :y, CP_FLOAT)

    def self.release(ptr)
      free ptr
    end

    def initialize(ptr)
      case ptr
        when FFI::MemoryPointer, FFI::Buffer, FFI::AutoPointer
          super ptr
        else
          super FFI::AutoPointer.new(ptr, self.class.method(:release))
      end
    end

    def to_bytes
      return self.pointer.get_bytes(0, self.size)
    end
  end

  VECT = Vect.by_value #most used in signatures definition, never a

  cp_static_inline :cpv, [CP_FLOAT]*2, VECT
  cp_static_inline :cpvneg, [VECT], VECT
  cp_static_inline :cpvadd, [VECT]*2, VECT
  cp_static_inline :cpvsub, [VECT]*2, VECT
  cp_static_inline :cpvmult, [VECT, CP_FLOAT], VECT
  cp_static_inline :cpvdot, [VECT]*2, CP_FLOAT
  cp_static_inline :cpvcross, [VECT]*2, CP_FLOAT

  cp_static_inline :cpvperp, [VECT], VECT
  cp_static_inline :cpvrperp, [VECT], VECT
  cp_static_inline :cpvproject, [VECT]*2, VECT
  cp_static_inline :cpvrotate, [VECT]*2, VECT
  cp_static_inline :cpvunrotate, [VECT]*2, VECT

  cp_static_inline :cpvlengthsq, [VECT], CP_FLOAT

  cp_static_inline :cpvlerp, [VECT, VECT, CP_FLOAT], VECT

  cp_static_inline :cpvnormalize, [VECT], VECT
  cp_static_inline :cpvnormalize_safe, [VECT], VECT

  cp_static_inline :cpvclamp, [VECT, CP_FLOAT], VECT
  cp_static_inline :cpvlerpconst, [VECT, VECT, CP_FLOAT], VECT
  cp_static_inline :cpvdist, [VECT]*2, CP_FLOAT
  cp_static_inline :cpvdistsq, [VECT]*2, CP_FLOAT

  cp_static_inline :cpvnear, [VECT, VECT, CP_FLOAT], :int

  func :cpvlength, [VECT], CP_FLOAT
  func :cpvforangle, [CP_FLOAT], VECT
  func :cpvslerp, [VECT, VECT, CP_FLOAT], VECT
  func :cpvslerpconst, [VECT, VECT, CP_FLOAT], VECT
  func :cpvtoangle, [VECT], CP_FLOAT
  func :cpvstr, [VECT], :string

  class Vec2
    attr_accessor :struct
    def initialize(*args)
      case args.size
      when 1
        @struct = args.first
      when 2
        @struct = CP.cpv(*args)
      else
        raise "wrong number of arguments (#{args.size} for 2)"
      end
    end

    def x
      @struct[:x]
    end
    def x=(new_x)
      raise TypeError, "can't modify frozen vec2" if frozen?
      @struct[:x] = new_x
    end
    def y
      @struct[:y]
    end
    def y=(new_y)
      raise TypeError, "can't modify frozen vec2" if frozen?
      @struct[:y] = new_y
    end

    def self.for_angle(angle)
      Vec2.new CP.cpvforangle(angle)
    end

    def to_s
      CP.cpvstr @struct
    end

    def to_angle
      CP.cpvtoangle @struct
    end

    def to_a
      [@struct[:x],@struct[:y]]
    end

    def -@
      Vec2.new CP.cpvneg(@struct)  
    end

    def +(other_vec)
      Vec2.new CP.cpvadd(@struct, other_vec.struct)
    end

    def -(other_vec)
      Vec2.new CP.cpvsub(@struct, other_vec.struct)
    end

    def *(s)
      Vec2.new CP.cpvmult(@struct, s)
    end

    def /(s)
      factor = 1.0/s
      Vec2.new CP.cpvmult(@struct, factor)
    end

    def dot(other_vec)
      CP.cpvdot(@struct, other_vec.struct)
    end

    def cross(other_vec)
      CP.cpvcross(@struct, other_vec.struct)
    end

    def perp
      Vec2.new CP.cpvperp(@struct)
    end

    def rperp
      Vec2.new CP.cpvrperp(@struct)
    end

    def project(other_vec)
      Vec2.new CP.cpvproject(@struct, other_vec.struct)
    end

    def rotate(other_vec)
      Vec2.new CP.cpvrotate(@struct, other_vec.struct)
    end

    def unrotate(other_vec)
      Vec2.new CP.cpvunrotate(@struct, other_vec.struct)
    end

    def lengthsq
      CP.cpvlengthsq(@struct)
    end

    def lerp(other_vec, t)
      Vec2.new CP.cpvlerp(@struct, other_vec.struct, t)
    end

    def normalize
      Vec2.new CP.cpvnormalize(@struct)
    end

    def normalize!
      @struct = CP.cpvnormalize(@struct)
      self
    end

    def normalize_safe
      Vec2.new CP.cpvnormalize_safe(@struct)
    end

    def clamp(len)
      Vec2.new CP.cpvclamp(@struct, len)
    end

    def lerpconst(other_vec, d)
      Vec2.new CP.cpvlerpconst(@struct, other_vec.struct, d)
    end

    def dist(other_vec)
      CP.cpvdist(@struct, other_vec.struct)
    end

    def distsq(other_vec)
      CP.cpvdistsq(@struct, other_vec.struct)
    end

    def near?(other_vec, dist)
      delta_v = CP.cpvsub(@struct, other_vec.struct)
      CP.cpvdot(delta_v, delta_v) < dist*dist
    end

    def length
      CP::cpvlength @struct
    end

    def ==(other)
      self.x == other.x && self.y == other.y
    end

  end
  ZERO_VEC_2 = Vec2.new(0,0).freeze
  def zero
    ZERO_VEC_2
  end
end
def vec2(x,y)
  CP::Vec2.new x, y
end
