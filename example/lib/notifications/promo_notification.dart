import 'package:notiflow/notiflow.dart';

base class PromoNotification extends NotiflowNotification {
  const PromoNotification({
    required super.id,
    required super.receivedAt,
    required super.source,
    required super.rawData,
    required this.promoCode,
    this.discount,
  });

  final String promoCode;
  final String? discount;
}

class PromoNotificationParser extends NotiflowParser<PromoNotification> {
  @override
  PromoNotification parse(NotificationEvent event) {
    final payload = event.payload;
    final promoCode = payload['promo_code'];

    if (promoCode is! String || promoCode.isEmpty) {
      throw NotiflowParseException(
        message: 'promo_code is required',
        payload: payload,
      );
    }

    return PromoNotification(
      id: event.id,
      receivedAt: event.receivedAt,
      source: event.source,
      rawData: payload,
      promoCode: promoCode,
      discount: payload['discount'] as String?,
    );
  }
}

class PromoNotificationHandler extends NotiflowHandler<PromoNotification> {
  @override
  Future<void> onForeground(
    PromoNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // Show promo banner
  }

  @override
  Future<void> onOpened(
    PromoNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await navigator.navigateTo(
      '/promo',
      arguments: {'promoCode': notification.promoCode},
    );
  }

  @override
  Future<void> onLaunch(
    PromoNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await navigator.navigateTo(
      '/promo',
      arguments: {'promoCode': notification.promoCode},
    );
  }
}
