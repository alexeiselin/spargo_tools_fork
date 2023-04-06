import 'package:flutter/material.dart';

typedef OverlayBuilder = Widget Function(BuildContext context,
    void Function() hideOverlay, ValueNotifier<bool> isOpenedOverlayNotifier);

typedef ButtonOverlayBuilder = Widget Function(BuildContext context,
    void Function() showOverlay, ValueNotifier<bool> isOpenedOverlayNotifier);

class AppOverlayManagerOverlay {
  AppOverlayManagerOverlay({
    required State widgetState,
    required this.overlayWidgetBuilder,
    required this.overlayWidth,
    required this.overlayHeight,
    required this.customOffset,
    required this.onIsOpenedOverlay,
    required this.paddingFromSide,
    this.overlayPlaceInButtonWidget = false,
  }) : _widgetState = widgetState {
    isOpenOverlay
        .addListener(() => onIsOpenedOverlay?.call(isOpenOverlay.value));
  }

  final State _widgetState;
  BuildContext get _context => _widgetState.context;

  final OverlayBuilder overlayWidgetBuilder;
  final double? overlayWidth;
  final double? overlayHeight;
  final double paddingFromSide;
  final Offset? customOffset;

  /// Расположить overlay прям в виджете кнопки
  final bool overlayPlaceInButtonWidget;

  OverlayEntry? overlayEntry;
  final layerLink = LayerLink();

  ValueNotifier<bool> isOpenOverlay = ValueNotifier(false);
  final void Function(bool isOpenedOverlay)? onIsOpenedOverlay;

  void _destroyOverlayEntry() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  void destroy() {
    _destroyOverlayEntry();
    isOpenOverlay.dispose();
    isOpenOverlay
        .removeListener(() => onIsOpenedOverlay?.call(isOpenOverlay.value));
  }

  void hideOverlay() {
    _destroyOverlayEntry();
    isOpenOverlay.value = false;
  }

  void showOverlay() {
    final renderBox = _context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final rightDxOverlay = offset.dx + (overlayWidth ?? size.width);
    final offsetX = rightDxOverlay > MediaQuery.of(_context).size.width
        ? -((MediaQuery.of(_context).size.width - rightDxOverlay).abs() +
            paddingFromSide)
        : 0.0;
    final offsetY = size.height + paddingFromSide;

    final resultOffsetX = offsetX + (customOffset?.dx ?? 0);
    var resultOffsetY = offsetY -
        (overlayPlaceInButtonWidget ? size.height + paddingFromSide : 0);
    final difference = MediaQuery.of(_context).size.height -
        (offset.dy + resultOffsetY + (overlayHeight ?? 0));
    if (difference < 0) {
      resultOffsetY += difference - paddingFromSide;
    }
    resultOffsetY += (customOffset?.dy ?? 0);

    overlayEntry = OverlayEntry(
      builder: (innerContext) {
        return GestureDetector(
          onTap: hideOverlay,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: MediaQuery.of(_context).size.height,
            width: MediaQuery.of(_context).size.width,
            child: Stack(
              children: [
                Positioned(
                  width: overlayWidth ?? size.width,
                  child: CompositedTransformFollower(
                    link: layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(resultOffsetX, resultOffsetY),
                    child: overlayWidgetBuilder(
                        innerContext, hideOverlay, isOpenOverlay),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(_context).insert(overlayEntry!);
    isOpenOverlay.value = true;
  }
}
