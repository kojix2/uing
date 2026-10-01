# Installation

Add UIng to your application's `shard.yml`:

    dependencies:
      uing:
        github: kojix2/uing

Install the dependencies:

    shards install

The post-install script downloads the appropriate libui-ng library for the
current platform. Commit your `shard.yml` and `shard.lock`, but do not commit
the downloaded `libui` directory.

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

    require "uing"

    puts UIng::VERSION

Then run it:

    crystal run hello.cr

The command should print the installed UIng version. Continue with
[First Steps](first-steps.md) to open a native window.
