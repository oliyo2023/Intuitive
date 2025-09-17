import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅会员'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSubscriptionCard(
              context: context,
              title: '基础版',
              price: 'Rp 150,000 / 月',
              features: [
                '120 张图片生成',
                '高清分辨率',
                '无水印',
                '基础图片编辑',
              ],
              buttonText: '选择基础版',
              isRecommended: false,
              onPressed: () {
                // TODO: Implement payment logic
              },
            ),
            const SizedBox(height: 24),
            _buildSubscriptionCard(
              context: context,
              title: '专业版',
              price: 'Rp 450,000 / 月',
              features: [
                '500 张图片生成',
                '4K 分辨率',
                '无水印',
                '高级图片编辑',
                '视频生成功能',
                '优先访问新功能',
              ],
              buttonText: '选择专业版',
              isRecommended: true,
              onPressed: () {
                // TODO: Implement payment logic
              },
            ),
             const SizedBox(height: 24),
            _buildSubscriptionCard(
              context: context,
              title: '按量付费',
              price: 'Rp 20,000',
              features: [
                '10 张图片生成',
                '高清分辨率',
                '无水印',
              ],
              buttonText: '购买次数包',
              isRecommended: false,
              onPressed: () {
                // TODO: Implement payment logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required String title,
    required String price,
    required List<String> features,
    required String buttonText,
    required bool isRecommended,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      elevation: isRecommended ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '推荐',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isRecommended) const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price, style: theme.textTheme.titleLarge?.copyWith(color: primaryColor)),
            const SizedBox(height: 24),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: isRecommended ? primaryColor : null,
                foregroundColor: isRecommended ? Colors.white : null,
              ),
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }
}