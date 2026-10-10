# Installation

[日本語](../guide_ja/installation.html)

## Prerequisites

Crystal and Shards are required. UIng is continuously tested with the latest
Crystal release.

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

<pre><code class="bash">
sudo apt install libgtk-3-dev
</code></pre>

The target Linux system also needs the GTK 3 runtime.

### macOS

The system AppKit framework provides the native GUI dependencies. Both Intel
and Apple Silicon are supported.

### Windows

UIng supports MSVC, MinGW64, and UCRT64. Use the same toolchain as Crystal.
Run MSVC builds from a developer shell such as Developer PowerShell, and use
the matching MSYS2 shell for MinGW64 or UCRT64.

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
