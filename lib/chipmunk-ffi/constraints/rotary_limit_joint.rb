module CP

  class RotaryLimitJointStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :min, CP_FLOAT,
             :max, CP_FLOAT,
             :i_sum, CP_FLOAT,
             :bias, CP_FLOAT,
             :j_acc, CP_FLOAT,
             :j_max, CP_FLOAT)
  end
  func :cpRotaryLimitJointNew, [:pointer, :pointer, CP_FLOAT, CP_FLOAT], :pointer

  class RotaryLimitJoint
    include Constraint
    struct_accessor RotaryLimitJointStruct, :min, :max
    def initialize(a_body, b_body, min, max)
      @body_a, @body_b = a_body, b_body
      @struct = RotaryLimitJointStruct.new(CP.cpRotaryLimitJointNew(
        a_body.struct.pointer,b_body.struct.pointer,min,max))
    end
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::RotaryLimitJoint = CP::RotaryLimitJoint