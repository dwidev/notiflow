<div align="center">

# 🔔 NotiFlow

**Notification Runtime Framework for Flutter**

_Handle. Observe. Debug. Dispatch._

<p>
  <a href="https://pub.dev/packages/notiflow"><img alt="pub version" src="https://img.shields.io/badge/pub-v0.1.0-blue" /></a>
  <img alt="platform" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-02569B" />
  <img alt="dart" src="https://img.shields.io/badge/Dart-%5E3.3.0-0175C2" />
  <img alt="license" src="https://img.shields.io/badge/license-MIT-green" />
</p>

</div>

---

Pernah debug notifikasi yang tidak berfungsi dan tidak tahu kenapa?

```
❌ ChatNotification   12:34:05
   ├─ ✅ Received     firebase/background
   ├─ ✅ Parsed       ChatNotification(chatId: '123')
   ├─ ✅ Matched
   ├─ ⛔ AuthMiddleware  STOPPED
   │     reason: token_expired
   └─ ⬜ Handler: skipped
```

NotiFlow punya **Inspector** — lihat exactly apa yang terjadi dengan setiap notifikasi. Bug yang biasanya butuh berjam-jam untuk di-reproduce, ketemu dalam hitungan detik.

---

## Installation

```yaml
dependencies:
  notiflow: ^0.1.0
```

> Zero external dependencies — NotiFlow hanya butuh `flutter`. Provider (Firebase, OneSignal, dll) tetap di `pubspec.yaml` kamu.

---

## Quick Start

```dart
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure
  Notiflow.instance
    .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
    .addMiddleware(LoggingMiddleware())
    .addMiddleware(DeduplicationMiddleware())
    .register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser:  ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

  // 2. Bridge your provider
  FirebaseMessaging.onMessage.listen((message) {
    Notiflow.instance.dispatch(NotificationEvent(
      source:  NotificationSource.firebase,
      state:   NotificationState.foreground,
      payload: message.data,
    ));
  });

  runApp(MyApp());
}
```

Selesai. NotiFlow match event → parse ke `ChatNotification` → panggil `onForeground()`.

---

## How It Works

```
Provider (Firebase / OneSignal / Local / Custom)
    │
    ▼  dispatch()
NotificationEvent          ← satu model untuk semua provider
    │
    ▼
Middleware Pipeline        ← logging, dedup, auth guard, dll
    │
    ▼
Matcher                    ← cari handler yang cocok
    │
    ▼
Parser                     ← raw payload → typed notification
    │
    ▼
Handler                    ← onForeground / onOpened / onLaunch
    │
    ▼
Navigator                  ← navigate ke halaman yang tepat
```

---

## Core Concepts

### Typed Notification

```dart
class ChatNotification extends NotiflowNotification {
  final String chatId;
  final String senderName;

  const ChatNotification({
    required super.id,
    required super.receivedAt,
    required super.source,
    required super.rawData,
    required this.chatId,
    required this.senderName,
  });
}
```

### Parser

Validasi dan konversi raw payload ke typed object. Error di sini di-capture Inspector — tidak crash app.

```dart
class ChatNotificationParser extends NotiflowParser<ChatNotification> {
  @override
  ChatNotification parse(NotificationEvent event) {
    final chatId = event.payload['chat_id'];

    if (chatId is! String || chatId.isEmpty) {
      throw NotiflowParseException(
        message: 'chat_id is required',
        payload: event.payload,
      );
    }

    return ChatNotification(
      id:         event.id,
      receivedAt: event.receivedAt,
      source:     event.source,
      rawData:    event.payload,
      chatId:     chatId,
      senderName: event.payload['sender_name'] as String? ?? 'Unknown',
    );
  }
}
```

### Handler

Tiga state yang tidak bisa terlewat — `onForeground`, `onOpened`, `onLaunch` semuanya abstract. Kalau salah satu tidak diimplementasi, compile error.

```dart
class ChatNotificationHandler extends NotiflowHandler<ChatNotification> {
  @override
  Future<void> onForeground(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // App aktif — tampilkan banner, update badge
  }

  @override
  Future<void> onOpened(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await navigator.navigateTo('/chat', arguments: notification.chatId);
  }

  @override
  Future<void> onLaunch(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // App baru dibuka — delay kecil agar app siap
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await navigator.navigateTo('/chat', arguments: notification.chatId);
  }
}
```

---

## Middleware

Dieksekusi berurutan sebelum handler. Bisa pass, modifikasi event, atau **stop** pipeline.

```dart
Notiflow.instance
  .addMiddleware(LoggingMiddleware())
  .addMiddleware(DeduplicationMiddleware())
  .addMiddleware(AuthGuardMiddleware());
```

**Custom middleware:**

```dart
class AuthGuardMiddleware extends NotiflowMiddleware {
  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) async {
    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!isLoggedIn) {
      return const MiddlewareStop(reason: 'user_not_authenticated');
    }
    return next(event);
  }
}
```

