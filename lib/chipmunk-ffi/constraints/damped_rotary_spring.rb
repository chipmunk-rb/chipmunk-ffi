module CP

  callback :cpDampedRotarySpringTorqueFunc, [:pointer, CP_FLOAT], CP_FLOAT

  class DampedRotarySpringStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :rest_angle, CP_FLOAT,
             :stiffness, CP_FLOAT,
             :damping, CP_FLOAT,
             :spring_torque_func, :cpDampedRotarySpringTorqueFunc,
             :dt, CP_FLOAT,
             :target_wrn, CP_FLOAT,
             :i_sum, CP_FLOAT)
  end

  func :cpDampedRotarySpringNew, [:pointer, :pointer, CP_FLOAT, CP_FLOAT, CP_FLOAT], :pointer

  class DampedRotarySpring
    include Constraint
    struct_accessor DampedRotarySpringStruct, :rest_angle, :damping, :stiffness
    def initialize(a_body, b_body,rest_angle, stiffness, damping)
      @body_a, @body_b = a_body, b_body
      @struct = DampedRotarySpringStruct.new(CP.cpDampedRotarySpringNew(
        a_body.struct.pointer,b_body.struct.pointer, rest_angle, stiffness, damping))
    end
    
    
    # FIXME: Ideally, we'd prefer to pass DampedSprings, rather than DampedSpringStructs,
    # to the user's lambda; or, better still, pass no spring at all, and allow them to refer
    # to self. However, this means using wrapper procs in both the getter and the setter; in
    # the case where the user takes a lambda recieved from a reader and supplies it to a writer;
    # Each time this happens, we get a more deeply nested chain of lambdas.
    def spring_torque_func
      @struct.spring_torque_func
    end
    
    def spring_torque_func=(l)
      @spring_torque_lambda = l # Keep the lambda from being GCed
      @struct.spring_torque_func = @spring_torque_lambda
    end
  end
end

