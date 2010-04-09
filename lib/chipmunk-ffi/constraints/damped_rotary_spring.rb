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
      set_data_pointer
      set_initial_torque_proc        
    end
    
    def spring_torque_func
      @user_level_torque_lambda
    end
    
    def spring_torque_func=(l)
      @user_level_torque_lambda = l
      
      # We keep the lambda in an ivar to keep it from being GCed
      @spring_torque_lambda = Proc.new do |spring_ptr,angle|
        spring_struct = DampedRotarySpringStruct.new(spring_ptr)
        obj_id = spring_struct.constraint.data.get_long(0)
        spring = ObjectSpace._id2ref(obj_id)
        l.call(spring,angle)
      end
      @struct.spring_torque_func = @spring_torque_lambda
    end
    
    private
    def set_initial_torque_proc
      ffi_func = @struct.spring_torque_func
      @user_level_torque_lambda ||= Proc.new do |spring, angle|
        ffi_func.call(spring.struct,angle)
      end
    end
    
  end
end

# Alias for compatibility with chipmunk C-Ruby bindings.
CP::Constraint::DampedRotarySpring = CP::DampedRotarySpring
