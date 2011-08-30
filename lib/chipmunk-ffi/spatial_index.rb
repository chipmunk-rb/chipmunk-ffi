module CP

  callback :cpSpatialIndexBBFunc, [:pointer], BBStruct.by_value
  callback :cpSpatialIndexIteratorFunc, [:pointer]*2, :void
  callback :cpSpatialIndexQueryFunc, [:pointer]*3, :void
  callback :cpSpatialIndexSegmentQueryFunc, [:pointer]*3, CP_FLOAT

  # maybe copying these structures is of no use, cause SLembcke in his comments says
  # that there's no point in reading spacial index structs' fields,
  # thus, these classes only practical purpose is to prevent corruption by GC
  # that should be achievable in more simple ways
  #TODO discuss corruption prevention methods other than copying structs definitions
  class SpatialIndexStruct < NiceFFI::Struct
    layout :klass, :pointer,
           :bb_func, :cpSpatialIndexBBFunc,
           :static_index, :pointer,
           :dynamic_index, :pointer
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
  func :cpSpaceHashResize, [:pointer, CP_FLOAT, :int], :void

  func :cpBBTreeNew, [:cpSpatialIndexBBFunc, :pointer], :pointer
  func :cpBBTreeOptimize, [:pointer], :void

  #TODO wrap the new API from cpSpatialIndex.h
  callback :cpSpatialIndexDestroyImpl, [:pointer], :void

  callback :cpSpatialIndexCountImpl, [:pointer], :int
  callback :cpSpatialIndexEachImpl, [:pointer, :cpSpatialIndexIteratorFunc, :pointer], :void

  callback :cpSpatialIndexContainsImpl, [:pointer, :pointer, :uint], :int #cpBool
  callback :cpSpatialIndexInsertImpl, [:pointer, :pointer, :uint], :void
  callback :cpSpatialIndexRemoveImpl, [:pointer, :pointer, :uint], :void

  callback :cpSpatialIndexReindexImpl, [:pointer], :void
  callback :cpSpatialIndexReindexObjectImpl, [:pointer, :pointer, :uint], :void
  callback :cpSpatialIndexReindexQueryImpl, [:pointer, :cpSpatialIndexQueryFunc, :pointer], :void

  callback :cpSpatialIndexPointQueryImpl, [:pointer, VECT, :cpSpatialIndexQueryFunc, :pointer], :void
  callback :cpSpatialIndexSegmentQueryImpl, [:pointer, :pointer, VECT, VECT, CP_FLOAT, :cpSpatialIndexSegmentQueryFunc, :pointer], :void
  callback :cpSpatialIndexQueryImpl, [:pointer, :pointer, BBStruct.by_value, :cpSpatialIndexQueryFunc, :pointer], :void

  class SpatialIndexClassStruct < NiceFFI::Struct
    layout :destroy, :cpSpatialIndexDestroyImpl,
           :count, :cpSpatialIndexCountImpl,
           :each, :cpSpatialIndexEachImpl,

           :contains, :cpSpatialIndexContainsImpl,
           :insert, :cpSpatialIndexInsertImpl,
           :remove, :cpSpatialIndexRemoveImpl,

           :reindex, :cpSpatialIndexReindexImpl,
           :reindexObject, :cpSpatialIndexReindexObjectImpl,
           :reindexQuery, :cpSpatialIndexReindexQueryImpl,

           :pointQuery, :cpSpatialIndexPointQueryImpl,
           :segmentQuery, :cpSpatialIndexSegmentQueryImpl,
           :query, :cpSpatialIndexQueryImpl
  end

  func :cpSpatialIndexFree, [:pointer], :void
  func :cpSpatialIndexCollideStatic, [:pointer, :pointer, :cpSpatialIndexQueryFunc, :pointer], :void
  cp_static_inline :cpSpatialIndexDestroy, [:pointer], :void
  cp_static_inline :cpSpatialIndexCount, [:pointer], :int
  cp_static_inline :cpSpatialIndexEach, [:pointer]*3, :void
  cp_static_inline :cpSpatialIndexContains, [:pointer, :pointer, :uint], :int #cpBool
  cp_static_inline :cpSpatialIndexQuery, [:pointer, :pointer, BBStruct.by_value, :pointer, :pointer], :void

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
    
    def query_func
      @query_func ||= Proc.new do |_, other, _|
        s = ShapeStruct.new other
        obj_id = s.data.get_long 0
        @shapes <<  ObjectSpace._id2ref(obj_id)
      end
    end

    def query(bb)
      shapes = []
      CP.cpSpatialIndexQuery @struct.pointer, nil, bb.struct, query_func, nil
      shapes
    end

  end

end


