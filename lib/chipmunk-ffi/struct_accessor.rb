module CP
  module StructAccessor
    private
    
    def struct_reader(struct,*args)
      raise(ArgumentError,"First argument must be an FFI::Struct subclass, got #{struct.inspect} instead.") unless struct < FFI::Struct
      args.each {|attribute| add_struct_reader(struct,attribute) }
    end
    
    def struct_writer(struct,*args)
      raise(ArgumentError,"First argument must be an FFI::Struct subclass, got #{struct.inspect} instead.") unless struct < FFI::Struct
      args.each {|attribute| add_struct_writer(struct,attribute) }
    end
      
    def struct_accessor(struct,*args)
      struct_reader(struct,*args)
      struct_writer(struct,*args)
    end
    
    def add_struct_reader(struct,attribute)
      type = resolve_type(struct,attribute)
      if type == CP::Vect
        define_method(attribute) { Vec2.new(self.struct[attribute]) }
      else
        define_method(attribute) { self.struct[attribute] }
      end
    end
      
    def add_struct_writer(struct,attribute)
      type = resolve_type(struct,attribute)
      if type == CP::Vect
        define_method("#{attribute}=") {|val| self.struct[attribute].pointer.put_bytes(0,val.struct.to_bytes,0,Vect.size) }
      else
        define_method("#{attribute}=") {|val| self.struct[attribute] = val }
      end
    end
    
    def resolve_type(struct,attribute)
      t = struct.layout[attribute].type
      if t.is_a?(FFI::StructByValue)
        t.struct_class
      else
        t
      end
    end
    
  end
end