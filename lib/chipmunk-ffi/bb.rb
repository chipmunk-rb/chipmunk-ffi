module CP

  class BBStruct < NiceFFI::Struct
    layout(:l, CP_FLOAT,
           :b, CP_FLOAT,
           :r, CP_FLOAT,
           :t, CP_FLOAT )
  end

  bb = BBStruct.by_value
  vect = Vect.by_value

  cp_static_inline :cpBBNew, [CP_FLOAT]*4, bb
  cp_static_inline :cpBBIntersects, [bb, bb], :int
  cp_static_inline :cpBBContainsBB, [bb, bb], :int
  cp_static_inline :cpBBContainsVect, [bb, vect], :int
  cp_static_inline :cpBBMerge, [bb, bb], bb
  cp_static_inline :cpBBExpand, [bb, vect], bb
  cp_static_inline :cpBBArea, [bb], CP_FLOAT
  cp_static_inline :cpBBMergedArea, [bb, bb], CP_FLOAT
  cp_static_inline :cpBBIntersectsSegment, [bb, vect, vect], :int

  func :cpBBClampVect, [bb, vect], vect
  func :cpBBWrapVect, [bb, vect], vect

  class BB
    attr_reader :struct
    def initialize(*args)
      case args.size
      when 1
        @struct = args.first
      when 4
        @struct = CP.cpBBNew(*args)
      else
        raise "wrong number of args for BB, got #{args.size}, but expected 4"
      end
    end

    [:l, :b, :r, :t].each do |f|
      define_method(f) { @struct[f] }
      define_method("#{f}=") { |new_f| @struct[f] = new_f }
    end

    def intersects?(other_bb)
      b = CP.cpBBIntersects(@struct,other_bb.struct)
      b != 0
    end

    def contains_bb?(other_bb)
      b = CP.cpBBContainsBB(@struct,other_bb.struct)
      b != 0
    end

    def contains_vect?(vect)
      b = CP.cpBBContainsVect(@struct,vect.struct)
      b != 0
    end

    def ==(other_bb)
      [:l, :b, :r, :t].each { |f| return false unless @struct[f] == other_bb.struct[f] }
      true
    end

    def merge(other_bb)
      CP::BB.new CP.cpBBMerge(@struct, other_bb.struct)
    end

    def +(other_bb)
      CP::BB.new CP.cpBBMerge(@struct, other_bb.struct)
    end

    def expand(vect)
      CP::BB.new CP.cpBBExpand(@struct, vect.struct)
    end

    def area
      CP.cpBBArea @struct
    end

    def merged_area(other_bb)
      CP.cpBBMergedArea @struct, other_bb.struct
    end

    def intersects_segment?(vect_1, vect_2)
      b = CP.cpBBIntersectsSegment @struct, vect_1.struct, vect_2.struct
      b != 0
    end

    def clamp_vect(v)
      v_struct = CP.cpBBClampVect(@struct,v.struct)
      Vec2.new v_struct
    end

    def wrap_vect(v)
      v_struct = CP.cpBBWrapVect(@struct,v.struct)
      Vec2.new v_struct
    end

    def to_s
      "#<CP::BB:(% .3f, % .3f) -> (% .3f, % .3f)>" % [l,b,r,t]
    end
  end

end

