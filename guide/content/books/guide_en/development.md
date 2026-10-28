# Development

[日本語](../guide_ja/development.html)

UIng is intentionally a small, sustainable foundation for native Crystal
applications. Contributions should preserve its stability, cross-platform
behavior, and established lifetime rules.

## API levels

<table>
  <thead>
    <tr><th>Level</th><th>Defined in</th><th>Example</th><th>Purpose</th></tr>
  </thead>
  <tbody>
    <tr><td>High-level</td><td><code>src/uing/*.cr</code></td><td><code>button.on_clicked { }</code></td><td>Object-oriented application API</td></tr>
    <tr><td>Low-level</td><td><code>src/uing/lib_ui/lib_ui.cr</code></td><td><code>UIng::LibUI.new_button</code></td><td>Direct libui-ng bindings</td></tr>
  </tbody>
</table>

The high-level API covers basic controls such as `Window`, `Label`, and
`Button`, as well as advanced controls such as `Table` and `Area`. Application
code should normally use this level. `UIng::LibUI` exists for direct access to
the underlying C API and for implementing high-level wrappers.

## Low-level bindings and native libraries

The low-level bindings were initially generated with
[crystal_lib](https://github.com/crystal-lang/crystal_lib). They are now
maintained directly because generated declarations still required manual
adaptation, such as converting `LibC::Int` values to `Bool` at the high level.
AI assistance is used when maintaining these bindings.

When adding a component, follow the callback and lifetime patterns established
by existing controls. Native libui-ng builds are produced by GitHub Actions in
[kojix2/libui-ng](https://github.com/kojix2/libui-ng); UIng-specific
enhancements are maintained on its `dev` branch. On Windows,
`comctl32.manifest` selects Common Controls v6 so native controls use modern
visual styles.

## Memory safety

- The control registry retains wrappers until native destruction; parent
  references mirror the control tree.
- Area and Table::Model retain their Handlers, which retain closures and captured
  Crystal objects. Captured native resources must remain valid.
- Callbacks recover boxed closures through `data`. Area and Table model callbacks
  recover the Handler through the public `UserData` field (`user_data` in LibUI).
- Borrowed callback values are invalidated when the callback returns.

Direct LibUI callers must retain their handlers and callback context. Native
libraries must match the FFI layout; update the release and checksums in
`download.cr` together. See [Runtime and Lifetime](runtime-and-lifetime.md).

## Use of generative AI

Generative AI assists with GitHub Actions, complex examples, memory-safety
reviews, and development of the patched libui-ng builds. UIng began with
iterative implementation and line-by-line human review of generated code.
Human effort now focuses on overall design, visual inspection of native GUIs,
and improvements found through real-world use.

## Contributing

- Fork the repository and submit a pull request.
- Report reproducible bugs with the platform and Crystal version.
- Add or update cross-platform examples when changing visible behavior.
- Articles and usage reports about UIng are also welcome.