**Built-in:**

| Middleware                | Fungsi                                               |
| ------------------------- | ---------------------------------------------------- |
| `LoggingMiddleware`       | Log semua event dan durasi pipeline                  |
| `DeduplicationMiddleware` | Blok event duplikat (ring buffer)                    |
| `AnalyticsMiddleware`     | Track ke analytics provider kamu                     |
| `QueueMiddleware`         | Tahan event sampai app siap, flush dengan `.ready()` |

---

## Navigator

**Navigator 1.0 (bawaan):**

```dart
Notiflow.instance.setNavigator(
  NavigatorKeyAdapter(navigatorKey: navigatorKey),
);
```

**GoRouter / AutoRoute / Custom:**

Implementasi `NotiflowNavigatorAdapter` untuk navigation library apapun. Contoh siap pakai ada di cookbook:

- [GoRouter Adapter](doc/cookbook/go_router_adapter.md)
- [AutoRoute Adapter](doc/cookbook/auto_route_adapter.md)

---

## Provider Integration

NotiFlow tidak wrap provider — kamu yang tulis bridge-nya. Sekitar 15 baris per provider, fully transparent, fully yours.

**Firebase:**

```dart
// Foreground
FirebaseMessaging.onMessage.listen((message) {
  Notiflow.instance.dispatch(NotificationEvent(
    source:  NotificationSource.firebase,
    state:   NotificationState.foreground,
    payload: message.data,
  ));
});

// Background
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  Notiflow.instance.dispatch(NotificationEvent(
    source:  NotificationSource.firebase,
    state:   NotificationState.background,
    payload: message.data,
  ));
});

// Terminated
final initial = await FirebaseMessaging.instance.getInitialMessage();
if (initial != null) {
  Notiflow.instance.dispatch(NotificationEvent(
    source:  NotificationSource.firebase,
    state:   NotificationState.launch,
    payload: initial.data,
  ));
}
```

Matcher kamu yang menentukan logic-nya — NotiFlow tidak pernah mengasumsikan struktur payload. Pakai field `type`, `action`, `screen`, nested object, atau apapun yang backend kamu gunakan.

Cookbook lengkap:

- [Firebase](doc/cookbook/firebase_integration.md)
- [OneSignal](doc/cookbook/onesignal_integration.md)
- [Local Notification](doc/cookbook/local_notification_integration.md)

---

## Inspector

> 🚧 Coming in v0.2.0

```dart
Notiflow.instance.showInspector();
```

Overlay debug yang menampilkan trace lengkap setiap notifikasi — source, state, hasil parsing, setiap middleware yang dilewati, dan hasil navigasi. Zero overhead di production.

---

## Testing

`Notiflow.create()` memberi isolated instance — tidak butuh Firebase, tidak butuh mock platform channel.

```dart
test('routes chat notification correctly', () async {
  final notiflow  = Notiflow.create();
  final navigator = MockNavigator();

  notiflow
    .setNavigator(navigator)
    .register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser:  ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

  await notiflow.dispatch(NotificationEvent(
    source:  NotificationSource.firebase,
    state:   NotificationState.background,
    payload: {'type': 'chat', 'chat_id': 'room-1', 'sender_name': 'Budi'},
  ));

  expect(navigator.lastRoute, equals('/chat'));
});
```

---

## Why NotiFlow?

|                             | Tanpa NotiFlow                   | Dengan NotiFlow                              |
| --------------------------- | -------------------------------- | -------------------------------------------- |
| Tambah tipe notifikasi baru | Edit file yang ada, risiko break | File baru, register — tidak sentuh yang lama |
| Bug routing terdeteksi      | Saat QA atau production          | Saat compile (type safety)                   |
| Unit test routing           | Hampir mustahil                  | Trivial — `Notiflow.create()`                |
| Handle 3 app state          | Mudah terlewat                   | Tidak bisa terlewat — abstract method        |
| Multi-provider              | Setup berbeda tiap provider      | Satu `dispatch()` untuk semua                |
| Debug notifikasi gagal      | `print()` dan pray               | `showInspector()`                            |
| Ganti navigation library    | Ubah semua handler               | Ganti satu adapter                           |

---

## Roadmap

| Version    | Scope                                                               |
| ---------- | ------------------------------------------------------------------- |
| **v0.1.0** | Core engine, middleware pipeline, `NavigatorKeyAdapter`, unit tests |
| **v0.2.0** | Inspector built-in, cookbook lengkap, extension helpers             |
| **v0.3.0** | `AuthMiddleware`, `RetryMiddleware`, Inspector JSON export          |
| **v1.0.0** | API freeze, dokumentasi lengkap, DevTools extension                 |

---

## License

[MIT](LICENSE)

---

<div align="center">

**NotiFlow** — _Handle. Observe. Debug. Dispatch._

_Single package. Full transparency. Zero magic._

</div>
