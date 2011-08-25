module CP

  callback :cpSpaceHashBBFunc, [:pointer], BBStruct.by_value
  callback :cpSpatialIndexQueryFunc, [:pointer, :pointer, :pointer], :void

  class SpatialIndexStruct < NiceFFI::Struct
    layout(:klass, :pointer,
           :bb_func, :cpSpaceHashBBFunc,
           :static_index, :pointer,
           :dynamic_index, :pointer)
  end

  class SpaceHashStruct < NiceFFI::Struct
    layout(:spatial_index, CP::SpatialIndexStruct,
           :num_cells, :int,
           :cell_dim, CP_FLOAT,
           :table, :pointer,
           :handle_set, :pointer,
           :pooled_bins, :pointer,
           :pooled_handles, :pointer,
           :allocated_buffers, :pointer,
           :stamp, :uint) #TODO introduce constant for timestamp type
  end
  func :cpSpaceHashNew,  [CP_FLOAT,:int,:cpSpatialIndexQueryFunc,:pointer], :pointer
  #the next 3 fuctions were removed from API
  #func :cpSpaceHashQuery, [:pointer, :pointer, BBStruct.by_value, :cpSpatialIndexQueryFunc, :pointer], :void
  #func :cpSpaceHashInsert, [:pointer, :pointer, :uint, BBStruct.by_value], :void #TODO
  #func :cpSpaceHashRemove, [:pointer, :pointer, :uint], :void #TODO

  #TODO wrap the new API from cpSpatialIndex.h

  class SpaceHash
    attr_reader :struct
    def initialize(*args, &bb_func)
      case args.size
      when 1
        @struct = args.first
      when 2
        raise "need bb func" unless block_given?
        cell_dim = args[0]
        cells = args[1]
        #TODO find use cases of dynamic index construction with a pre-initialized static index
        @struct = SpaceHashStruct.new(CP.cpSpaceHashNew(cell_dim, cells, bb_func, nil))
      end
    end

    def num_cells;@struct.num_cells;end
    def cell_dim;@struct.cell_dim;end
    
    #def insert(obj, bb)
    #  CP.cpSpaceHashInsert(@struct.pointer, obj.struct.pointer, obj.struct.hash_value, bb.struct)
    #end

    #def remove(obj)
    #  CP.cpSpaceHashRemove(@struct.pointer, obj.struct.pointer, obj.struct.hash_value)
    #end

    def query_func
      @query_func ||= Proc.new do |obj,other,data|
        s = ShapeStruct.new(other)
        obj_id = s.data.get_long 0
        @shapes <<  ObjectSpace._id2ref(obj_id)
      end
    end

    #def query_by_bb(bb) #removed from API
    #  @shapes = []
    #  CP.cpSpaceHashQuery(@struct.pointer, nil, bb.struct, query_func, nil)
    #  @shapes
    #end

  end

end


