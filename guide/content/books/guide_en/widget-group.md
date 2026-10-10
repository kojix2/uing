# Group

[日本語](../guide_ja/widget-group.html)

Group places one child inside a titled native frame.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-ubuntu.png" alt="Group on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-windows.png" alt="Group on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-macos.png" alt="Group on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_group" %}}

## Usage notes

A Group has one direct child. To hold several controls, place them in a Box, Form, or Grid and assign that container to `child`.

![A Group has one Box child containing A and B. Group margins and Box spacing are independent.](../../images/group-child.svg)

```crystal
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Checkbox.new("A"))
box.append(UIng::Checkbox.new("B"))
group = UIng::Group.new("Settings", margined: true)
group.child = box
```

`margined: true` adds space between the frame and its child; the Box's `padded: true` adds gaps between its children.

[API reference](../../api/UIng/Group.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_group.cr)
