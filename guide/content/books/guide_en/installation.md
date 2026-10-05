# Installation

[日本語](../guide_ja/installation.html)

Add UIng to your application's `shard.yml`:

<pre><code class="yaml">
dependencies:
  uing:
    github: kojix2/uing
</code></pre>

Install the dependencies:

<pre><code class="bash">
shards install
</code></pre>

The post-install script downloads the appropriate libui-ng library for the
current platform.

## Platform notes

### Linux

Install the GTK 3 development package before building your application. The
package name depends on the distribution; on Debian and Ubuntu it is
`libgtk-3-dev`.

### macOS

The system AppKit framework provides the native GUI dependencies. Both Intel
and Apple Silicon are supported.

### Windows

UIng supports MSVC, MinGW64, and UCRT64. For an MSVC build, run Crystal from an
x64 Native Tools command prompt or Developer PowerShell so the compiler and
Windows SDK are available.

## Verify the installation

Create `hello.cr`:

<pre><code class="crystal">
require "uing"

UIng.init

window = UIng::Window.new("Hello World", 300, 200)
window.on_closing do
  UIng.quit
  true
end

window.child = UIng::Label.new("Hello from UIng")
window.show

UIng.main
UIng.uninit
</code></pre>

Then run it:

<pre><code class="bash">
crystal run hello.cr
</code></pre>

If a native window titled "Hello World" opens, the installation works.
Continue with [First Steps](first-steps.md) to add a button and handle
events.
