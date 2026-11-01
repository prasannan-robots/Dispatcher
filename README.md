# Dispatcher — Ground System

A tactical dispatch display for tracking handsets (radios / walkie-talkies) in the field. It
plots each unit on a map with its call sign, link type (VHF / satellite / GSM) and status, and
connects to a base station over **USB serial** or **Bluetooth** to receive live position and
telemetry data.

Built to pair with the DMR828 / walkie-talkie firmware projects.

## Features

- Live tactical map (flutter_map) with per-handset markers and info popups.
- Team roster with connection status and link type.
- USB serial and Bluetooth serial connectivity (with a web stub so the UI still runs in a browser).
- Settings for display and connection options.

## Run

```bash
flutter pub get
flutter run            # Android/desktop for real USB/Bluetooth; web for the UI only
flutter build apk
```

Serial/Bluetooth need a real device; on web those services are stubbed out.
