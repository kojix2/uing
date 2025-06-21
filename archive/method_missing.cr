# Historical archive: MethodMissing module
# This module was used for dynamic method generation but is no longer in use.
# Archived on 2025/6/4 for historical reference.

module UIng
  module MethodMissing
    # Dynamic method generation macro that automatically creates wrapper methods
    # for libui C API functions based on the calling class and method name.
    #
    # This macro handles three types of method calls:
    # 1. Setter methods (ending with '=') - maps to C API functions with 'set_' prefix
    # 2. Methods with blocks - creates methods that accept blocks and forward them
    # 3. Regular methods - creates standard wrapper methods
    #
    # Examples:
    #   button.text = "Hello"     # -> UIng.button_set_text(@ref_ptr, "Hello")
    #   button.show               # -> UIng.button_show(@ref_ptr)
    #   button.on_clicked { ... } # -> UIng.button_on_clicked(@ref_ptr, &block)
    macro method_missing(call)
      {% if call.name.ends_with?("=") %}
      # Handle setter methods (e.g., text=, enabled=)
      # Converts 'property=' to 'set_property' in the C API call
      {% setter_name = call.name.stringify[0..-2] %}
      def {{call.name}}(value)
        UIng.{{ @type.name.split("::").last.underscore.id }}_set_{{setter_name.id}}(@ref_ptr, value)
      end
      {% elsif call.block %}
      # Handle methods that accept blocks (e.g., on_clicked, on_changed)
      # This only works when there are no block parameters
      def {{call.name}}(*args, **kwargs, &block : -> U) forall U
        UIng.{{ @type.name.split("::").last.underscore.id }}_{{call.name.id}}(@ref_ptr, *args, **kwargs, &block)
      end
      {% else %}
      # Handle regular methods (e.g., show, hide, destroy)
      # Maps directly to the corresponding C API function
      def {{call.name}}(*args, **kwargs)
        UIng.{{ @type.name.split("::").last.underscore.id }}_{{call.name.id}}(@ref_ptr, *args, **kwargs)
      end
      {% end %}
    end
  end
end
