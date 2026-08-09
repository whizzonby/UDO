import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/widgets/udo_design_system.dart';
import '../../../more/presentation/providers/notifications_provider.dart';
import '../../../more/presentation/screens/more_screen.dart'
    show WeddingSettingsSheet;
import '../../../more/presentation/screens/notifications_screen.dart';
import '../providers/home_provider.dart';
import 'editorial_home.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final notificationCount = ref.watch(notificationsProvider).totalActive;

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: UdoDesign.plan,
        child: state.isLoading
            ? const _HomeSkeleton()
            : EditorialHome(
                state: state,
                onProfileTap: () => _openWeddingSettings(context),
                onNotificationTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                onSettingsTap: () => _openWeddingSettings(context),
                onEditCoverPhoto: () => _editCoverPhoto(context, notifier),
                notificationCount: notificationCount,
              ),
      ),
    );
  }

  Future<void> _editCoverPhoto(BuildContext context, HomeNotifier notifier) async {
    final xfile = await ImagePicker().pickMedia(imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Uploading cover photo...')));
    final ok = await notifier.uploadCoverPhoto(bytes, xfile.name);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? 'Cover photo updated.' : "Couldn't upload that photo. Try again."),
      backgroundColor: ok ? null : UdoDesign.rose,
    ));
  }

  void _openWeddingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const WeddingSettingsSheet(),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double height, {double width = double.infinity}) => Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: UdoDesign.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: UdoDesign.border),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 110),
      children: [
        bar(220),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: bar(96)),
          const SizedBox(width: 10),
          Expanded(child: bar(96)),
        ]),
        Row(children: [
          Expanded(child: bar(96)),
          const SizedBox(width: 10),
          Expanded(child: bar(96)),
        ]),
        const SizedBox(height: 10),
        bar(160),
        bar(130),
      ],
    );
  }
}
