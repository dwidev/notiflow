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
  else if (type == 'payment') { /* ... */ }
  // keeps growing forever...
});
```

Modern apps make it worse — Firebase for push, OneSignal for marketing, local notifications for reminders — each with different APIs, different lifecycles, and zero shared abstractions.

**NotiFlow was built to solve this.** It's a runtime framework that sits between *any* notification provider and your app logic. You register typed handlers, plug in a middleware pipeline, and let NotiFlow take care of routing, parsing, lifecycle management, and observability — all without coupling your app to a single provider.

> NotiFlow is **not** a Firebase wrapper. It's **not** a push notification router.
> It's the **Notification Runtime Framework** that Flutter has been missing.

---

## ✨ Features

| Feature | Description |
|---|---|
| **Provider Agnostic** | Works with Firebase, OneSignal, local notifications, or any custom provider. |
| **Typed Notifications** | Raw payloads become compile-time safe Dart models. No more `payload['key']` typos. |
| **Lifecycle Handlers** | Dedicated callbacks for `foreground`, `opened` (background), and `launch` (terminated). |
| **Middleware Pipeline** | Logging, analytics, dedup, auth guards, queuing — chainable, ordered, with sealed results. |
| **Navigator Abstraction** | Handlers navigate without `BuildContext`. Swap Navigator 1.0, GoRouter, or AutoRoute with one adapter. |
| **High Performance** | Pre-built middleware chain (zero alloc dispatch), O(1) type-cache registry, ring buffer dedup, object pool. |
| **Interface-Based** | Your code depends on `INotiFlow`, never on internals. Swap implementations freely. |
| **Plugin Ecosystem** | Headless Mode for full control, Plugin Mode for zero-boilerplate setup. Mix both. |
| **Testable** | `NotiFlow.create()` gives isolated instances — no Firebase mocks needed. |
| **Inspector** *(roadmap)* | Real-time overlay UI showing middleware traces, handler results, and notification history. |

---

## 📦 Installation

Add NotiFlow to your `pubspec.yaml`:

```yaml
dependencies:
  notiflow: ^0.0.1
```

```bash
flutter pub get
```

Import it:

```dart
import 'package:notiflow/notiflow.dart';
```

> **Zero external dependencies.** NotiFlow core depends only on `flutter` — nothing else.

---

## 🚀 Quick Start

Get running in **under 5 minutes**. Three steps: create a navigator key, configure NotiFlow, dispatch events.

```dart
import 'package:flutter/material.dart';
import 'package:notiflow/notiflow.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Configure NotiFlow
  NotiFlow.instance
    .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
    .addMiddleware(LoggingMiddleware(tag: 'NotiFlow'))
    .addMiddleware(DeduplicationMiddleware())
    .register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser: ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/': (_) => const HomePage(),
        '/chat': (_) => const ChatPage(),
      },
    );
  }
}
```

```dart
// 2️⃣ Dispatch from any provider
await NotiFlow.instance.dispatch(
  NotificationEvent(
    source: NotificationSource.firebase,
    state: NotificationState.background,
    payload: {
      'type': 'chat',
      'chat_id': 'room-123',
      'sender_name': 'Aisha',
    },
  ),
);
```

That's it. NotiFlow matches the event → parses it into `ChatNotification` → calls `onOpened()` on the handler → navigates to `/chat`.

---

## 🧠 Core Concepts

NotiFlow's architecture is built around four primitives: **Events**, **Notifications**, **Parsers**, and **Handlers**.

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
  source: NotificationSource.firebase,   // where it came from
  state: NotificationState.foreground,   // app lifecycle state
  payload: message.data,                 // raw data
  metadata: {                            // optional display info
    'title': 'New message',
    'body': 'Aisha sent you a photo',
  },
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
    // App is active — show in-app banner, update badge, etc.
  }

  @override
  Future<void> onOpened(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // User tapped notification from background
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
    // App was terminated — wait for UI, then navigate
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await navigator.navigateTo(
      '/chat',
      arguments: {'chatId': notification.chatId},
    );
  }
}
```

### 5. Registration

Bind everything together with `register()`:

```dart
NotiFlow.instance.register<ChatNotification>(
  matcher: (event) => event.payload['type'] == 'chat',
  parser: ChatNotificationParser(),
  handler: ChatNotificationHandler(),
);
```

