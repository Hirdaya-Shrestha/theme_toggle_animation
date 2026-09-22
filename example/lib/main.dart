import 'package:flutter/material.dart';
import 'package:theme_toggle_animation/theme_toggle_animation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Toggle Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.light,
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _isDark = false;
  bool _enabled = true;
  ThemeAnimationType _animationType = ThemeAnimationType.circle;
  CircleAnimationDirection _circleDir = CircleAnimationDirection.ftl;
  LineAnimationDirection _lineDir = LineAnimationDirection.ltr;
  double _blurAmount = 0;

  ThemeData get _currentTheme => _isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  @override
  Widget build(BuildContext context) {
    return ThemeToggleAnimation(
      currentTheme: _currentTheme,
      animationType: _animationType,
      circleDirection: _circleDir,
      lineDirection: _lineDir,
      blurAmount: _blurAmount,
      enabled: _enabled,
      customMaskImage: AssetImage("assets/custommask.gif"),
      duration: const Duration(milliseconds: 1600),
      onToggle: () => setState(() => _isDark = !_isDark),
      onAnimationStart: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animation started'), duration: Duration(milliseconds: 500)),
        );
      },
      onAnimationEnd: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animation complete'), duration: Duration(milliseconds: 500)),
        );
      },
      builder: (context, toggle) => _buildContent(context, toggle),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildContent(BuildContext context, VoidCallback toggle) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Toggle Animation'),
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnimationTypeSelector(context),
          const SizedBox(height: 16),
          if (_animationType == ThemeAnimationType.circle)
            _buildCircleDirectionSelector(context),
          if (_animationType == ThemeAnimationType.line)
            _buildLineDirectionSelector(context),
          if (_animationType != ThemeAnimationType.customMask) ...[
            const SizedBox(height: 16),
            _buildBlurSelector(context),
          ],
          const SizedBox(height: 16),
          _buildEnabledToggle(context),
          const SizedBox(height: 32),
          _buildPreviewCard(context),
          const SizedBox(height: 32),
          _buildToggleSection(context, toggle),
        ],
      ),
    );
  }

  Widget _buildAnimationTypeSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animation Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ThemeAnimationType.values.map((type) {
                final isSelected = _animationType == type;
                return ChoiceChip(
                  label: Text(type.name),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _animationType = type),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleDirectionSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Circle Direction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CircleAnimationDirection.values.map((dir) {
                final isSelected = _circleDir == dir;
                return ChoiceChip(
                  label: Text(dir.name),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _circleDir = dir),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineDirectionSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Line Direction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LineAnimationDirection.values.map((dir) {
                final isSelected = _lineDir == dir;
                return ChoiceChip(
                  label: Text(dir.name),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _lineDir = dir),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blur: ${_blurAmount.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _blurAmount,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (v) => setState(() => _blurAmount = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnabledToggle(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text('Animation enabled',
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: const Text('Disable to skip animation on toggle'),
        value: _enabled,
        onChanged: (v) => setState(() => _enabled = v),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              _isDark ? Icons.nightlight_round : Icons.wb_sunny,
              size: 64,
              color: _isDark ? Colors.amber : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _isDark ? 'Dark Mode' : 'Light Mode',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${_animationType.name} | blur: ${_blurAmount.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSection(BuildContext context, VoidCallback toggle) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: toggle,
        icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
        label: Text('Switch to ${_isDark ? 'Light' : 'Dark'}'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
