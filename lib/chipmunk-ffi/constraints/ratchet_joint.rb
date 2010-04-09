module CP

  class RatchetJointStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :angle, CP_FLOAT,
             :phase, CP_FLOAT,
             :ratchet, CP_FLOAT,
             :i_sum, CP_FLOAT,
             :bias, CP_FLOAT,
             :j_acc, CP_FLOAT,
             :j_max, CP_FLOAT)
  end
  func :cpRatchetJointNew, [:pointer, :pointer, CP_FLOAT, CP_FLOAT], :pointer

  class RatchetJoint
    include Constraint
    struct_accessor RatchetJointStruct, :angle, :phase, :ratchet
    def initialize(a_body, b_body, phase, ratchet)
      @body_a, @body_b = a_body, b_body
      @struct = RatchetJointStruct.new(CP.cpRatchetJointNew(
        a_body.struct.pointer,b_body.struct.pointer,phase,ratchet))
    end
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::RatchetJoint = CP::RatchetJoint