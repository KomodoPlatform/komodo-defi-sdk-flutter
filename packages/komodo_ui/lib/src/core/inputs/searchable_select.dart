import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A model class representing a selectable item
class SelectItem<T> {
  const SelectItem({
    required this.id,
    required this.value,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String id;
  final T value;
  final String title;
  final Widget? leading;
  final Widget? trailing;
}

/// Controller for managing selection state
class SearchableSelectController<T> extends ChangeNotifier {
  SelectItem<T>? _selectedItem;

  SelectItem<T>? get selectedItem => _selectedItem;

  void select(SelectItem<T>? item) {
    if (_selectedItem?.id != item?.id) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  void clear() {
    select(null);
  }
}

/// Widget that displays a searchable select input
class SearchableSelect<T> extends StatefulWidget {
  const SearchableSelect({
    required this.items,
    required this.onItemSelected,
    super.key,
    this.hint,
    this.selectedItemBuilder,
    this.itemBuilder,
    this.forceDropdown = false,
    this.decoration,
    this.initialValue,
    this.controller,
  });

  final List<SelectItem<T>> items;
  final Function(SelectItem<T>)? onItemSelected;
  final String? hint;
  final Widget Function(SelectItem<T>)? selectedItemBuilder;
  final Widget Function(SelectItem<T>, VoidCallback?)? itemBuilder;
  final bool forceDropdown;
  final InputDecoration? decoration;
  final T? initialValue;
  final SearchableSelectController<T>? controller;

  @override
  State<SearchableSelect<T>> createState() => _SearchableSelectState<T>();
}

class _SearchableSelectState<T> extends State<SearchableSelect<T>> {
  SelectItem<T>? _selectedItem;
  late final SearchableSelectController<T> _controller;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeSelection();
  }

  void _initializeController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isControllerInternal = true;
      _controller = SearchableSelectController<T>();
    }
    _controller.addListener(_onControllerChange);
  }

  void _initializeSelection() {
    if (widget.initialValue != null) {
      _selectedItem = widget.items.firstWhere(
        (item) => item.value == widget.initialValue,
        orElse: () => widget.items.first,
      );
      _controller.select(_selectedItem);
    } else if (_controller.selectedItem != null) {
      _selectedItem = _controller.selectedItem;
    }
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {
        _selectedItem = _controller.selectedItem;
      });
    }
  }

  @override
  void didUpdateWidget(SearchableSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      _initializeController();
    }

    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != null) {
      _initializeSelection();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _showSearch(BuildContext context) async {
    final selected = await showSearchOverlay<T>(
      context,
      items: widget.items,
      itemBuilder: widget.itemBuilder,
      forceDropdown: widget.forceDropdown,
    );

    if (selected != null) {
      setState(() {
        _selectedItem = selected;
      });
      _controller.select(selected);
      widget.onItemSelected?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchableSelectView(
      selectedItem: _selectedItem,
      hint: widget.hint,
      onTap: () => _showSearch(context),
      selectedItemBuilder: widget.selectedItemBuilder,
    );
  }
}

/// Presentation widget for the searchable select
class SearchableSelectView<T> extends StatelessWidget {
  const SearchableSelectView({
    required this.selectedItem,
    required this.onTap,
    super.key,
    this.hint,
    this.selectedItemBuilder,
  });

  final SelectItem<T>? selectedItem;
  final VoidCallback onTap;
  final String? hint;
  final Widget Function(SelectItem<T>)? selectedItemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: theme.textTheme.bodyLarge?.fontSize,
            ),
          ),
          isEmpty: selectedItem == null,
          child: selectedItem == null
              ? null
              : selectedItemBuilder?.call(selectedItem!) ??
                  DefaultSelectedItemView(item: selectedItem!),
        ),
      ),
    );
  }
}

/// Default view for selected items
class DefaultSelectedItemView extends StatelessWidget {
  const DefaultSelectedItemView({
    required this.item,
    super.key,
  });

  final SelectItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (item.leading != null) ...[
          item.leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            item.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (item.trailing != null) ...[
          const SizedBox(width: 8),
          item.trailing!,
        ],
      ],
    );
  }
}

class SearchableSelectorDelegate<T> extends SearchDelegate<SelectItem<T>?> {
  SearchableSelectorDelegate(
    this.items, {
    // TODO: Localize and/or expose as a parameter
    this.searchHint = 'Search',
    this.itemBuilder,
  });

  final Iterable<SelectItem<T>> items;
  final String searchHint;
  final Widget Function(SelectItem<T> item, VoidCallback? onTap)? itemBuilder;

