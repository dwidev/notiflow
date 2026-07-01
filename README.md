<div align="center">

# 🔔 NotiFlow

**Notification Runtime Framework for Flutter**

Handle. Observe. Debug. Dispatch.

The missing runtime layer between your notification provider and your Flutter app.

<p>
  <a href="https://pub.dev/packages/notiflow"><img alt="pub version" src="https://img.shields.io/badge/pub-v0.0.1-blue" /></a>
  <a href="https://pub.dev/packages/notiflow/score"><img alt="pub points" src="https://img.shields.io/badge/points-140%2F160-brightgreen" /></a>
  <img alt="platform" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-02569B" />
  <img alt="dart" src="https://img.shields.io/badge/Dart-%5E3.12.2-0175C2" />
  <img alt="license" src="https://img.shields.io/badge/license-MIT-green" />
</p>

<p>
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-core-concepts">Core Concepts</a> •
  <a href="#-middleware">Middleware</a> •
  <a href="#-navigator">Navigator</a> •
  <a href="#-provider-integration">Providers</a> •
  <a href="#-api-reference">API</a> •
  <a href="#-testing">Testing</a>
</p>

_Single package. Full transparency. Zero magic._

</div>

---

## 📖 Background

Every Flutter developer who has integrated push notifications has written the same code: a giant `if-else` block inside `onMessageOpenedApp`, growing to 300+ lines after a year, untestable, and terrifying to refactor.

```dart
// ❌ This lives in every Flutter app — and nobody dares to touch it
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final type = message.data['type'];
  if (type == 'chat') {
    Navigator.pushNamed(context, '/chat', arguments: message.data['chat_id']);
  } else if (type == 'order') {
    Navigator.pushNamed(context, '/order', arguments: message.data['order_id']);
  } else if (type == 'promo') { /* ... */ }
  // keeps growing forever...
});
```

Modern apps make it worse — Firebase for push, OneSignal for marketing, local notifications for reminders — each with different APIs, different lifecycles, and zero shared abstractions.

**NotiFlow was built to solve this.** It's a runtime framework that sits between _any_ notification provider and your app logic. You register typed handlers, plug in a middleware pipeline, and let NotiFlow take care of routing, parsing, lifecycle management, and observability.

