require 'rubygems'
require 'nice-ffi'

module CP
  extend NiceFFI::Library

  if RUBY_PLATFORM == "java"
    require 'jruby'
    JRuby.objectspace=true
  end
    
  unless defined? CP::LOAD_PATHS
    # Check if the application has defined CP_PATHS with some
    # paths to check first for chipmunk library.
    CP::LOAD_PATHS = if defined? ::CP_PATHS
                       NiceFFI::PathSet::DEFAULT.prepend( ::CP_PATHS )
                     else
                       NiceFFI::PathSet::DEFAULT
                     end

  end

  defined?(::CP_EXACT_PATH) ?
          load_library(::CP_EXACT_PATH) :
          load_library("chipmunk", CP::LOAD_PATHS)

  def self.cp_static_inline(func_sym, args, ret)
    func_name = "_#{func_sym}"
    attach_variable func_name, :pointer
    const_func_name = func_sym.to_s.upcase

    func = FFI::Function.new(ret, args, FFI::Pointer.new(self.send(func_name).to_i), :convention => :default )
    const_set const_func_name, func

    instance_eval <<-METHOD
    def #{func_sym}(*args)
      const_get('#{const_func_name}').call *args
    end
    METHOD
  end

  CP_FLOAT = :double
  CP_GROUP_TYPE = :uint #:pointer #uintptr_t
  CP_LAYERS_TYPE = :uint
  CP_COLLISION_TYPE_TYPE = :uint #:pointer
  CP_ALL_LAYERS = 0

end
libs = %w{vec2 core bb body shape arbiter space constraint spatial_index}
$: << File.dirname(__FILE__)
libs.each do |lib|
  require "chipmunk-ffi/#{lib}"
end