  @override
  String get searchFieldLabel => searchHint;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return itemBuilder?.call(item, () => close(context, item)) ??
            SearchResultTile(
              item: item,
              onTap: () => close(context, item),
            );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return itemBuilder?.call(item, () => query = item.title) ??
            SearchResultTile(
              item: item,
              onTap: () => query = item.title,
            );
      },
    );
  }
}

class SearchResultTile<T> extends StatelessWidget {
  const SearchResultTile({
    required this.item,
    super.key,
    this.onTap,
  });

  final SelectItem<T> item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: item.leading,
      title: Text(item.title),
      trailing: item.trailing,
      onTap: onTap,
    );
  }
}

Future<SelectItem<T>?> showSearchOverlay<T>(
  BuildContext context, {
  required Iterable<SelectItem<T>> items,
  String searchHint = 'Search',
  Widget Function(SelectItem<T> item, VoidCallback? onTap)? itemBuilder,
  bool forceDropdown = false,
}) async {
  final isMobile = MediaQuery.of(context).size.width < 600 && !forceDropdown;

  if (isMobile) {
    return showSearch<SelectItem<T>?>(
      context: context,
      delegate: SearchableSelectorDelegate(
        items,
        searchHint: searchHint,
        itemBuilder: itemBuilder,
      ),
    );
  } else {
    return showDropdownSearch(
      context,
      items,
      searchHint: searchHint,
      itemBuilder: itemBuilder,
    );
  }
}

OverlayEntry? _overlayEntry;
Completer? _completer;

