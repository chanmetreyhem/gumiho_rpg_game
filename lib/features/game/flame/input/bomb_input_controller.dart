import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../gumiho_game.dart';

/// Invisible drag target on the viewport — uses Flame canvas coords for aim.
class BombInputController extends PositionComponent
    with DragCallbacks, HasGameReference<GumihoGame> {
  static const _hitSize = 88.0;
  static const _bottomInset = 28.0;
  static const _minDragPx = 48.0;

  Vector2? _dragStartCanvas;
  Vector2? _lastCanvas;
  bool _dragging = false;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomCenter;
    size = Vector2.all(_hitSize);
    _reposition(_viewportSize);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _reposition(size);
    }
  }

  Vector2 get _viewportSize {
    final size = game.camera.viewport.size;
    if (size.x > 0 && size.y > 0) return size;
    return game.size;
  }

  void _reposition(Vector2 viewSize) {
    position = Vector2(viewSize.x / 2, viewSize.y - _bottomInset);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (game.bombsRemaining <= 0 || game.paused) return;
    _dragging = true;
    game.isBombAiming = true;
    _dragStartCanvas = event.canvasPosition;
    _lastCanvas = event.canvasPosition;
    _updateAim(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_dragging) return;
    _lastCanvas = event.canvasEndPosition;
    _updateAim(event.canvasEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _finishDrag();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _cancelDrag();
  }

  void _updateAim(Vector2 canvas) {
    final start = _dragStartCanvas;
    if (start != null && canvas.distanceTo(start) < 12) {
      game.setBombAimPreview(null);
      return;
    }
    game.setBombAimPreview(game.bombTargetFromCanvas(canvas));
  }

  void _finishDrag() {
    if (!_dragging) return;

    final start = _dragStartCanvas;
    final end = _lastCanvas;
    game.setBombAimPreview(null);
    game.isBombAiming = false;
    _dragging = false;
    _dragStartCanvas = null;
    _lastCanvas = null;

    if (start == null || end == null) return;
    if (end.distanceTo(start) < _minDragPx) return;

    game.throwBombAt(game.bombTargetFromCanvas(end));
  }

  void _cancelDrag() {
    game.setBombAimPreview(null);
    game.isBombAiming = false;
    _dragging = false;
    _dragStartCanvas = null;
    _lastCanvas = null;
  }
}
