module UIng
  # RefCounted provides reference counting functionality for libui-ng resources
  # that can be shared across multiple objects.
  #
  # CRITICAL THREAD SAFETY WARNING:
  # All reference counting operations (acquire/release) MUST be performed on the
  # main thread only, as libui-ng is not thread-safe.
  #
  # Usage pattern:
  #   resource = SomeRefCountedResource.new(...)  # ref_count = 1
  #   other_object.use(resource)                  # calls resource.acquire (ref_count = 2)
  #   # ... later ...
  #   other_object.cleanup                        # calls resource.release (ref_count = 1)
  #   resource.release                            # ref_count = 0, resource freed
  module RefCounted
    # Reference count for this resource
    @ref_count : Int32 = 1

    # Whether this wrapper owns the underlying C resource
    @owned : Bool = true

    # Whether this wrapper is borrowing the resource (doesn't own it)
    @borrowed : Bool = false

    # Increment the reference count for this resource.
    # Should be called when a new object starts using this resource.
    #
    # NOTE: Borrowed resources do not participate in reference counting.
    def acquire : Nil
      return if @borrowed

      # TODO: Add main thread assertion here when available
      # raise "RefCounted operations must be on main thread" unless on_main_thread?

      @ref_count += 1
    end

    # Decrement the reference count for this resource.
    # When the count reaches zero and the resource is owned, it will be freed.
    #
    # NOTE: Borrowed resources do not participate in reference counting.
    def release : Nil
      return if @borrowed

      # TODO: Add main thread assertion here when available
      # raise "RefCounted operations must be on main thread" unless on_main_thread?

      @ref_count -= 1
      if @ref_count <= 0 && @owned
        free_resource
        @ref_count = 0 # Ensure it doesn't go negative
      end
    end

    # Returns the current reference count.
    # Primarily for debugging and testing purposes.
    def ref_count : Int32
      @ref_count
    end

    # Returns true if this wrapper owns the underlying resource.
    def owned? : Bool
      @owned
    end

    # Returns true if this wrapper is borrowing the resource.
    def borrowed? : Bool
      @borrowed
    end

    # Abstract method that must be implemented by including classes.
    # This method should free the underlying C resource.
    abstract def free_resource : Nil

    # Set the ownership and borrowing flags.
    # This should only be called during initialization.
    protected def set_ownership(owned : Bool, borrowed : Bool) : Nil
      @owned = owned
      @borrowed = borrowed
      @ref_count = borrowed ? 0 : 1
    end
  end
end
