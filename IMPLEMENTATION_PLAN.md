# Implementation Plan: Consistent Resource Ownership and Reference Counting for libui-ng Bindings (FINAL)

## Overview

This plan describes the **completed implementation** of a unified and robust resource management strategy for Crystal bindings to libui-ng, focusing on TableModel, TableModelHandler, Image, and TableValue. The implementation ensures memory safety, prevents double-free and dangling pointer bugs, and makes ownership/borrowing semantics explicit and consistent across all resource types.

**STATUS: COMPLETED** - This plan has been fully implemented and tested, incorporating feedback from libui-ng developers who confirmed that reference counting is the recommended approach for shared resources.

## Key Principles (Implemented)

- **Explicit Ownership:** Every resource wrapper clearly indicates whether it owns the underlying C resource or is merely borrowing it via `owned/borrowed` flags.
- **Reference Counting:** All shared resources (TableModel, TableModelHandler, Image) use reference counting. Resources are freed only when the reference count drops to zero.
- **No Reliance on GC/Finalize:** No dependency on Crystal's GC or finalizers for freeing C resources. All C resources are released explicitly via reference counting.
- **Borrowed Resources:** Wrappers for resources they do not own are marked as borrowed and do not free the resource.
- **Thread Safety:** All resource management operations are performed on the main thread only, as libui-ng is not thread-safe.
- **Consistency Over Compatibility:** The design prioritizes consistency and safety over backward compatibility.

## Completed Implementation

### 1. RefCounted Module (src/uing/ref_counted.cr)
```crystal
module RefCounted
  @ref_count : Int32 = 1
  @owned : Bool = true
  @borrowed : Bool = false

  def set_ownership(owned : Bool, borrowed : Bool)
    @owned = owned
    @borrowed = borrowed
    @ref_count = borrowed ? 0 : 1
  end

  def acquire
    return if @borrowed
    @ref_count += 1
  end

  def release
    return if @borrowed
    @ref_count -= 1
    if @ref_count <= 0 && @owned
      free_resource
    end
  end

  abstract def free_resource
end
```

### 2. TableModelHandler (src/uing/table/table_model_handler.cr)
- ✅ Implements RefCounted module
- ✅ Manages callback lifecycle with reference counting
- ✅ Supports both owned and borrowed instances
- ✅ Automatic cleanup when reference count reaches zero

### 3. TableModel (src/uing/table/table_model.cr)
- ✅ Implements RefCounted module
- ✅ Manages TableModelHandler reference with acquire/release
- ✅ Supports multiple Tables sharing the same model
- ✅ Automatic cleanup of both model and handler references

### 4. Image (src/uing/image.cr)
- ✅ Implements RefCounted module
- ✅ Can be shared across multiple table cells
- ✅ Creator responsibility pattern for release
- ✅ No finalize method (explicit management only)

### 5. TableValue (src/uing/table/table_value.cr)
- ✅ Implements RefCounted module for consistency
- ✅ **Critical Design Decision**: Does NOT acquire/release Image references
- ✅ Short-lived objects that only hold Image references
- ✅ Image lifecycle managed by creator (Employee objects, DEFAULT_AVATAR)

### 6. Table (src/uing/table.cr)
- ✅ Manages TableModel reference with acquire/release
- ✅ Automatic selection management with block syntax
- ✅ Proper cleanup order in destroy method
- ✅ Block-based selection method for automatic resource management

## Critical Design Decisions Made

### 1. TableValue and Image Relationship
**Problem**: TableValue objects are short-lived (created in callbacks, immediately returned to libui-ng), but Images need long-term management.

**Solution**: TableValue stores Image reference but does NOT call acquire/release. Image lifecycle is managed by the actual owner (Employee objects, DEFAULT_AVATAR constant).

```crystal
# TableValue constructor - reference only, no acquire
def initialize(image : Image)
  @ref_ptr = LibUI.new_table_value_image(image.to_unsafe)
  set_ownership(owned: true, borrowed: false)
  @image_ref = image  # Reference only, no acquire
end

# TableValue free_resource - no release
protected def free_resource : Nil
  @image_ref = nil  # Clear reference, don't release
  LibUI.free_table_value(@ref_ptr)
end
```

