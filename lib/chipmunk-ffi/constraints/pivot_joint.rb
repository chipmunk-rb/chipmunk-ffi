module CP

  class PivotJointStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :anchr1, Vect,
             :anchr2, Vect,
             :r1, Vect,
             :r2, Vect,
             :k1, Vect,
             :k2, Vect,
             :j_acc, Vect,
             :j_max, CP_FLOAT,
             :bias, CP_FLOAT)
  end
  func :cpPivotJointNew, [:pointer, :pointer, VECT], :pointer
  func :cpPivotJointNew2, [:pointer, :pointer, VECT, VECT], :pointer

  class PivotJoint
    include Constraint
    struct_accessor PivotJointStruct, :anchr1, :anchr2
    def initialize(a_body, b_body, anchr_one, anchr_two=nil)
      @body_a, @body_b = a_body, b_body
      @struct = if anchr_two.nil?
        PivotJointStruct.new(CP.cpPivotJointNew(
          a_body.struct.pointer,b_body.struct.pointer,anchr_one.struct))
      else
        PivotJointStruct.new(CP.cpPivotJointNew2(
          a_body.struct.pointer,b_body.struct.pointer,anchr_one.struct,anchr_two.struct))
      end
    end
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::PivotJoint = CP::PivotJoint
