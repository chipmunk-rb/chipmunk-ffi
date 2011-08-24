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
             :target_vrn, CP_FLOAT,
             :v_coef, CP_FLOAT,
             :r1, Vect,
             :r2, Vect,
             :n_mass, CP_FLOAT,
             :n, Vect)
  end

  func :cpDampedSpringNew, [:pointer, :pointer, VECT, VECT, CP_FLOAT, CP_FLOAT, CP_FLOAT], :pointer

  class DampedSpring
    include Constraint
    struct_accessor DampedSpringStruct, :anchr1, :anchr2, :rest_length, :damping, :stiffness
    def initialize(a_body, b_body, anchr_one, anchr_two, 
                   rest_length, stiffness, damping)
      @body_a, @body_b = a_body, b_body
      @struct = DampedSpringStruct.new(CP.cpDampedSpringNew(
        a_body.struct.pointer,b_body.struct.pointer,anchr_one.struct,anchr_two.struct,
        rest_length, stiffness, damping))
      set_data_pointer
      set_initial_force_proc
    end
    
    def spring_force_func
      @user_level_force_lambda
    end
    
    def spring_force_func=(l)
      @user_level_force_lambda = l
      
      # We keep the lambda in an ivar to keep it from being GCed
      @spring_force_lambda = Proc.new do |spring_ptr,dist|
        spring_struct = DampedSpringStruct.new(spring_ptr)
        obj_id = spring_struct.constraint.data.get_long(0)
        spring = ObjectSpace._id2ref(obj_id)
        l.call(spring,dist)
      end
      @struct.spring_force_func = @spring_force_lambda
    end
    
    private
    def set_initial_force_proc
      ffi_func = @struct.spring_force_func
      @user_level_force_lambda ||= Proc.new do |spring, dist|
        ffi_func.call(spring.struct,dist)
      end
    end
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::DampedSpring = CP::DampedSpring
