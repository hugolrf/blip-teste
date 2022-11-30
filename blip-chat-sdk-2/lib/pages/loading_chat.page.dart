import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class LoadingChatPage extends StatelessWidget {
  const LoadingChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonAvatar(
              style: SkeletonAvatarStyle(
                height: 40,
                width: 40,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              child: Column(
                children: const [
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 14,
                      width: 120,
                      borderRadius: BorderRadius.all(
                        Radius.circular(22),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 12,
                      width: 80,
                      borderRadius: BorderRadius.all(
                        Radius.circular(22),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Expanded(
            child: SkeletonLine(
              style: SkeletonLineStyle(height: null),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              bottomPadding > 0 ? bottomPadding : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Flexible(
                  child: SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 44,
                      borderRadius: BorderRadius.all(
                        Radius.circular(22),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    height: 44,
                    width: 44,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