Add as many notification types as you want — each in its own file, zero coupling between them.

---

## 🔗 Middleware

Middleware runs **in order** before the handler is invoked. Each middleware can pass the event forward, modify it, perform side effects, or **stop the pipeline entirely**.

### Writing Custom Middleware

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

    return next(event); // pass to next middleware
  }
}
```

### Built-in Middleware

| Middleware | Purpose | Key Options |
|---|---|---|
| `LoggingMiddleware` | Logs every event and pipeline duration to console. | `tag`, `enableInRelease` |
| `DeduplicationMiddleware` | Prevents duplicate events using a ring buffer. | `windowDuration`, `bufferSize`, `keyExtractor` |
| `AnalyticsMiddleware` | Sends events to your analytics provider. | `onTrack` callback |
| `QueueMiddleware` | Holds events until your app is ready (auth, DB, etc.). | Call `.ready()` to flush |

### Middleware Order Matters

```dart
NotiFlow.instance
  .addMiddleware(LoggingMiddleware())        // 1. Log everything
  .addMiddleware(DeduplicationMiddleware())  // 2. Drop duplicates
  .addMiddleware(AuthGuardMiddleware())      // 3. Block if not logged in
  .addMiddleware(AnalyticsMiddleware(...));  // 4. Track to analytics
```

### QueueMiddleware — Delay Until Ready

```dart
final queueMiddleware = QueueMiddleware();

NotiFlow.instance.addMiddleware(queueMiddleware);

// Later, after auth / DB / bootstrap is complete:
await queueMiddleware.ready();
```

---

## 🧭 Navigator

NotiFlow decouples navigation from handlers via `NotiflowNavigator`. Swap your navigation library by changing **one adapter** — no handler changes needed.

### Navigator 1.0 (Built-in)

```dart
final navigatorKey = GlobalKey<NavigatorState>();

NotiFlow.instance.setNavigator(
  NavigatorKeyAdapter(navigatorKey: navigatorKey),
);

// Pass navigatorKey to MaterialApp
MaterialApp(navigatorKey: navigatorKey, /* ... */);
```

### GoRouter / AutoRoute / Custom

Implement `CustomNavigatorAdapter` for any navigation library:

```dart
class GoRouterAdapter extends CustomNavigatorAdapter {
  const GoRouterAdapter({required this.router});
  final GoRouter router;

  @override
  Future<void> navigateTo(String route, {Object? arguments}) async {
    router.go(route, extra: arguments);
  }

  @override
  Future<void> navigateAndReplace(String route, {Object? arguments}) async {
    router.replace(route, extra: arguments);
  }

  @override
  Future<void> popUntil(String route) async => router.popUntil(route);

  @override
  Future<void> pop<T>([T? result]) async => router.pop(result);

  @override
  Future<void> navigateAndClearStack(String route, {Object? arguments}) async {
    router.go(route, extra: arguments);
  }
}
```

```dart
NotiFlow.instance.setNavigator(GoRouterAdapter(router: appRouter));
```

---

## 🔌 Provider Integration

NotiFlow doesn't wrap providers — it consumes their data through `NotificationEvent`. Here's how to integrate common providers:

### Firebase Messaging

```dart
// Foreground
FirebaseMessaging.onMessage.listen((message) {
  NotiFlow.instance.dispatch(
    NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.foreground,
      payload: message.data,
      metadata: {
        'title': message.notification?.title,
        'body': message.notification?.body,
      },
    ),
  );
});

// Background (user tapped)
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  NotiFlow.instance.dispatch(
    NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.background,
      payload: message.data,
    ),
  );
});

// Terminated (app launched via notification)
final initial = await FirebaseMessaging.instance.getInitialMessage();
if (initial != null) {
  NotiFlow.instance.dispatch(
    NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.launch,
      payload: initial.data,
    ),
  );
}
```

### OneSignal

```dart
OneSignal.shared.setNotificationReceivedHandler((notif) {
  NotiFlow.instance.dispatch(
    NotificationEvent(
      source: NotificationSource.oneSignal,
      state: NotificationState.foreground,
      payload: Map<String, dynamic>.from(notif.additionalData ?? {}),
    ),
  );
});

