# Runtime and Lifetime

A UIng application creates its controls between `UIng.init` and `UIng.main`.
The main loop then waits for native events and invokes the callbacks registered
by the application.

## Application lifecycle

- `UIng.init` initializes libui-ng.
- `window.show` makes a completed window visible.
- `UIng.main` runs the native event loop.
- `UIng.quit` asks that loop to stop.
- `UIng.uninit` releases application-wide resources after the loop ends.

Prefer the block form of `UIng.init` because it guarantees the matching
`UIng.uninit` call:

    UIng.init do
      # Build and show the interface here.
      UIng.main
    end

`UIng.quit` stops the loop; it does not destroy every open window. A normal
window-closing callback returns `true`, allowing libui-ng to destroy that
window as it closes.

## Control ownership

Containers own their child controls. Destroying a parent also destroys its
children, so do not destroy a control while it is still attached.

Detach a child before reusing or explicitly destroying it. For example, set a
window's child to `nil`, call `delete` on a `Box`, `Form`, or `Grid`, or use
`control.detach`.

Tables, custom drawing resources, menus, and multi-window shutdown have extra
lifetime rules. Consult their examples and the
[API Reference](../../api/) when using them.
