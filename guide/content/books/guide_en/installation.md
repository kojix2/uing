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

The post-install script downloads the appropriate libui-ng library from
[kojix2/libui-ng releases](https://github.com/kojix2/libui-ng/releases). UIng
uses patched libui-ng builds maintained for the supported platforms; details
of those patches are available on the libui-ng
[`dev` branch](https://github.com/kojix2/libui-ng/commits/dev).

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

The post-install script downloads both `/MD` and `/MT` MSVC libraries. Normal
Crystal builds use `/MD`; builds made with `--static` use `/MT`.

### Hide the console window

GUI executables built on Windows may open a console window. Select the Windows
GUI subsystem when building the final executable.

MinGW64 or UCRT64:

<pre><code class="bash">
crystal build app.cr --link-flags "-mwindows"
</code></pre>

MSVC:

<pre><code class="powershell">
crystal build app.cr --link-flags=/SUBSYSTEM:WINDOWS
</code></pre>

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
