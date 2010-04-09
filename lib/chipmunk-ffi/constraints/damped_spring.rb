module CP

  callback :cpDampedSpringForceFunc, [:pointer, CP_FLOAT], CP_FLOAT

  class DampedSpringStruct < NiceFFI::Struct
    layout(:constraint, ConstraintStruct,
             :anchr1, Vect,
             :anchr2, Vect,
             :rest_length, CP_FLOAT,
             :stiffness, CP_FLOAT,
             :damping, CP_FLOAT,
             :spring_force_func, :cpDampedSpringForceFunc,
             :dt, CP_FLOAT,
             :target_vrn, CP_FLOAT,
             :r1, Vect,
             :r2, Vect,
             :n_mass, CP_FLOAT,
             :n, Vect)
  end

  func :cpDampedSpringNew, [:pointer, :pointer, Vect.by_value, Vect.by_value, CP_FLOAT, CP_FLOAT, CP_FLOAT], :pointer

  class DampedSpring
    include Constraint
    struct_accessor DampedSpringStruct, :anchr1, :anchr2, :rest_length, :damping, :stiffness
    def initialize(a_body, b_body, anchr_one, anchr_two, 
                   rest_length, stiffness, damping)
      @body_a, @body_b = a_body, b_body
      @struct = DampedSpringStruct.new(CP.cpDampedSpringNew(
        a_body.struct.pointer,b_body.struct.pointer,anchr_one.struct,anchr_two.struct,
        rest_length, stiffness, damping))
    #  @__default_force_func = default_force_func = @struct.spring_force_func
    #  @__default_force_lambda = @spring_force_lambda = Proc.new {|dist| default_force_func.call(@struct,dist) }
    end
    
    
    # FIXME: Ideally, we'd prefer to pass DampedSprings, rather than DampedSpringStructs,
    # to the user's lambda; or, better still, pass no spring at all, and allow them to refer
    # to self. However, this means using wrapper procs in both the getter and the setter; in
    # the case where the user takes a lambda recieved from a reader and supplies it to a writer;
    # Each time this happens, we get a more deeply nested chain of lambdas.
    def spring_force_func
      @struct.spring_force_func
    end
    
    def spring_force_func=(l)
      @spring_force_lambda = l # Keep the lambda from being GCed
      @struct.spring_force_func = @spring_force_lambda
    end
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::DampedSpring = CP::DampedSpring
