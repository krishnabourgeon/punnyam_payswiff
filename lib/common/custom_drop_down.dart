import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdown<T> extends StatefulWidget {
  final void Function(T)? onChange;
  final List<DropdownItem<T>>? items;
  final DropdownStyle? dropdownStyle;
  final DropdownButtonStyle? dropdownButtonStyle;
  final Icon? icon;
  final bool hideIcon;
  final String? initialValue;
  final EdgeInsetsGeometry? padding;
  final TextStyle? initialTextStyle;
  final double? overlayPadding;
  final bool? parrentScrolled;
  final void Function(String)? textFormFieldOnChanged;
  final bool? isShowSearchBox;
  const CustomDropdown(
      {Key? key,
      this.hideIcon = false,
      @required this.items,
      this.dropdownStyle,
      this.dropdownButtonStyle,
      this.icon,
      this.initialValue,
      @required this.onChange,
      this.padding,
      this.initialTextStyle,
      this.overlayPadding = 0,
      this.parrentScrolled,
      this.textFormFieldOnChanged,
      this.isShowSearchBox})
      : super(key: key);

  @override
  CustomDropdownState<T> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>>
    with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  late OverlayEntry _overlayEntry;
  bool _isOpen = false;
  int _currentIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void didUpdateWidget(covariant CustomDropdown<T> oldWidget) {
    if (widget.parrentScrolled == true && _isOpen) {
      _overlayEntry.remove();
      _animationController.reverse();
      setState(() {
        _isOpen = false;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _closeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var style = widget.dropdownButtonStyle;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          alignment: style?.alignment,
          padding: style?.padding,
          color: style?.color,
          decoration: style?.decoration ??
              BoxDecoration(border: Border.all(color: Colors.black)),
          foregroundDecoration: style?.foregroundDecoration,
          width: style?.width ?? double.maxFinite,
          height: style?.height ?? 45.h,
          margin: style?.margin,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (_currentIndex == -1) ...[
                  Text(widget.initialValue ?? "",
                      style: widget.initialTextStyle ??
                          style?.unselectedTextStyle),
                  // widget.child!,
                ] else ...[
                  if (T == String) ...[
                    Text(
                      widget.items![_currentIndex].value.toString(),
                      style: style?.textStyle,
                    ),
                  ]
                ],
                const Spacer(),
                if (!widget.hideIcon)
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: widget.icon ??
                        const Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.black,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject()! as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    var topOffset = offset.dy + size.height + 5;
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _toggleDropdown(close: true),
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.overlayPadding!),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: topOffset,
                  width: widget.dropdownStyle?.width ?? size.width,
                  child: CompositedTransformFollower(
                    offset: Offset(0, size.height + 5),
                    link: _layerLink,
                    showWhenUnlinked: false,
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: widget.dropdownStyle?.borderRadius ??
                              BorderRadius.zero,
                          side: widget.dropdownStyle?.borderSide ??
                              BorderSide.none),
                      color: widget.dropdownStyle?.color,
                      child: SizeTransition(
                        axisAlignment: 1,
                        sizeFactor: _expandAnimation,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: ((MediaQuery.of(context).size.height -
                                        topOffset -
                                        15) <=
                                    15)
                                ? 300
                                : MediaQuery.of(context).size.height -
                                    topOffset -
                                    15,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (widget.isShowSearchBox ?? false)
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w),
                                        child: StatefulBuilder(
                                          builder: (context, textFieldState) {
                                            return TextFormField(
                                              onChanged:
                                                  widget.textFormFieldOnChanged,
                                              decoration: const InputDecoration(
                                                  hintText: 'Search'),
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                (widget.isShowSearchBox ?? false)
                                    ? 10.verticalSpace
                                    : 0.verticalSpace,
                                // context.read<BillingProvider>().isSearching
                                //     ? Center(
                                //         child: CircularProgressIndicator(),
                                //       )
                                //     :
                                StatefulBuilder(
                                  builder: (context, builderState) =>
                                      ListView.builder(
                                    itemCount: widget.items?.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: widget.overlayPadding!),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) => InkWell(
                                      onTap: () {
                                        setState(() => _currentIndex = index);
                                        widget.onChange!(
                                            widget.items![index].value);
                                        _toggleDropdown();
                                      },
                                      child: widget.items![index],
                                    ),
                                    // children: widget.items!
                                    //     .asMap()
                                    //     .entries
                                    //     .map((item) {
                                    //   debugPrint(
                                    //       'items length ${widget.items?.length}');
                                    //   return InkWell(
                                    //     onTap: () {
                                    //       setState(
                                    //           () => _currentIndex = item.key);
                                    //       widget.onChange!(item.value.value);
                                    //       _toggleDropdown();
                                    //     },
                                    //     child: item.value,
                                    //   );
                                    // }).toList(),
                                  ),
                                ),
                                10.verticalSpace
                              ],
                            ),
                          ),
                        ),
                      ),
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

  void _closeOverlay() {
    if (_isOpen && mounted) {
      _overlayEntry.remove();
    }
  }

  void _toggleDropdown({bool close = false}) async {
    FocusScope.of(context).unfocus();
    if (_isOpen || close) {
      await _animationController.reverse();
      _overlayEntry.remove();
      setState(() {
        _isOpen = false;
      });
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      setState(() => _isOpen = true);
      _animationController.forward();
    }
  }
}

class DropdownItem<T> extends StatelessWidget {
  final T value;
  final Widget child;
  const DropdownItem({Key? key, required this.value, required this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class DropdownButtonStyle {
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;
  final TextStyle? unselectedTextStyle;
  const DropdownButtonStyle({
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.margin,
    this.textStyle,
    this.unselectedTextStyle,
  });
}

class DropdownStyle {
  final Color? color;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? borderSide;
  const DropdownStyle({
    this.color,
    this.width,
    this.borderRadius,
    this.borderSide,
  });
}
