// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../models/notiflow_notification.dart';
import '../types.dart';
import 'notiflow_lifecycle.dart';

class NotiflowRoute<T extends NotiflowNotification> {
  final NotifMatcher matcher;
  final NotifParse parse;
  final NotiflowLifecycle lifecycle;

  NotiflowRoute({
    required this.matcher,
    required this.parse,
    required this.lifecycle,
  });
}
