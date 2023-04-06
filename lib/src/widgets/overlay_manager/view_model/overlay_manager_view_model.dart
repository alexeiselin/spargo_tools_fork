import 'package:flutter/material.dart';
import 'package:spargo_tools/src/widgets/overlay_manager/view_model/overlay_manager_overlay.dart';

class AppOverlayManagerViewModel {
  AppOverlayManagerViewModel({
    required State widgetState,
    required OverlayBuilder overlayWidgetBuilder,
    required double? overlayWidth,
    required double? overlayHeight,
    required double paddingFromSide,
    required Offset? offset,
    required this.buttonOverlayWidgetBuilder,
    required void Function(bool)? onIsOpenedOverlay,
    bool overlayPlaceInButtonWidget = false,
  }) : _widgetState = widgetState {
    overlay = AppOverlayManagerOverlay(
      widgetState: _widgetState,
      overlayWidgetBuilder: overlayWidgetBuilder,
      overlayWidth: overlayWidth,
      overlayHeight: overlayHeight,
      customOffset: offset,
      onIsOpenedOverlay: onIsOpenedOverlay,
      overlayPlaceInButtonWidget: overlayPlaceInButtonWidget,
      paddingFromSide: paddingFromSide,
    );
  }

  final State _widgetState;
  BuildContext get _context => _widgetState.context;
  bool get mounted => _widgetState.mounted;

  late final AppOverlayManagerOverlay overlay;
  final ButtonOverlayBuilder buttonOverlayWidgetBuilder;

  void onOpenOverlayPressed() {
    overlay.showOverlay();
  }

  void destroy() {
    overlay.destroy();
  }

  void init() {}
}
