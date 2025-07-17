import 'package:ophth_board/features/content_entries/model/content_entry.dart';

extension ContentEntryTypeExtension on ContentType {
  String get collectionName {
    switch (this) {
      case ContentType.post:
        return 'posts';
      case ContentType.announcement:
        return 'announcements';
      case ContentType.noticeBoard:
        return 'notice_board';
    }
  }

  String get displayName {
    switch (this) {
      case ContentType.post:
        return 'Post';
      case ContentType.announcement:
        return 'Announcement';
      case ContentType.noticeBoard:
        return 'Notice Board';
    }
  }
}