OneSignal.shared.setNotificationOpenedHandler((result) {
  NotiFlow.instance.dispatch(
    NotificationEvent(
      source: NotificationSource.oneSignal,
      state: NotificationState.background,
      payload: Map<String, dynamic>.from(
        result.notification.additionalData ?? {},
      ),
    ),
  );
});
```

### Any Provider

As long as you can produce a `Map<String, dynamic>`, NotiFlow can handle it:

```dart
MyCustomProvider.onEvent.listen((event) {
  NotiFlow.instance.dispatch(
    NotificationEvent(
      source: NotificationSource.custom,
      state: NotificationState.foreground,
      payload: event.toMap(),
    ),
  );
});
```

---

## ⚡ Two Modes of Operation

### Headless Mode

You manually receive events from providers and call `dispatch()`. Full control, zero magic.

```dart
NotiFlow.instance
  .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
  .addMiddleware(LoggingMiddleware())
  .register<ChatNotification>(
    matcher: (event) => event.payload['type'] == 'chat',
    parser: ChatNotificationParser(),
    handler: ChatNotificationHandler(),
  );

// You handle Firebase/OneSignal/etc. yourself
FirebaseMessaging.onMessage.listen((msg) {
  NotiFlow.instance.dispatch(NotificationEvent(/* ... */));
});
```

**Best for:** existing projects, custom providers, maximum flexibility.

### Plugin Mode *(coming soon)*

Plugins auto-listen to providers — zero boilerplate setup.

```dart
await NotiFlow.instance
  .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
  .addPlugin(NotiflowFirebasePlugin(messaging: FirebaseMessaging.instance))
  .addPlugin(NotiflowInspectorPlugin())
  .addMiddleware(LoggingMiddleware())
  .register<ChatNotification>(/* ... */)
  .start(); // plugins start listening automatically
```

**Best for:** new projects, standard providers, minimal code.

### Combine Both

```dart
// Plugin for Firebase (automatic)
NotiFlow.instance.addPlugin(NotiflowFirebasePlugin(/* ... */));

// Headless for a custom WebSocket provider (manual)
myWebSocket.onNotification.listen((data) {
  NotiFlow.instance.dispatch(NotificationEvent(
    source: NotificationSource.custom,
    state: NotificationState.foreground,
    payload: data,
  ));
});

await NotiFlow.instance.start();
```

---

## 📚 API Reference

### NotiFlow Instance

```dart
// Singleton
NotiFlow.instance

// Isolated instance for testing
final notiflow = NotiFlow.create();
```

### Builder API (Fluent / Chainable)

```dart
NotiFlow.instance
  .setNavigator(navigator)                   // set navigation adapter
  .addMiddleware(middleware)                  // append middleware to pipeline
  .removeMiddleware(middleware)               // remove specific middleware
  .register<T>(                              // register notification type
    matcher: (event) => bool,
    parser: myParser,
    handler: myHandler,
  )
  .setFallbackHandler(fallbackHandler);      // handle unmatched events
```

### Dispatch & Query

```dart
await NotiFlow.instance.dispatch(event);     // process a notification event

final notification = NotiFlow.instance.resolve(event); // parse without dispatching
final count = NotiFlow.instance.registeredCount;        // number of registered types
```

### Plugin Mode

```dart
NotiFlow.instance.addPlugin(plugin);         // register a plugin
await NotiFlow.instance.start();             // install all plugins
await NotiFlow.instance.stop();              // dispose all plugins
```

### Lifecycle Management

```dart
NotiFlow.instance.reset();                   // clear all registrations, middleware, navigator
```

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Provider Layer                         │
│   Firebase   │   OneSignal   │   Local   │   Custom      │
└──────┬───────┴───────┬───────┴─────┬─────┴───────┬──────┘
       └───────────────┴─────────────┴─────────────┘
                           │
               ┌───────────▼───────────┐
               │   NotificationEvent   │   ← Unified model
               └───────────┬───────────┘
                           │
       ┌───────────────────▼───────────────────────┐
       │              INotiFlow                     │
       │                                            │
       │  ┌────────────────────────────────────┐   │
       │  │       Middleware Pipeline           │   │
       │  │  Logging → Dedup → Auth → ...      │   │
       │  │  [sealed: Continue | Stop]         │   │
       │  └──────────────┬─────────────────────┘   │
       │                 │                          │
       │  ┌──────────────▼─────────────────────┐   │
       │  │           Registry                  │   │
       │  │  matcher → parser → typed notif     │   │
       │  │  O(1) type-cache + linear fallback  │   │
       │  └──────────────┬─────────────────────┘   │
       │                 │                          │
       │  ┌──────────────▼─────────────────────┐   │
       │  │           Handler                   │   │
       │  │  onForeground / onOpened / onLaunch │   │
       │  └──────────────┬─────────────────────┘   │
       │                 │                          │
       │  ┌──────────────▼─────────────────────┐   │
       │  │       Navigator Adapter             │   │
       │  │  NavigatorKey / GoRouter / Custom    │   │
       │  └────────────────────────────────────┘   │
       └───────────────────────────────────────────┘
```

