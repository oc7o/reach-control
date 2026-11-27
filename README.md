# reach-control

Native SwiftUI ground station client for the **REACH** autonomous drone platform.

## Overview

- Reads physical gamepad / controller input via Apple's `GameController` framework (`ControllerManager.swift`)
- Streams controller inputs over gRPC (`ControllerGRPCClient.swift`) to [`reach-core`](https://github.com/oc7o/reach-core)
- Includes a lightweight Python test receiver (`test_server.py`) for local development without hardware

## Legacy Flutter Client

The original v1 Flutter ground station built with Flutter, MQTT, and `flutter_map` is preserved in git history under the [`v0.1-flutter-legacy`](../../tree/v0.1-flutter-legacy) tag.

## Related Repositories

- [`reach-core`](https://github.com/oc7o/reach-core) — Rust MAVLink ↔ gRPC bridge on the companion computer
- [`reach-proto`](https://github.com/oc7o/reach-proto) — Shared Protocol Buffers definitions
- [`reach-auto-fly`](https://github.com/oc7o/reach-auto-fly) — Archived v1 autonomous Python + computer vision stack
