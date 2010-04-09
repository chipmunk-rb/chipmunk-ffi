require 'chipmunk-ffi/struct_accessor'

module CP
  callback :cpConstraintPreStepFunction, [:pointer, CP_FLOAT, CP_FLOAT], :void
  callback :cpConstraintApplyImpulseFunction, [:pointer], :void
  callback :cpConstraintGetImpulseFunction, [:pointer], CP_FLOAT

  class ConstraintClassStruct < NiceFFI::Struct
    layout(:pre_step, :cpConstraintPreStepFunction,
      :apply_impluse, :cpConstraintApplyImpulseFunction,
      :getImpulse, :cpConstraintGetImpulseFunction)
  end

  class ConstraintStruct < NiceFFI::Struct
    layout(:klass, :pointer,
           :a, :pointer,
           :b, :pointer,
           :max_force, CP_FLOAT,
           :bias_coef, CP_FLOAT,
           :max_bias, CP_FLOAT,
           :data, :pointer)
  end
  
  module Constraint
    attr_reader :body_a, :body_b, :struct
    [:max_force,:bias_coef,:max_bias].each do |sym|
      define_method(sym) { struct.constraint[sym] }
      define_method("#{sym}=") {|val| struct.constraint[sym] = val.to_f }
    end
    
    def self.included(other)
      super
      other.class_eval { extend StructAccessor }
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
end
