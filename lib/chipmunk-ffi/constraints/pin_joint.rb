module CP

  class PinJointStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :anchr1, Vect,
             :anchr2, Vect,
             :dist, CP_FLOAT,
             :r1, Vect,
             :r2, Vect,
             :n, Vect,
             :n_mass, CP_FLOAT,
             :jn_acc, CP_FLOAT,
             :jn_max, CP_FLOAT,
             :bias, CP_FLOAT)
  end
  func :cpPinJointNew, [:pointer, :pointer, Vect.by_value, Vect.by_value], :pointer

  class PinJoint
    include Constraint
    struct_accessor PinJointStruct, :anchr1, :anchr2, :dist
    def initialize(a_body, b_body, anchr_one, anchr_two)
      @body_a, @body_b = a_body, b_body
      @struct = PinJointStruct.new(CP.cpPinJointNew(
        a_body.struct.pointer,b_body.struct.pointer,anchr_one.struct,anchr_two.struct))
    end
  end
end
