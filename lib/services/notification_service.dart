import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smonsg/providers/friends_provider.dart';
import 'package:smonsg/widgets/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  void showOverlayNotification(BuildContext context, String message,
      {required String type}) {
    final overlayState = Overlay.of(context);
    final AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 250), // Faster animation
      vsync: Navigator.of(context),
    );

    late OverlayEntry overlayEntry;
    bool isDismissed =
        false; // Flag to track if the notification has been dismissed
    double horizontalDragOffset = 0.0;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 10, // Adjust initial top position (higher on the screen)
          left: horizontalDragOffset,
          right: -horizontalDragOffset,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.5, // Small scale at the start
              end: 1.0, // Full scale at the end
            ).animate(CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOut,
            )),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0), // Offscreen at the top
                end: const Offset(0.0, 0.0), // Onscreen position
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: Curves.easeOut,
              )),
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  horizontalDragOffset += details.primaryDelta!;
                  overlayEntry.markNeedsBuild();
                },
                onHorizontalDragEnd: (details) {
                  if (horizontalDragOffset.abs() >
                      MediaQuery.of(context).size.width / 2) {
                    if (!isDismissed) {
                      isDismissed = true;
                      animationController.reverse().then((_) {
                        if (overlayEntry.mounted) {
                          overlayEntry.remove();
                        }
                      });
                    }
                  } else {
                    horizontalDragOffset = 0.0;
                    overlayEntry.markNeedsBuild();
                  }
                },
                child: NotificationWidget(message: message),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Start the animation
    animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!isDismissed) {
        isDismissed = true;
        animationController.reverse().then((_) {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        });
      }
    });

    // Fetch friends on notification only if the type is 'friend'
    if (type == 'friend') {
      Provider.of<FriendsProvider>(context, listen: false)
          .fetchFriends(forceRefresh: true);
    }
  }
}
