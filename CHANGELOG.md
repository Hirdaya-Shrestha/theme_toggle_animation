## 1.0.3

* Fix custom mask expanding with stretched aspect ratio (now scales uniformly)
* Cache screenshot, mask content, and clip content in RepaintBoundary to eliminate animation lag
* Stop redundant rebuilds from GIF frames while idle

## 1.0.2

* Shorten pubspec description to stay within pub.dev's recommended length
* README.md updates with proper demo url

## 1.0.1

* Convert classes to standard syntax for pub.dev compatibility
* Minor improvements

## 1.0.0

* Circle animation with 5 directions (corners + fromWidget)
* Line animation with 10 directions (4 cardinal + 4 diagonal + 2 fromWidget)
* Custom GIF mask animation with configurable position and size
* Blur effect on circle and line animation edges
* Custom clip path provider for customMask type
* Configurable animation duration and curve
* onAnimationStart and onAnimationEnd callbacks
* Enabled flag to disable animation
* Animated GIF frame-by-frame support via ImageStream
* Zero dependencies beyond Flutter SDK
