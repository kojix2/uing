# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)

Yet another crystal binding for libui-ng.

## Installation

## Usage

See [examples](examples).

- Notes:
  - UIng.msg_box is not working on Windows (the reason is unknown).

## Development

- https://forum.crystal-lang.org/t/6361
- Rules:
  - `UIng::LibUI` is a module for binding.
  - Use [crystal_lib](https://github.com/crystal-lang/crystal_lib) to create bindings.
  - Method names should be snake_case.
  - [Passing a Proc to a C function](https://crystal-lang.org/api/1.12.1/Proc.html#passing-a-proc-to-a-c-function)

## Contributing

- Fork this repository
- Report bugs
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features

## License

MIT