### Performance Design

| Technique | What It Does |
|---|---|
| **Pre-built Chain** | Middleware chain built once on change, not per dispatch. Zero allocation on hot path. |
| **Type-Cache Registry** | O(1) handler lookup after first encounter. Linear scan only for new types. |
| **Ring Buffer Dedup** | Fixed-size circular buffer — bounded memory, O(1) insert & lookup. |
| **Object Pool** | Reuses `_ChainNode` objects to minimize GC pressure under high notification volume. |

---

## 🧪 Testing

NotiFlow is designed for testability from day one. Use `NotiFlow.create()` for isolated instances — no Firebase, no mocks, no device.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:notiflow/notiflow.dart';

void main() {
  test('dispatches chat notification correctly', () async {
    final notiflow = NotiFlow.create();
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
        payload: {'type': 'chat', 'chat_id': 'room-1', 'sender_name': 'Aisha'},
      ),
    );

    expect(mockNavigator.lastRoute, '/chat');
  });

  test('resolve returns typed notification without dispatch', () {
    final notiflow = NotiFlow.create();

    notiflow.register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser: ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

    final event = NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.foreground,
      payload: {'type': 'chat', 'chat_id': 'room-1'},
    );

    final result = notiflow.resolve(event);
    expect(result, isA<ChatNotification>());
    expect((result as ChatNotification).chatId, 'room-1');
  });
}
```

Run tests:

```bash
flutter test
```

---

## 🗺️ Roadmap

| Version | Milestone | Scope |
|---|---|---|
| **v0.1.0** | Alpha | Core engine, Headless Mode, middleware pipeline, `NavigatorKeyAdapter`, unit tests |
| **v0.2.0** | Beta | Plugin Mode, `notiflow_firebase`, `notiflow_inspector` (overlay + history), `notiflow_go_router` |
| **v0.3.0** | — | `notiflow_auto_route`, Auth/Retry middleware, Inspector JSON export, DevTools extension alpha |
| **v1.0.0** | Stable | API freeze, all plugins stable, full documentation, pub.dev publish |
| **v1.1.0** | — | Inspector replay, performance profiling, notification grouping |

---

## 🆚 Comparison

| Aspect | Manual (without NotiFlow) | With NotiFlow |
|---|---|---|
| Add new notification type | Edit existing file, risk breaking others | New file, register — don't touch existing code |
| Routing bugs detected | At QA or production | At compile time (type safety) |
| Unit test routing logic | Nearly impossible | Trivial — `NotiFlow.create()`, no provider mocks |
| Handle 3 app states | Easy to miss one | Can't miss — abstract methods enforce all three |
| Multi-provider support | Different setup per provider, duplicated logic | One `dispatch()` for all |
| Debug failed notifications | `print()` and pray | Inspector UI + history *(coming soon)* |
| Log all notifications | Copy-paste in every handler | `addMiddleware(LoggingMiddleware())` — one line |
| Onboard new developer | Read 300+ lines of spaghetti | Read one handler — understand everything |
| Swap navigation library | Rewrite every handler | Change one adapter |
| Swap notification provider | Major refactor | Change one plugin |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

---

## 📄 License

NotiFlow is released under the [MIT License](LICENSE).

---

<div align="center">

**NotiFlow** — *Handle. Observe. Debug. Dispatch.*

Built with ❤️ for the Flutter community.

</div>
