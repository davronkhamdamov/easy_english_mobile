import 'package:flutter/cupertino.dart';

/// A complete, self-contained iOS view demonstrating Apple HIG-compliant
/// collapsible Large Title navigation bar using pure [CupertinoPageScaffold]
/// and [CupertinoSliverNavigationBar].
class CupertinoSettingsScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onEditPressed;

  const CupertinoSettingsScreen({
    super.key,
    this.title = 'Settings',
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onEditPressed ?? () {},
              child: const Icon(CupertinoIcons.slider_horizontal_3),
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildSectionHeader('ACCOUNT'),
                  _buildCupertinoGroup([
                    _buildTile(
                      icon: CupertinoIcons.person_crop_circle,
                      iconColor: CupertinoColors.activeBlue,
                      title: 'Profile & Band Target',
                      value: 'Band 7.5',
                      showChevron: true,
                    ),
                    _buildTile(
                      icon: CupertinoIcons.bell_fill,
                      iconColor: CupertinoColors.systemRed,
                      title: 'Notifications',
                      value: 'Enabled',
                      showChevron: true,
                    ),
                  ]),
                  _buildSectionHeader('PREFERENCES'),
                  _buildCupertinoGroup([
                    _buildTile(
                      icon: CupertinoIcons.moon_fill,
                      iconColor: CupertinoColors.systemIndigo,
                      title: 'Dark Appearance',
                      trailingWidget: CupertinoSwitch(
                        value: true,
                        onChanged: (val) {},
                      ),
                    ),
                    _buildTile(
                      icon: CupertinoIcons.speaker_2_fill,
                      iconColor: CupertinoColors.activeGreen,
                      title: 'Audio Pronunciation',
                      value: 'UK Accent',
                      showChevron: true,
                    ),
                  ]),
                  _buildSectionHeader('SUPPORT & ABOUT'),
                  _buildCupertinoGroup([
                    _buildTile(
                      icon: CupertinoIcons.question_circle_fill,
                      iconColor: CupertinoColors.systemOrange,
                      title: 'Help & Practice Guide',
                      showChevron: true,
                    ),
                    _buildTile(
                      icon: CupertinoIcons.info_circle_fill,
                      iconColor: CupertinoColors.systemGrey,
                      title: 'Easy IELTS Version',
                      value: '2.4.0',
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.systemGrey,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Widget _buildCupertinoGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          final isLast = index == children.length - 1;
          return Column(
            children: [
              children[index],
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 54),
                  child: SizedBox(
                    height: 0.5,
                    child: ColoredBox(color: CupertinoColors.separator),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? value,
    Widget? trailingWidget,
    bool showChevron = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 18,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (value != null)
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ],
          if (showChevron) ...[
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.systemGrey3,
            ),
          ],
        ],
      ),
    );
  }
}
