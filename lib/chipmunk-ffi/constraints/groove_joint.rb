module CP

  class GrooveJointStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :grv_n, Vect,
             :grv_a, Vect,
             :grv_b, Vect,
             :anchr2, Vect,
             :grv_tn, Vect,
             :clamp, CP_FLOAT,
             :r1, Vect,
             :r2, Vect,
             :k1, Vect,
             :k2, Vect,
             :j_acc, Vect,
             :j_max_length, CP_FLOAT,
             :bias, Vect)
  end

  func :cpGrooveJointNew, [:pointer, :pointer, Vect.by_value, Vect.by_value, Vect.by_value], :pointer

  class GrooveJoint
    include Constraint
    struct_accessor GrooveJointStruct, :anchr2
    def initialize(a_body, b_body, groove_a, groove_b, anchr2)
      @body_a, @body_b = a_body, b_body
      @struct = GrooveJointStruct.new(CP.cpGrooveJointNew(
        a_body.struct.pointer,b_body.struct.pointer,groove_a.struct,groove_b.struct,anchr2.struct))
    end
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::GrooveJoint = CP::GrooveJoint