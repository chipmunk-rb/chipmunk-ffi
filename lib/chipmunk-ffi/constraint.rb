require 'chipmunk-ffi/struct_accessor'

module CP
  callback :cpConstraintPreStepFunc, [:pointer, CP_FLOAT], :void
  callback :cpConstraintApplyCachedImpulseFunc, [:pointer, CP_FLOAT], :void
  callback :cpConstraintApplyImpulseFunc, [:pointer], :void
  callback :cpConstraintGetImpulseFunc, [:pointer], CP_FLOAT

  class ConstraintClassStruct < NiceFFI::Struct
    layout(:pre_step, :cpConstraintPreStepFunc,
           :apply_cached_impulse, :cpConstraintApplyCachedImpulseFunc,
           :apply_impulse, :cpConstraintApplyImpulseFunc,
           :getImpulse, :cpConstraintGetImpulseFunc)
  end

  callback :cpConstraintPreSolveFunc, [:pointer, :pointer], :void
  callback :cpConstraintPostSolveFunc, [:pointer, :pointer], :void

  class ConstraintStruct < NiceFFI::Struct
    layout(:klass, :pointer,
           :a, :pointer,
           :b, :pointer,
           :space, :pointer,
           :next_a, :pointer,
           :next_b, :pointer,
           :max_force, CP_FLOAT,
           :error_bias, CP_FLOAT,
           :max_bias, CP_FLOAT,
           :pre_solve, :cpConstraintPreSolveFunc,
           :post_solve, :cpConstraintPostSolveFunc,
           :data, :pointer)
  end
  
  module Constraint
    attr_reader :body_a, :body_b, :struct
    [:max_force,:error_bias,:max_bias].each do |sym|
      define_method(sym) { struct.constraint[sym] }
      define_method("#{sym}=") {|val| struct.constraint[sym] = val.to_f }
    end
    
    def self.included(other)
      super
      other.class_eval { extend StructAccessor }
    end
    
    def set_data_pointer
      mem = FFI::MemoryPointer.new(:long)
      mem.put_long 0, object_id
      # this is needed to prevent data corruption by GC
      @constraint_pointer = mem
      @struct.constraint.data = mem
    end
    
  end

  require 'chipmunk-ffi/constraints/pin_joint'
  require 'chipmunk-ffi/constraints/slide_joint'
  require 'chipmunk-ffi/constraints/pivot_joint'
  require 'chipmunk-ffi/constraints/groove_joint'
  require 'chipmunk-ffi/constraints/damped_spring'
  require 'chipmunk-ffi/constraints/rotary_limit_joint'
  require 'chipmunk-ffi/constraints/ratchet_joint'
  require 'chipmunk-ffi/constraints/gear_joint'
  require 'chipmunk-ffi/constraints/simple_motor'
  require 'chipmunk-ffi/constraints/damped_rotary_spring'
end
