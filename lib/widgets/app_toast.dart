import 'dart:async';

import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppToastType { success, failed }

enum SubmissionAction { create, update, delete }

class AppToastData {
  const AppToastData({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
  });

  final int id;
  final AppToastType type;
  final String title;
  final String message;
  final Duration duration;
}

class AppToast extends ChangeNotifier {
  AppToast._();

  static final AppToast instance = AppToast._();
  static const Duration defaultDuration = Duration(seconds: 4);

  AppToastData? _current;
  Timer? _timer;
  int _nextId = 0;

  AppToastData? get current => _current;

  static void showSuccess(String message, {String title = 'Success'}) {
    instance.show(type: AppToastType.success, title: title, message: message);
  }

  static void showFailed(String message, {String title = 'Failed'}) {
    instance.show(type: AppToastType.failed, title: title, message: message);
  }

  static void showSubmissionSuccess({
    required SubmissionAction action,
    required String subject,
  }) {
    showSuccess('The $subject has been ${action.pastTense}.');
  }

  static void showSubmissionFailed({
    required SubmissionAction action,
    required String subject,
  }) {
    showFailed('Failed to ${action.verb} the $subject.');
  }

  void show({
    required AppToastType type,
    required String title,
    required String message,
    Duration duration = defaultDuration,
  }) {
    _timer?.cancel();
    _current = AppToastData(
      id: ++_nextId,
      type: type,
      title: title,
      message: message,
      duration: duration,
    );
    notifyListeners();
    _timer = Timer(duration, dismiss);
  }

  void dismiss() {
    if (_current == null) return;
    _timer?.cancel();
    _timer = null;
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

extension SubmissionActionText on SubmissionAction {
  String get verb {
    return switch (this) {
      SubmissionAction.create => 'create',
      SubmissionAction.update => 'update',
      SubmissionAction.delete => 'delete',
    };
  }

  String get pastTense {
    return switch (this) {
      SubmissionAction.create => 'created',
      SubmissionAction.update => 'updated',
      SubmissionAction.delete => 'deleted',
    };
  }
}

class AppToastHost extends StatelessWidget {
  const AppToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppToast.instance,
      builder: (context, _) {
        final notification = AppToast.instance.current;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final maxWidth = (screenWidth - 32).clamp(260.0, 340.0).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              top: 32,
              right: 14,
              child: IgnorePointer(
                ignoring: notification == null,
                child: SafeArea(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: notification == null
                          ? const SizedBox.shrink(key: ValueKey('empty'))
                          : _AppToast(
                              key: ValueKey(notification.id),
                              data: notification,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AppToast extends StatefulWidget {
  const _AppToast({super.key, required this.data});

  final AppToastData data;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.data.duration,
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.data.type == AppToastType.success;
    final accent = isSuccess ? AppColors.success : AppColors.error;
    final background = AppColors.white.withValues(alpha: 0.9);
    final icon = isSuccess ? Icons.check_rounded : Icons.close_rounded;

    return Semantics(
      liveRegion: true,
      label: '${widget.data.title}: ${widget.data.message}',
      child: Material(
        color: AppColors.transparent,
        elevation: 12,
        shadowColor: AppColors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.72),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.96),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.data.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Semantics(
                        button: true,
                        label: 'Close notification',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: AppToast.instance.dismiss,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return LinearProgressIndicator(
                      minHeight: 3,
                      value: 1 - _progressController.value,
                      color: accent,
                      backgroundColor: accent.withValues(alpha: 0.2),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
