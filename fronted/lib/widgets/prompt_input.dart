import 'package:flutter/material.dart';

class PromptInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const PromptInput({
    super.key,
    required this.controller,
    required this.onGenerate,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.surface.withOpacity(0.9),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: primary.withAlpha((0.3 * 255).round()),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy_outlined,
                color: primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '描述你想要生成的图像...\n例如: "一只可爱的小猫坐在彩虹上"',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isGenerating ? null : onGenerate,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: primary.withOpacity(0.5),
            ).copyWith(
              overlayColor: MaterialStateProperty.all(primary.withOpacity(0.2)),
            ),
            child: isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '生成图像',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}