Future<SelectItem<T>?> showDropdownSearch<T>(
  BuildContext context,
  Iterable<SelectItem<T>> items, {
  String searchHint = 'Search',
  Widget Function(SelectItem<T> item, VoidCallback? onTap)? itemBuilder,
}) async {
  final renderBox = context.findRenderObject()! as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);

  void clearOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _completer = null;
  }

  void onItemSelected(SelectItem<T>? item) {
    _completer?.complete(item);
    clearOverlay();
  }

  clearOverlay();

  _completer = Completer<SelectItem<T>?>();
  _overlayEntry = OverlayEntry(
    builder: (context) {
      return GestureDetector(
        onTap: () => onItemSelected(null),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height,
              width: renderBox.size.width,
              child: _SearchOverlay(
                items: items,
                onSelected: onItemSelected,
                searchHint: searchHint,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Overlay.of(context).insert(_overlayEntry!);
  });

  return _completer!.future as Future<SelectItem<T>?>;
}

class _SearchOverlay<T> extends StatefulWidget {
  const _SearchOverlay({
    required this.items,
    required this.onSelected,
    this.searchHint = 'Search',
    this.itemBuilder,
  });
  final Iterable<SelectItem<T>> items;
  final ValueChanged<SelectItem<T>?>? onSelected;
  final String searchHint;
  final Widget Function(SelectItem<T> item, VoidCallback? onTap)? itemBuilder;

  @override
  State<_SearchOverlay<T>> createState() => _SearchOverlayState<T>();
}

class _SearchOverlayState<T> extends State<_SearchOverlay<T>> {
  late Iterable<SelectItem<T>> filteredItems;
  String query = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      query = newQuery;
      filteredItems = widget.items.where(
        (item) => item.title.toLowerCase().contains(query.toLowerCase()),
      );
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                focusNode: _focusNode,
                readOnly: widget.onSelected == null,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: theme.inputDecorationTheme.border ??
                      defaultSearchableSelectTheme(
                        theme.brightness,
                        theme.colorScheme,
                      ).border,
                ),
                style: theme.textTheme.bodyLarge,
                onChanged: updateSearchQuery,
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems.elementAt(index);
                  return widget.itemBuilder?.call(
                        item,
                        () => widget.onSelected?.call(item),
                      ) ??
                      SearchResultTile(
                        item: item,
                        onTap: () => widget.onSelected?.call(item),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The recommended theme for the [SearchableSelect] widget.
///
/// NB! This is not applied automatically, and is only a suggestion. You need
/// to apply it to your theme.
InputDecorationTheme defaultSearchableSelectTheme(
  Brightness themeMode,
  ColorScheme colorScheme,
) {
  final isDark = themeMode == Brightness.dark;
  final surfaceColor = isDark ? Colors.grey[900] : Colors.grey[50];
  final borderColor = isDark
      ? colorScheme.onSurface.withOpacity(0.1)
      : colorScheme.outline.withOpacity(0.2);

  return InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor?.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.primary.withOpacity(0.5),
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  );
}

class MockCoinIcon extends StatelessWidget {
  const MockCoinIcon(this.symbol, {super.key});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          symbol.substring(0, math.min(2, symbol.length)),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Generic method to show a searchable select dialog/overlay
Future<T?> showSearchableSelect<T>(
  BuildContext context, {
  required List<SelectItem<T>> items,
  String searchHint = 'Search',
  Widget Function(SelectItem<T> item, VoidCallback? onTap)? itemBuilder,
  T? Function(SelectItem<T>?)? convertResult,
  bool? isMobile,
}) async {
  isMobile ??= MediaQuery.of(context).size.width < 600;

  final SelectItem<T>? selected;

  if (isMobile) {
    selected = await showSearch<SelectItem<T>?>(
      context: context,
      delegate: SearchableSelectorDelegate(
        items,
        searchHint: searchHint,
        itemBuilder: itemBuilder,
      ),
    );
  } else {
    selected = await showSearchOverlay(
      context,
      items: items,
      searchHint: searchHint,
      itemBuilder: itemBuilder,
    );
  }

  // Allow conversion of the result if needed
  if (convertResult != null) {
    return convertResult(selected);
  }

  return selected?.value;
}

////////////////////////////////////////////////////////////////////////////////
// Demo app:

void main() {
  runApp(
    MaterialApp(
      home: const _DemoScreen(),
      theme: ThemeData.dark().copyWith(
        inputDecorationTheme: defaultSearchableSelectTheme(
          Brightness.dark,
          const ColorScheme.dark(),
        ),
      ),
    ),
  );
}

class _DemoScreen extends StatelessWidget {
  const _DemoScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Dropdown Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crypto Coin Selector',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const _CoinDropdownDemo(),

                const SizedBox(height: 32),

                Text(
                  'User Selector',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _UserDropdownDemo(),

                const SizedBox(height: 32),

                // Usage instructions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Features Demo:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Responsive layout (resize window to see mobile/desktop modes)\n'
                          '• Search functionality\n'
                          '• Custom item rendering\n'
                          '• Copy to clipboard\n'
                          '• Theme support',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinDropdownDemo extends StatefulWidget {
  const _CoinDropdownDemo();

  @override
  State<_CoinDropdownDemo> createState() => _CoinDropdownDemoState();
}

class _CoinDropdownDemoState extends State<_CoinDropdownDemo> {
  final controller = SearchableSelectController<String>();

  final coinItems = [
    const SelectItem(
      id: 'KMD',
      title: 'Komodo',
      value: 'KMD',
      leading: MockCoinIcon('KMD'),
      trailing: Text('+2.9%', style: TextStyle(color: Colors.green)),
    ),
    const SelectItem(
      id: 'SL',
      title: 'SecondLive',
      value: 'SL',
      leading: MockCoinIcon('SL'),
      trailing: Text('+322.9%', style: TextStyle(color: Colors.green)),
    ),
    const SelectItem(
      id: 'KE',
      title: 'KiloEx',
      value: 'KE',
      leading: MockCoinIcon('KE'),
      trailing: Text('-2.09%', style: TextStyle(color: Colors.red)),
    ),
    const SelectItem(
      id: 'BTC',
      title: 'Bitcoin',
      value: 'BTC',
      leading: MockCoinIcon('BTC'),
      trailing: Text('+1.2%', style: TextStyle(color: Colors.green)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SearchableSelect<String>(
      controller: controller,
      items: coinItems,
      onItemSelected: (item) {
        print('Selected: ${item.title}');
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _UserDropdownDemo extends StatelessWidget {
  _UserDropdownDemo();

  final userItems = [
    const SelectItem(
      id: '0x4cd....66fv84',
      title: 'Anton Bulov',
      value: '0x4cd....66fv84',
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          'https://picsum.photos/seed/1/100',
        ),
      ),
      trailing: Icon(Icons.verified, color: Colors.blue),
    ),
    const SelectItem(
      id: '5bvns....66fv84',
      title: 'Sarah Connor',
      value: '5bvns....66fv84',
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          'https://picsum.photos/seed/2/100',
        ),
      ),
    ),
    const SelectItem(
      id: '9vdsf....13695',
      title: 'John Doe',
      value: '9vdsf....13695',
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          'https://picsum.photos/seed/3/100',
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchableSelect<String>(
      items: userItems,
      hint: 'To Anton Bulov',
      onItemSelected: (item) {
        debugPrint('Selected user: ${item.title}');
      },
      selectedItemBuilder: (item) => Row(
        children: [
          if (item.leading != null) ...[
            item.leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              item.title,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'ID copied to clipboard',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
