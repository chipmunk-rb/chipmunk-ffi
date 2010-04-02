module CP
  module StructAccessor
    private
    
    def struct_reader(*args)
      args.each {|attribute| add_struct_reader(attribute) }
    end
    
    def struct_writer(*args)
      args.each {|attribute| add_struct_writer(attribute) }
    end
      
    def struct_accessor(*args)
      struct_reader(*args)
      struct_writer(*args)
    end
    
    def add_struct_reader(attribute)
      define_method(attribute) { self.struct[attribute] }
    end
      
    def add_struct_writer(attribute)
      define_method("#{attribute}=") {|val| self.struct[attribute] = val }
    end
  end
end