# 🚚 Repository Moved

> **⚠️ This repository has been migrated to the Komodo DeFi SDK Flutter monorepo.**
>
> 📍 **New location:** [packages/dragon_charts_flutter](https://github.com/KomodoPlatform/komodo-defi-sdk-flutter/tree/main/packages/dragon_charts_flutter)
>
> 🔄 **Active development** continues in the monorepo. Please update your forks, bookmarks, and links.
>
> 💡 **For issues, PRs, and contributions**, please use the [main monorepo](https://github.com/KomodoPlatform/komodo-defi-sdk-flutter).

---

# Dragon Charts Flutter (Archived)

Dragon Charts Flutter is a lightweight, declarative, and highly customizable charting library for Flutter. It provides a simple yet powerful way to create various types of charts, with a focus on ease of use and flexibility.

## Features

- **Lightweight:** Minimal dependencies and optimized for performance.
- **Declarative:** Define charts using a declarative API that makes customization straightforward.
- **Customizable:** Highly customizable with support for different line types, colors, and more.
- **Expandable:** Designed with a modular architecture to easily add new chart types.

## Installation

Pub is the recommended way to install this package, but you can also install it from GitHub.

### From Pub

Run this command:

```bash
flutter pub add dragon_charts_flutter
```

### From GitHub

```yaml
dependencies:
  dragon_charts_flutter:
    git:
      url: https://github.com/your_username/dragon_charts_flutter.git
      ref: main # or a specific tag/branch/commit
```

Then, run `flutter pub get` to install the package.

## Usage

Here is a simple example to get you started:

```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ChartBloc(),
        child: const ChartScreen(),
      ),
    );
  }
}

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Line Chart with Animation')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: BlocBuilder<ChartBloc, ChartState>(
          builder: (context, state) {
            return CustomLineChart(
              domainExtent: const ChartExtent.tight(),
              elements: [
                ChartGridLines(isVertical: false, count: 5),
                ChartAxisLabels(
                    isVertical: true,
                    count: 5,
                    labelBuilder: (value) => value.toStringAsFixed(2)),
                ChartAxisLabels(
                    isVertical: false,
                    count: 5,
                    labelBuilder: (value) => value.toStringAsFixed(2)),
                ChartDataSeries(data: state.data1, color: Colors.blue),
                ChartDataSeries(
                    data: state.data2,
                    color: Colors.red,
                    lineType: LineType.bezier),
              ],
              tooltipBuilder: (context, dataPoints) {
                return ChartTooltip(
                    dataPoints: dataPoints, backgroundColor: Colors.black);
              },
            );
          },
        ),
      ),
    );
  }
}
```

## Documentation

### ChartData

Represents a data point in the chart.

#### Properties

- `x`: `double` - The x-coordinate of the data point.
- `y`: `double` - The y-coordinate of the data point.

### ChartDataSeries

Represents a series of data points to be plotted on the chart.

#### Properties

- `data`: `List<ChartData>` - The list of data points.
- `color`: `Color` - The color of the series.
- `lineType`: `LineType` - The type of line (straight or bezier).

### CustomLineChart

The main widget for displaying a line chart.

#### Properties

- `elements`: `List<ChartElement>` - The elements to be drawn on the chart.
- `tooltipBuilder`: `Widget Function(BuildContext, List<ChartData>)` - The builder for custom tooltips.
- `domainExtent`: `ChartExtent` - The extent of the domain (x-axis).
- `rangeExtent`: `ChartExtent` - The extent of the range (y-axis).
- `backgroundColor`: `Color` - The background color of the chart.

## Roadmap

### ✅ v0.1.0 (Done)

 - ✅ Initial release with support for line charts.

### v0.2.0

- Add pie charts support.
- Improve documentation and add more examples.

### v0.3.0

- Add bar charts support.
- Implement interactive legends.

### v0.4.0

- Add scatter plots support.
- Enhance performance for large datasets.

### v1.0.0

- Full documentation and stable release.
- Add support for exporting charts as images.

## Why Dragon Charts Flutter?

Dragon Charts Flutter is an excellent solution for your charting needs because:

- **Lightweight:** It has minimal dependencies and is optimized for performance, making it suitable for both small and large projects.
- **Declarative:** The declarative API makes it easy to define and customize charts, reducing the complexity of your code.
- **Customizable:** The library is highly customizable, allowing you to create unique and visually appealing charts tailored to your application's needs.
- **Expandable:** The modular architecture enables easy addition of new chart types and features, ensuring the library can grow with your requirements.

## Contributing

Contributions are welcome! Please read the [contributing guidelines](CONTRIBUTING.md) first.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.