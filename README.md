<div align="center">

# Theme Toggle Animation

**Smooth, animated theme switching for Flutter.**

Circle reveals, scanning lines, and custom GIF mask animations — zero dependencies, fully customizable.

[![Pub](https://img.shields.io/pub/v/theme_toggle_animation.svg)](https://pub.dev/packages/theme_toggle_animation)
[![CI](https://github.com/Hirdaya-Shrestha/theme_toggle_animation/actions/workflows/ci.yml/badge.svg)](https://github.com/Hirdaya-Shrestha/theme_toggle_animation/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

[**Get Started**](#-installation) · [**Examples**](#-examples) · [**API**](#-api-reference)

</div>

---

## Demo

<table>
  <tr>
    <td align="center" width="33%"><b>Circle</b></td>
    <td align="center" width="33%"><b>Line</b></td>
    <td align="center" width="33%"><b>Custom Mask</b></td>
  </tr>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/Hirdaya-Shrestha/theme_toggle_animation/main/demo_gifs/circle.gif" width="240" alt="Circle animation demo"/></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Hirdaya-Shrestha/theme_toggle_animation/main/demo_gifs/line.gif" width="240" alt="Line animation demo"/></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Hirdaya-Shrestha/theme_toggle_animation/main/demo_gifs/custom.gif" width="240" alt="Custom mask animation demo"/></td>
  </tr>
  <tr>
    <td align="center">Expanding circle reveal from any corner or tap position.</td>
    <td align="center">Scanning line sweep across the screen.</td>
    <td align="center">Animated GIF mask reveal effect.</td>
  </tr>
</table>

> [!NOTE]
> Demo GIFs looks a bit pixalated due to the conversion from mp4 recording. It looks better originally in the UI when using this theme toggle animation. 

---

## ✨ Features

| Feature | Description |
|:--------|:------------|
| 🎯 **3 animation types** | `circle`, `line`, `customMask` |
| 📍 **5 circle directions** | 4 corners + from tap position |
| 📏 **10 line directions** | Cardinal, diagonal, and from tap position |
| 🖼️ **GIF mask animation** | Animated GIFs as reveal masks |
| 🔀 **Custom clip paths** | Bring your own `Path` function |
| 🌫️ **Blur effects** | Configurable blur on animation edges |
| 🎛️ **Configurable** | Duration, curve, enabled flag |
| 🔔 **Lifecycle callbacks** | `onAnimationStart` / `onAnimationEnd` |
| ⚡ **Optimized** | RepaintBoundary, content caching, GPU clips |
| 🧩 **State management agnostic** | Provider, Riverpod, Bloc, GetX — all work |
| 📦 **Zero dependencies** | Only Flutter SDK |

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  theme_toggle_animation: ^1.0.3
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return ThemeToggleAnimation(
      currentTheme: _isDark ? ThemeData.dark() : ThemeData.light(),
      onToggle: () => setState(() => _isDark = !_isDark),
      builder: (context, toggle) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: toggle,
              ),
            ],
          ),
          body: const Center(child: Text('Hello World')),
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
```

---

## 🎬 Examples

### Circle

Expanding circle reveal from any corner or the tap position:

```dart
ThemeToggleAnimation(
  currentTheme: myTheme,
  animationType: ThemeAnimationType.circle,
  circleDirection: CircleAnimationDirection.fromWidget,
  blurAmount: 4.0,
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

| Direction | Description |
|:----------|:------------|
| `ftl` | From top-left |
| `ftr` | From top-right |
| `fbl` | From bottom-left |
| `fbr` | From bottom-right |
| `fromWidget` | From tap position |

---

### Line

Scanning line sweep in 10 directions:

```dart
ThemeToggleAnimation(
  currentTheme: myTheme,
  animationType: ThemeAnimationType.line,
  lineDirection: LineAnimationDirection.ltr,
  blurAmount: 4.0,
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

| Direction | Description |
|:----------|:------------|
| `ltr` | Left → right |
| `rtl` | Right → left |
| `ttb` | Top → bottom |
| `btt` | Bottom → top |
| `fromWidgetHorizontal` | From tap, horizontal |
| `fromWidgetVertical` | From tap, vertical |
| `ftl` | Diagonal top-left |
| `ftr` | Diagonal top-right |
| `fbl` | Diagonal bottom-left |
| `fbr` | Diagonal bottom-right |

---

### Custom Mask

Reveal the new theme through an animated GIF:

```dart
ThemeToggleAnimation(
  currentTheme: myTheme,
  animationType: ThemeAnimationType.customMask,
  customMaskImage: AssetImage('assets/mask.gif'),
  customMaskOffset: Offset(50, 100),
  customMaskSize: Size(150, 150),
  duration: Duration(milliseconds: 2000),
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

> 💡 GIFs with transparent backgrounds work best — opaque pixels reveal the new theme.

---

## 🔌 State Management

Works with any state management solution — just call `onToggle` to flip your state.

<details>
<summary><b>Provider / Riverpod</b></summary>

```dart
ThemeToggleAnimation(
  currentTheme: ref.watch(themeProvider),
  onToggle: () => ref.read(themeProvider.notifier).toggle(),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

</details>

<details>
<summary><b>Bloc</b></summary>

```dart
ThemeToggleAnimation(
  currentTheme: context.read<ThemeBloc>().state.themeData,
  onToggle: () => context.read<ThemeBloc>().add(ToggleTheme()),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

</details>

<details>
<summary><b>GetX</b></summary>

```dart
ThemeToggleAnimation(
  currentTheme: Get.isDarkMode ? darkTheme : lightTheme,
  onToggle: () => Get.isDarkMode
      ? Get.changeTheme(lightTheme)
      : Get.changeTheme(darkTheme),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

</details>

<details>
<summary><b>setState</b></summary>

```dart
ThemeToggleAnimation(
  currentTheme: _isDark ? darkTheme : lightTheme,
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

</details>

---

## 📖 API Reference

### ThemeToggleAnimation

| Parameter | Type | Default | Description |
|:----------|:-----|:--------|:------------|
| `currentTheme` | `ThemeData` | **required** | The current theme to apply |
| `builder` | `Widget Function(BuildContext, VoidCallback)` | **required** | Builder with toggle callback |
| `child` | `Widget` | **required** | Child widget tree |
| `onToggle` | `VoidCallback?` | `null` | Called when toggle is tapped |
| `animationType` | `ThemeAnimationType` | `circle` | Animation effect |
| `duration` | `Duration` | `750ms` | Animation duration |
| `curve` | `Curve` | `easeInOut` | Animation curve |
| `enabled` | `bool` | `true` | Enable / disable animation |
| `onAnimationStart` | `VoidCallback?` | `null` | Fired when animation starts |
| `onAnimationEnd` | `VoidCallback?` | `null` | Fired when animation completes |
| `circleDirection` | `CircleAnimationDirection` | `ftl` | Circle origin |
| `lineDirection` | `LineAnimationDirection` | `ltr` | Line sweep direction |
| `blurAmount` | `double` | `0.0` | Blur intensity *(circle / line only)* |
| `clipper` | `Path Function(Size, Offset, double)?` | `null` | Custom clip path |
| `customMaskImage` | `ImageProvider?` | `null` | GIF / image for mask |
| `customMaskOffset` | `Offset?` | center | Mask position |
| `customMaskSize` | `Size?` | `200 × 200` | Mask size during play phase |

### Enums

**`ThemeAnimationType`** — `circle` · `line` · `customMask`

**`CircleAnimationDirection`** — `ftl` · `ftr` · `fbl` · `fbr` · `fromWidget`

**`LineAnimationDirection`** — `ltr` · `rtl` · `ttb` · `btt` · `fromWidgetHorizontal` · `fromWidgetVertical` · `ftl` · `ftr` · `fbl` · `fbr`

---

## 📋 Requirements

- Flutter `>=3.0.0`
- Dart SDK `^3.0.0`

---

## 📄 License

MIT © Hirdaya Shrestha — see [LICENSE](LICENSE) for details.

---

<div align="center">

**Made with ❤️ by Hirdaya Shrestha**

[Report Bug](https://github.com/Hirdaya-Shrestha/theme_toggle_animation/issues) · [Request Feature](https://github.com/Hirdaya-Shrestha/theme_toggle_animation/issues)

</div>
