import 'package:notiflow/notiflow.dart';

base class OrderNotification extends NotiflowNotification {
  const OrderNotification({
    required super.id,
    required super.receivedAt,
    required super.source,
    required super.rawData,
    required this.orderId,
    required this.status,
  });

  final String orderId;
  final String status;
}

class OrderNotificationParser extends NotiflowParser<OrderNotification> {
  @override
  OrderNotification parse(NotificationEvent event) {
    final payload = event.payload;

    return OrderNotification(
      id: event.id,
      receivedAt: event.receivedAt,
      source: event.source,
      rawData: payload,
      orderId: payload['order_id'] as String? ?? '',
      status: payload['status'] as String? ?? 'unknown',
    );
  }
}

class OrderNotificationHandler extends NotiflowHandler<OrderNotification> {
  @override
  Future<void> onForeground(
    OrderNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // Show in-app banner for order update
  }

  @override
  Future<void> onOpened(
    OrderNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await navigator.navigateTo(
      '/order',
      arguments: {'orderId': notification.orderId},
    );
  }

  @override
  Future<void> onLaunch(
    OrderNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await navigator.navigateTo(
      '/order',
      arguments: {'orderId': notification.orderId},
    );
  }
}
