# theme_toggle_animation

Smooth, animated theme switching for Flutter with multiple animation effects. Zero dependencies beyond Flutter SDK.

Inspired by [react-theme-switch-animation](https://www.npmjs.com/package/react-theme-switch-animation).

## Features

- **3 animation types**: circle, line, custom GIF mask
- **5 circle directions**: corners + from tap position
- **10 line directions**: cardinal, diagonal, from tap position
- **GIF mask animation**: animated GIFs as reveal masks with configurable position and size
- **Blur effects**: configurable blur on circle and line animation edges
- **Custom clip paths**: provide your own clip path function
- **Lifecycle callbacks**: onAnimationStart, onAnimationEnd
- **Performance optimized**: RepaintBoundary, content caching, GPU-accelerated clips
- **State management agnostic**: works with setState, Provider, Riverpod, Bloc, etc.
- **Zero dependencies**: only Flutter SDK

## Installation

```yaml
dependencies:
  theme_toggle_animation: ^1.0.0
```

```bash
flutter pub get
```

## Quick Start

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

## Animation Types

### Circle (Default)

Expanding circle reveal from any corner or the tap position:

```dart
ThemeToggleAnimation(
  currentTheme: myTheme,
  animationType: ThemeAnimationType.circle,
  circleDirection: CircleAnimationDirection.fromWidget,
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

### Line

Scanning line sweep in 10 directions:

```dart
ThemeToggleAnimation(
  currentTheme: myTheme,
  animationType: ThemeAnimationType.line,
  lineDirection: LineAnimationDirection.ltr,
  blurAmount: 4.0, // optional blur on the scan edge
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

### Custom GIF Mask

Reveal the new theme through an animated GIF mask:

```dart
ThemeToggleAnimation(
  currentTheme: myTheme,
  animationType: ThemeAnimationType.customMask,
  customMaskImage: AssetImage('assets/mask.gif'),
  customMaskOffset: Offset(50, 100), // top-left position
  customMaskSize: Size(150, 150),    // size during play phase
  duration: Duration(milliseconds: 2000), // GIF needs more time
  onToggle: () => setState(() => _isDark = !_isDark),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

GIFs with transparent backgrounds work best. The opaque pixels reveal the new theme.

## State Management

Works with any state management solution. Just call `onToggle` to flip your state:

### Provider / Riverpod

```dart
ThemeToggleAnimation(
  currentTheme: ref.watch(themeProvider),
  onToggle: () => ref.read(themeProvider.notifier).toggle(),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

### Bloc

```dart
ThemeToggleAnimation(
  currentTheme: context.read<ThemeBloc>().state.themeData,
  onToggle: () => context.read<ThemeBloc>().add(ToggleTheme()),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

### GetX

```dart
ThemeToggleAnimation(
  currentTheme: Get.isDarkMode ? darkTheme : lightTheme,
  onToggle: () => Get.isDarkMode ? Get.changeTheme(lightTheme) : Get.changeTheme(darkTheme),
  builder: (context, toggle) => MyToggleWidget(onTap: toggle),
  child: MyApp(),
)
```

## API Reference

### ThemeToggleAnimation

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `currentTheme` | `ThemeData` | **required** | The current theme to apply |
| `builder` | `Widget Function(BuildContext, VoidCallback)` | **required** | Builder with toggle callback |
| `child` | `Widget` | **required** | Child widget tree |
| `onToggle` | `VoidCallback?` | `null` | Called when toggle is tapped |
| `animationType` | `ThemeAnimationType` | `circle` | Animation effect |
| `duration` | `Duration` | `750ms` | Animation duration |
| `curve` | `Curve` | `easeInOut` | Animation curve |
| `enabled` | `bool` | `true` | Enable/disable animation |
| `onAnimationStart` | `VoidCallback?` | `null` | Called when animation starts |
| `onAnimationEnd` | `VoidCallback?` | `null` | Called when animation completes |
| `circleDirection` | `CircleAnimationDirection` | `ftl` | Circle origin |
| `lineDirection` | `LineAnimationDirection` | `ltr` | Line sweep direction |
| `blurAmount` | `double` | `0.0` | Blur intensity (circle/line only) |
| `clipper` | `Path Function(Size, Offset, double)?` | `null` | Custom clip path |
| `customMaskImage` | `ImageProvider?` | `null` | GIF/image for mask |
| `customMaskOffset` | `Offset?` | center | Mask position |
| `customMaskSize` | `Size?` | `200x200` | Mask size during play |

### ThemeAnimationType

| Type | Description |
|------|-------------|
| `circle` | Expanding circle reveal |
| `line` | Scanning line sweep |
| `customMask` | GIF mask or custom clip path |

### CircleAnimationDirection

| Direction | Description |
|-----------|-------------|
| `ftl` | From top-left |
| `ftr` | From top-right |
| `fbl` | From bottom-left |
| `fbr` | From bottom-right |
| `fromWidget` | From tap position |

### LineAnimationDirection

| Direction | Description |
|-----------|-------------|
| `ltr` | Left to right |
| `rtl` | Right to left |
| `ttb` | Top to bottom |
| `btt` | Bottom to top |
| `fromWidgetHorizontal` | From tap, horizontal |
| `fromWidgetVertical` | From tap, vertical |
| `ftl` | Diagonal top-left |
| `ftr` | Diagonal top-right |
| `fbl` | Diagonal bottom-left |
| `fbr` | Diagonal bottom-right |

## Requirements

- Flutter >=3.0.0
- Dart SDK ^3.13.2

## License

MIT - Copyright 2026 Hirdaya Shrestha