NotiFlow follows the **Alice Model** — like [Alice](https://pub.dev/packages/alice) opened HTTP inspection with one instance and one interceptor pattern, NotiFlow opens notification handling with one instance and one `dispatch()` call. No plugins, no black boxes, no magic.

> **One package. You write the bridge. NotiFlow handles the rest.**

---

## ✨ Features

| Feature                   | Description                                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------------------------ |
| **Provider Agnostic**     | Works with Firebase, OneSignal, local notifications, or any custom provider.                           |
| **Typed Notifications**   | Raw payloads become compile-time safe Dart models. No more `payload['key']` typos.                     |
| **Lifecycle Handlers**    | Dedicated callbacks for `foreground`, `opened` (background), and `launch` (terminated).                |
| **Middleware Pipeline**   | Logging, analytics, dedup, auth guards, queuing — chainable, ordered, with sealed results.             |
| **Navigator Abstraction** | Handlers navigate without `BuildContext`. Swap Navigator 1.0, GoRouter, or AutoRoute with one adapter. |
| **High Performance**      | Pre-built middleware chain (zero alloc dispatch), O(1) type-cache registry, ring buffer dedup.         |
| **Interface-Based**       | Your code depends on `Notiflow`, never on internals.                                                   |
| **Full Transparency**     | No plugin magic. Every provider integration is code you write, read, and control.                      |
| **Inspector** _(v0.2.0)_  | Built-in debug overlay — `Notiflow.instance.showInspector()` — like Alice for notifications.           |
| **Testable**              | `Notiflow.create()` gives isolated instances — no Firebase mocks needed.                               |

---

## 📦 Installation

```yaml
dependencies:
  notiflow: ^0.0.1
```

```bash
flutter pub get
```

```dart
import 'package:notiflow/notiflow.dart';
```

> **Zero external dependencies.** NotiFlow depends only on `flutter` — nothing else. Provider dependencies (Firebase, OneSignal, etc.) stay in _your_ `pubspec.yaml`, not ours.

---

## 🚀 Quick Start

Three steps: create a navigator key, configure NotiFlow, bridge your provider.

```dart
import 'package:flutter/material.dart';
import 'package:notiflow/notiflow.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Configure NotiFlow
  Notiflow.instance
    .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
    .addMiddleware(LoggingMiddleware(tag: 'NotiFlow'))
    .addMiddleware(DeduplicationMiddleware())
    .register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser: ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

  // 2️⃣ Bridge your provider — manual, transparent
  FirebaseMessaging.onMessage.listen((message) {
    Notiflow.instance.dispatch(NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.foreground,
      payload: message.data,
    ));
  });

  runApp(const MyApp());
}
```

That's it. NotiFlow matches the event → parses it into `ChatNotification` → calls `onForeground()` on the handler.

---

## 🧠 Core Concepts

```
Provider (Firebase, OneSignal, etc.)
    │
    ▼
NotificationEvent          ← unified model, provider-agnostic
    │
    ▼
Middleware Pipeline        ← logging, dedup, auth guard, etc.
    │
    ▼
Registry (matcher)         ← finds the right handler
    │
    ▼
Parser                     ← raw payload → typed notification
    │
    ▼
Handler                    ← onForeground / onOpened / onLaunch
    │
    ▼
Navigator                  ← route to the right screen
```

### 1. NotificationEvent

The unified entry point. Every provider's data gets converted into this single model.

```dart
NotificationEvent(
  source: NotificationSource.firebase,
  state: NotificationState.foreground,
  payload: message.data,
  metadata: {'title': 'New message', 'body': 'Aisha sent a photo'},
);
```

### 2. Typed Notification

Extend `NotiflowNotification` to create domain-specific models with compile-time safety.

```dart
class ChatNotification extends NotiflowNotification {
  const ChatNotification({
    required super.id,
    required super.receivedAt,
    required super.source,
    required super.rawData,
    required this.chatId,
    required this.senderName,
  });

  final String chatId;
  final String senderName;
}
```

### 3. Parser

Transforms a raw `NotificationEvent` into your typed notification. Validation happens here.

```dart
class ChatNotificationParser extends NotiflowParser<ChatNotification> {
  @override
  ChatNotification parse(NotificationEvent event) {
    final payload = event.payload;
    final chatId = payload['chat_id'];

    if (chatId is! String || chatId.isEmpty) {
      throw NotiflowParseException(
        message: 'chat_id is required',
        payload: payload,
      );
    }

    return ChatNotification(
      id: event.id,
      receivedAt: event.receivedAt,
      source: event.source,
      rawData: payload,
      chatId: chatId,
      senderName: payload['sender_name'] as String? ?? 'Unknown',
    );
  }
}
```

### 4. Handler

Defines what your app does for each notification lifecycle state. All three methods are required — you can never accidentally miss a state.

```dart
class ChatNotificationHandler extends NotiflowHandler<ChatNotification> {
  @override
  Future<void> onForeground(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // App is active — show in-app banner, update badge
  }

  @override
  Future<void> onOpened(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await navigator.navigateTo(
      '/chat',
      arguments: {'chatId': notification.chatId},
    );
  }

  @override
  Future<void> onLaunch(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await navigator.navigateTo(
      '/chat',
      arguments: {'chatId': notification.chatId},
    );
  }
}
```

### 5. Registration

```dart
Notiflow.instance.register<ChatNotification>(
  matcher: (event) => event.payload['type'] == 'chat',
  parser: ChatNotificationParser(),
  handler: ChatNotificationHandler(),
);
```

Add as many notification types as you want — each in its own file, zero coupling.

---

## 🔗 Middleware

Middleware runs **in order** before the handler. Each middleware can pass, modify, side-effect, or **stop** the pipeline.

### Custom Middleware

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

### Built-in Middleware

| Middleware                | Purpose                                                    |
| ------------------------- | ---------------------------------------------------------- |
| `LoggingMiddleware`       | Logs every event and pipeline duration.                    |
| `DeduplicationMiddleware` | Prevents duplicate events (ring buffer).                   |
| `AnalyticsMiddleware`     | Sends events to your analytics provider.                   |
| `QueueMiddleware`         | Holds events until app is ready. Call `.ready()` to flush. |

---

## 🧭 Navigator

### Navigator 1.0 (Built-in)

```dart
final navigatorKey = GlobalKey<NavigatorState>();
Notiflow.instance.setNavigator(
  NavigatorKeyAdapter(navigatorKey: navigatorKey),
);
```

### GoRouter / AutoRoute / Custom

Copy the adapter from the cookbook — no extra dependency needed:

- [GoRouter Adapter](doc/cookbook/go_router_adapter.md)
- [AutoRoute Adapter](doc/cookbook/auto_route_adapter.md)

Or implement `NotiflowNavigatorAdapter` yourself for any navigation library.

---

## 🔌 Provider Integration

NotiFlow doesn't wrap providers — you write the bridge. It's ~15 lines per provider, fully transparent, fully yours.

### Firebase Messaging

```dart
// Foreground
FirebaseMessaging.onMessage.listen((message) {
  Notiflow.instance.dispatch(NotificationEvent(
    source: NotificationSource.firebase,
    state: NotificationState.foreground,
    payload: message.data,
  ));
});

// Background (user tapped)
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  Notiflow.instance.dispatch(NotificationEvent(
    source: NotificationSource.firebase,
    state: NotificationState.background,
    payload: message.data,
  ));
});

// Terminated (app launched via notification)
final initial = await FirebaseMessaging.instance.getInitialMessage();
if (initial != null) {
  Notiflow.instance.dispatch(NotificationEvent(
    source: NotificationSource.firebase,
    state: NotificationState.launch,
    payload: initial.data,
  ));
}
```

### Extension Method (optional shorthand)

```dart
FirebaseMessaging.onMessage.listen((message) {
  Notiflow.instance.dispatch(
    message.data.toNotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.foreground,
    ),
  );
});
```

### More Providers

Full copy-paste recipes in the cookbook:

- [Firebase Integration](doc/cookbook/firebase_integration.md)
- [OneSignal Integration](doc/cookbook/onesignal_integration.md)
- [Local Notification Integration](doc/cookbook/local_notification_integration.md)

---

## 📚 API Reference

```dart
// Singleton
Notiflow.instance

// Isolated instance for testing
final notiflow = Notiflow.create();
```

### Builder API

```dart
Notiflow.instance
  .setNavigator(navigator)
  .addMiddleware(middleware)
  .removeMiddleware(middleware)
  .register<T>(matcher: ..., parser: ..., handler: ...)
  .setFallbackHandler(fallbackHandler);
```

### Dispatch & Query

```dart
await Notiflow.instance.dispatch(event);

final notification = Notiflow.instance.resolve(event);
final count = Notiflow.instance.registeredCount;

Notiflow.instance.reset();
```

### Inspector

```dart
Notiflow.instance.showInspector(); // debug overlay, like Alice
```

---

## 🧪 Testing

Use `Notiflow.create()` for isolated instances — no Firebase, no mocks, no device.

```dart
test('dispatches chat notification correctly', () async {
  final notiflow = Notiflow.create();
  final mockNavigator = MockNavigator();

  notiflow
    .setNavigator(mockNavigator)
    .register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser: ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

  await notiflow.dispatch(
    NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.background,
      payload: {'type': 'chat', 'chat_id': 'room-1'},
    ),
  );

  expect(mockNavigator.lastRoute, '/chat');
});
```

```bash
flutter test
```

---

## 🗺️ Roadmap

| Version    | Scope                                                                       |
| ---------- | --------------------------------------------------------------------------- |
| **v0.1.0** | Core engine, middleware pipeline, `NavigatorKeyAdapter`, unit tests         |
| **v0.2.0** | Inspector built-in (overlay + history), cookbook lengkap, extension helpers |
| **v0.3.0** | AuthMiddleware, RetryMiddleware, Inspector JSON export                      |
| **v1.0.0** | API freeze, full documentation, DevTools extension                          |

---

## 🆚 Why NotiFlow?

|                            | Manual (without NotiFlow)                | With NotiFlow                                   |
| -------------------------- | ---------------------------------------- | ----------------------------------------------- |
| Add new notification type  | Edit existing file, risk breaking others | New file, register — don't touch existing code  |
| Routing bugs detected      | At QA or production                      | At compile time (type safety)                   |
| Unit test routing logic    | Nearly impossible                        | Trivial — `Notiflow.create()`                   |
| Handle 3 app states        | Easy to miss one                         | Can't miss — abstract methods enforce all three |
| Multi-provider support     | Different setup per provider             | One `dispatch()` for all                        |
| Debug failed notifications | `print()` and pray                       | `showInspector()`                               |
| Swap navigation library    | Rewrite every handler                    | Change one adapter                              |

---

## 📄 License

NotiFlow is released under the [MIT License](LICENSE).

---

<div align="center">

**NotiFlow** — _Handle. Observe. Debug. Dispatch._

Single package. Full transparency. Zero magic.

</div>
