import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../screens/edit_image_screen.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onDelete;

  const ImageCard({
    super.key,
    required this.imageUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildShimmer(),
                errorWidget: (context, url, error) => _buildErrorWidget(),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildEditButton(context),
          ),
          if (onDelete != null)
            Positioned(
              top: 8,
              right: 8,
              child: _buildDeleteButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditImageScreen(imageUrl: imageUrl),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.edit_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}