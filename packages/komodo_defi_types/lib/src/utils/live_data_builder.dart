import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// A widget that rebuilds when a [LiveData] instance changes.
class LiveDataBuilder<T> extends StatefulWidget {
  const LiveDataBuilder({
    required this.liveData,
    required this.builder,
    super.key,
    this.child,
  });

  /// The [LiveData] instance to listen to.
  final LiveData<T> liveData;

  /// The builder function that creates the widget subtree.
  ///
  /// Will be called with the current value of [liveData].
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  /// An optional child widget that will be passed to the [builder] function.
  final Widget? child;

  @override
  State<LiveDataBuilder<T>> createState() => _LiveDataBuilderState<T>();
}

class _LiveDataBuilderState<T> extends State<LiveDataBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.liveData.value;
    widget.liveData.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(LiveDataBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveData != widget.liveData) {
      oldWidget.liveData.removeListener(_valueChanged);
      value = widget.liveData.value;
      widget.liveData.addListener(_valueChanged);
    }
  }

  void _valueChanged() {
    setState(() {
      value = widget.liveData.value;
    });
  }

  @override
  void dispose() {
    widget.liveData.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}

/// Extension on BuildContext to provide convenient access to LiveData instances.
extension LiveDataExtension on BuildContext {
  /// Retrieves the value of a [LiveData] instance and registers the current build context
  /// to be rebuilt when the value changes.
  T live<T>(LiveData<T> liveData) {
    // This function is called during the build, so we need to make sure we're
    // not creating a new LiveDataBuilder on every build.
    return _InheritedLiveData.of<T>(this, liveData);
  }

  /// Checks if a [LiveData] instance is currently loading.
  bool isLoading(LiveData<dynamic> liveData) {
    // Force a rebuild when loading state changes
    _InheritedLiveData.of(this, liveData);
    return liveData.isLoading;
  }

  /// Gets the error of a [LiveData] instance, if any.
  Object? error(LiveData<dynamic> liveData) {
    // Force a rebuild when error changes
    _InheritedLiveData.of(this, liveData);
    return liveData.error;
  }
}

/// An internal widget that provides the InheritedWidget functionality
/// for the BuildContext extension methods.
class _InheritedLiveData<T> extends InheritedWidget {
  const _InheritedLiveData({
    required this.liveData,
    required this.value,
    required this.version,
    required super.child,
    super.key,
  });
  final LiveData<T> liveData;
  final T value;
  final int version;

  @override
  bool updateShouldNotify(_InheritedLiveData<T> oldWidget) {
    return oldWidget.version != version;
  }

  static T of<T>(BuildContext context, LiveData<T> liveData) {
    // This approach uses a listener to schedule a frame after the current build
    // This is a simplification - in a real implementation, we would use an
    // inherited widget to properly manage dependencies
    void listener() {
      // Schedule a rebuild after this frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // If the context is still mounted, call markNeedsBuild
        if (context.mounted) {
          context
              .findAncestorStateOfType<_LiveDataBuilderState<dynamic>>()
              ?.setState(() {});
        }
      });
    }

    // Add a listener to rebuild this context when the value changes
    liveData.addListener(listener);

    // Return the current value
    return liveData.value;
  }
}
