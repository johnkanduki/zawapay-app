import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// The latest photos of the phone, in a row under the scanner (like
/// WhatsApp). Tapping one gives its file path, to read a QR code from it.
///
/// Shows nothing when photo access is refused or the gallery is empty.
class RecentPhotosStrip extends StatefulWidget {
  const RecentPhotosStrip({super.key, required this.onPicked});

  final ValueChanged<String> onPicked;

  @override
  State<RecentPhotosStrip> createState() => _RecentPhotosStripState();
}

class _RecentPhotosStripState extends State<RecentPhotosStrip> {
  static const int _count = 24;
  static const double _size = 92;

  List<AssetEntity> _photos = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) return;
      final photos = await PhotoManager.getAssetListRange(
        start: 0,
        end: _count,
        type: RequestType.image,
        // Newest first.
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );
      if (mounted) setState(() => _photos = photos);
    } catch (_) {
      // No photos (simulator, tests, refused): the strip stays hidden.
    }
  }

  Future<void> _open(AssetEntity photo) async {
    final file = await photo.file;
    if (file != null && mounted) widget.onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _open(_photos[i]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox.square(
              dimension: _size,
              child: _Thumbnail(photo: _photos[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photo});

  final AssetEntity photo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: photo.thumbnailDataWithSize(const ThumbnailSize.square(240)),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const ColoredBox(color: Color(0x1FFFFFFF));
        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}
