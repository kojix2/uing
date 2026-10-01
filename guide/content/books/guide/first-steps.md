# First Steps

This application opens a native window containing a button. Clicking the
button displays a message box.

    require "uing"

    UIng.init do
      window = UIng::Window.new("Hello World", 300, 200)
      window.on_closing do
        UIng.quit
        true
      end

      button = UIng::Button.new("Click me")
      button.on_clicked do
        window.msg_box("UIng", "Hello from Crystal!")
      end

      window.child = button
      window.show
      UIng.main
    end

Save the source as `hello.cr`, then run it:

    crystal run hello.cr

## How it works

1. `UIng.init` initializes the native GUI backend.
2. `Window.new` and `Button.new` create native controls.
3. `on_clicked` registers code to run after a click.
4. Assigning `window.child` places the button in the window.
5. `window.show` displays the interface.
6. `UIng.main` runs the event loop until the closing callback calls
   `UIng.quit`.

Returning `true` from `on_closing` allows the window to close. The block form
of `UIng.init` calls `UIng.uninit` automatically after the event loop returns.
