import 'package:flutter/material.dart';
import 'package:spargo_tools/src/widgets/overlay_manager/view_model/overlay_manager_overlay.dart';
import 'package:spargo_tools/src/widgets/overlay_manager/view_model/overlay_manager_view_model.dart';

class AppOverlayManagerWidget extends StatefulWidget {
  const AppOverlayManagerWidget({
    super.key,
    required this.buttonOverlayWidgetBuilder,
    required this.overlayWidgetBuilder,
    this.overlayWidth,
    this.overlayHeight,
    this.onIsOpenedOverlay,
    this.customOffset,
    this.overlayPlaceInButtonWidget = false,
    this.paddingFromSide = 12,
  });

  /// Builder виджета, на который происходит клик
  final ButtonOverlayBuilder buttonOverlayWidgetBuilder;

  /// Builder виджета, который нужно отобразить в overlay
  final OverlayBuilder overlayWidgetBuilder;

  /// CallBack изменения состояния overlay
  final void Function(bool isOpenedOverlay)? onIsOpenedOverlay;

  /// Ширина overlay
  final double? overlayWidth;

  /// Высота overlay для определения нижней точки виджета
  final double? overlayHeight;

  /// Дополнительные отступы
  final Offset? customOffset;

  /// Расположить оверлей в Offset кнопки
  final bool overlayPlaceInButtonWidget;

  /// Отступ от краев экрана
  final double paddingFromSide;

  @override
  State<AppOverlayManagerWidget> createState() =>
      _AppOverlayManagerWidgetState();
}

class _AppOverlayManagerWidgetState extends State<AppOverlayManagerWidget> {
  late final _vm = AppOverlayManagerViewModel(
    widgetState: this,
    onIsOpenedOverlay: widget.onIsOpenedOverlay,
    overlayWidgetBuilder: widget.overlayWidgetBuilder,
    overlayWidth: widget.overlayWidth,
    overlayHeight: widget.overlayHeight,
    paddingFromSide: widget.paddingFromSide,
    offset: widget.customOffset,
    buttonOverlayWidgetBuilder: widget.buttonOverlayWidgetBuilder,
    overlayPlaceInButtonWidget: widget.overlayPlaceInButtonWidget,
  );

  @override
  void initState() {
    super.initState();
    _vm.init();
  }

  @override
  void dispose() {
    _vm.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ViewWidget(vm: _vm);
  }
}

class _ViewWidget extends StatelessWidget {
  const _ViewWidget({
    super.key,
    required this.vm,
  });

  final AppOverlayManagerViewModel vm;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: vm.overlay.layerLink,
      child: ValueListenableBuilder<bool>(
        valueListenable: vm.overlay.isOpenOverlay,
        builder: (context, value, child) {
          return vm.buttonOverlayWidgetBuilder(
              context, vm.onOpenOverlayPressed, vm.overlay.isOpenOverlay);
        },
      ),
    );
  }
}
