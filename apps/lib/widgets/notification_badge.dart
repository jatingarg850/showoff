import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../notification_screen.dart';

class NotificationBadge
    extends
        StatelessWidget {
  final Widget
  child;
  final Color?
  badgeColor;
  final Color?
  textColor;
  final double?
  badgeSize;

  const NotificationBadge({
    super.key,
    required this.child,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Consumer<
      NotificationProvider
    >(
      builder:
          (
            context,
            provider,
            _,
          ) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: child,
                ),
                if (provider.unreadCount >
                    0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(
                        2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            badgeColor ??
                            Colors.red,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth:
                            badgeSize ??
                            16,
                        minHeight:
                            badgeSize ??
                            16,
                      ),
                      child: Text(
                        provider.unreadCount >
                                99
                            ? '99+'
                            : provider.unreadCount.toString(),
                        style: TextStyle(
                          color:
                              textColor ??
                              Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
    );
  }
}

// Simple notification icon with badge
class NotificationIcon
    extends
        StatelessWidget {
  final double?
  size;
  final Color?
  color;
  final Color?
  badgeColor;

  const NotificationIcon({
    super.key,
    this.size,
    this.color,
    this.badgeColor,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return NotificationBadge(
      badgeColor: badgeColor,
      child: Icon(
        Icons.notifications,
        size:
            size ??
            24,
        color:
            color ??
            Colors.black,
      ),
    );
  }
}
