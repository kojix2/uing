# **UIng**

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)

**UIng** is yet another Crystal binding for **[libui-ng](https://github.com/libui-ng/libui-ng)** or **[libui-dev](https://github.com/petabyt/libui-dev)**.

---

## **📌 Installation**

Crystal prefers **static linking** for libui rather than using it as a shared library.

The libui project **does not distribute pre-compiled binaries**.  
Therefore, this project uses the following sources to obtain binaries:

| OS                | Binary Source                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **MacOS / Linux** | Builds from the [kojix2/libui-ng](https://github.com/kojix2/libui-ng) repository (pre-build branch) |
| **Windows**       | Pre-built binaries distributed with [libui-dev](https://github.com/petabyt/libui-dev/releases)      |

### **🔽 Downloading Binaries**

```sh
crystal run download.cr
```

---

## **📌 Usage**

For more details, see [examples](examples).

### **⚠️ Important Notes**

- **Windows Compatibility Issues**
  - `libui-ng`'s `msg_box` implementation relies on `TaskDialog`.
  - `TaskDialog` requires **ComCtl32.dll version 6**.
  - **The standard ComCtl32 is version 5**, so a **manifest file is required**.

---

## **📌 Closures and Their Limitations**

In Crystal, **a C function pointer corresponds to a Proc**.  
However, whether it can be used as a closure depends on the following conditions:

| **Condition**                            | **Closure Support**                                    |
| ---------------------------------------- | ------------------------------------------------------ |
| **Data can be passed as an argument**    | ✅ Supported                                           |
| **Data cannot be passed as an argument** | ❌ Not Supported (Works only if Proc is not a closure) |

---

## **📌 Development (Binding Structure)**

UIng is structured into three binding levels:

| **Level**        | **Description**                                                                      |
| ---------------- | ------------------------------------------------------------------------------------ |
| **Low-Level**    | Defined in `src/uing/lib_ui/lib_ui.cr`. <br> Example: `UIng::LibUI.new_window`, etc. |
| **Middle-Level** | Defined in `src/uing.cr`. <br> Example: `UIng.new_window`, etc.                      |
| **High-Level**   | Expected in `src/uing/*.cr`. <br> Example: `window.on_closing { }`, etc.             |

- At the middle level, memory management tasks such as string deallocation are handled.
- The high-level API implementation is limited; the `Control` module provides a `method_missing` macro to handle undefined methods.

### **🔹 Additional Rules**

- `UIng::LibUI` is a **module dedicated to bindings**.
- **Use** [crystal_lib](https://github.com/crystal-lang/crystal_lib) **to generate low-level bindings** (manual modifications required).
- **Passing a Proc to a C function**: [Official Documentation](https://crystal-lang.org/api/1.12.1/Proc.html#passing-a-proc-to-a-c-function).

---

## **📌 Windows Compatibility**

Windows support is **particularly challenging** due to the following reasons:

### **🔹 Differences Between MSVC and MinGW**

| **Aspect**                 | **MSVC Version**        | **MinGW Version**       |
| -------------------------- | ----------------------- | ----------------------- |
| **libui Suitability**      | **libui-ng**            | **libui-dev**           |
| **Manifest File Handling** | Uses a different format | Uses a different format |

### **🔹 ComCtl32 Version Issues**

- **ComCtl32 version 6 or later is required**.
- **TaskDialog is dependent on it** (removing TaskDialog breaks functionality).
- **Using an older ComCtl32 version results in outdated UI appearance**.

### **🔹 Debugging**

- **MinGW version of gdb** can be used for debugging.

---

## **📌 Contributing**

You can contribute to this project by:

✅ **Forking this repository**  
✅ **Reporting bugs**  
✅ **Fixing bugs and submitting pull requests**  
✅ **Improving documentation**  
✅ **Suggesting or adding new features**

---

## **📌 License**

This project is licensed under the **MIT License**.