### 2. Creator Responsibility Pattern
**Principle**: The entity that creates an Image is responsible for calling release.

```crystal
# Creator creates and owns
DEFAULT_AVATAR = create_avatar_image(0.5, 0.5, 0.5)  # ref_count = 1

# Usage doesn't affect reference count
TableValue.new(DEFAULT_AVATAR)  # No acquire

# Creator releases
DEFAULT_AVATAR.release  # ref_count = 0, automatically freed
```

### 3. Automatic Selection Management
**Enhancement**: Added block-based selection method to eliminate manual free calls.

```crystal
# Old pattern (manual management)
selection = table.selection
# ... use selection ...
selection.free  # Easy to forget

# New pattern (automatic management)
table.selection do |selection|
  # ... use selection ...
  # Automatically freed when block ends
end
```

## Validation Results

### 1. Memory Safety
- ✅ No segmentation faults in advanced_table.cr
- ✅ Proper cleanup order prevents "cannot destroy while parent exists" errors
- ✅ Reference counting prevents premature resource deallocation

### 2. libui-ng Compliance
- ✅ Works alongside libui-ng's internal safety mechanisms
- ✅ Supports 1-to-many sharing patterns (TableModel → Tables, Image → TableValues)
- ✅ Main-thread-only constraint respected
- ✅ No memory leaks detected by libui-ng's built-in leak detection

### 3. API Consistency
- ✅ All shared resources use acquire/release pattern
- ✅ Unified owned/borrowed semantics
- ✅ Consistent constructor patterns across all classes
- ✅ No deprecated methods remaining

## Implementation Files Modified

1. **src/uing/ref_counted.cr** - Base reference counting module
2. **src/uing/table/table_model_handler.cr** - Reference counted handler
3. **src/uing/table/table_model.cr** - Reference counted model with handler management
4. **src/uing/image.cr** - Reference counted image
5. **src/uing/table/table_value.cr** - Reference counted but no Image acquire/release
6. **src/uing/table.cr** - TableModel management and block-based selection
7. **examples/advanced_table.cr** - Updated to use new reference counting patterns

## Key Lessons Learned

### 1. Short-lived vs Long-lived Objects
TableValue objects are fundamentally different from TableModel/Image objects:
- **TableValue**: Short-lived, created in callbacks, immediately consumed by libui-ng
- **TableModel/Image**: Long-lived, shared across multiple consumers

**Solution**: Different reference management strategies for different object lifecycles.

### 2. Creator Responsibility
The most reliable pattern is "creator releases" rather than complex shared ownership:
- Clear responsibility assignment
- Predictable cleanup timing
- Easier to debug and maintain

### 3. libui-ng Integration
Reference counting works best when it complements, not replaces, libui-ng's built-in safety mechanisms:
- libui-ng prevents invalid operations (e.g., freeing in-use TableModel)
- Reference counting prevents premature deallocation
- Together they provide comprehensive safety

## Future Maintenance

### 1. Adding New Resource Types
Follow the established pattern:
1. Include RefCounted module
2. Implement free_resource method
3. Add owned/borrowed constructor parameters
4. Manage dependent resource references with acquire/release

### 2. Thread Safety
All reference counting operations must remain on the main thread. If background thread support is needed:
1. Queue operations to main thread
2. Never call acquire/release from background threads
3. Document thread safety requirements clearly

### 3. Testing
Continue to use libui-ng's built-in leak detection as the primary validation tool:
- Run programs to completion
- Check for leak reports in console
- Investigate any reported leaks immediately

---

## Conclusion

The reference counting implementation successfully addresses the original segmentation fault issues in advanced_table.cr while providing a robust, consistent, and maintainable resource management system. The key insight was recognizing that different object lifecycles require different management strategies, leading to the creator responsibility pattern for Images and automatic management for short-lived objects like TableValue.

This implementation serves as a solid foundation for safe libui-ng bindings in Crystal, with clear patterns that can be extended to other resource types as needed.
