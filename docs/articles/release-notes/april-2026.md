# April 2026 Major Update

Release version: `0.0.7`

Release date: `04/06/2026`

## Changelog

This is a major release that redesigns the SDK from the ground up. The target framework moves from .NET 9 to **.NET 10**, Windows-only dependencies are replaced with cross-platform alternatives, the public API surface is overhauled for correctness and ergonomics, and comprehensive test coverage is added for the first time.

### Cross-platform support

Image processing now uses [SixLabors.ImageSharp](https://github.com/SixLabors/ImageSharp) instead of `System.Drawing.Common`, which means the core SDK works on **Windows, macOS, and Linux**. Windows-only APIs (such as native HID helpers) are guarded with `[SupportedOSPlatform("windows")]` and runtime checks.

The x64 platform restriction has also been removed — the SDK now builds for **Any CPU** (ARM64, x86, etc.).

### Public API redesign

The public API surface has been significantly reworked to improve type safety and ergonomics:

- **SDK-owned types** replace `System.Drawing` types in the public surface: [`DeviceColor`](xref:DeckSurf.SDK.Models.DeviceColor), [`DeviceRotation`](xref:DeckSurf.SDK.Models.DeviceRotation), [`DeviceImageFormat`](xref:DeckSurf.SDK.Models.DeviceImageFormat), and [`TouchPoint`](xref:DeckSurf.SDK.Models.TouchPoint).
- **Custom exception hierarchy**: [`DeckSurfException`](xref:DeckSurf.SDK.Exceptions.DeckSurfException) is the base, with [`DeviceCommunicationException`](xref:DeckSurf.SDK.Exceptions.DeviceCommunicationException) (includes `IsTransient`), [`DeviceDisconnectedException`](xref:DeckSurf.SDK.Exceptions.DeviceDisconnectedException) (includes `DeviceSerial`), [`ImageProcessingException`](xref:DeckSurf.SDK.Exceptions.ImageProcessingException), and [`DeviceNotFoundException`](xref:DeckSurf.SDK.Exceptions.DeviceNotFoundException).
- **Structured error events**: [`DeviceErrorEventArgs`](xref:DeckSurf.SDK.Models.DeviceErrorEventArgs) now includes `Category`, `IsTransient`, and `RecoveryHint`.
- **[`IConnectedDevice`](xref:DeckSurf.SDK.Interfaces.IConnectedDevice) interface** for testability and mocking.
- **`IDisposable`** with a full dispose pattern on [`ConnectedDevice`](xref:DeckSurf.SDK.Models.ConnectedDevice).
- **[`DeviceWatcher`](xref:DeckSurf.SDK.Core.DeviceWatcher)** for serial-based device monitoring with connect/disconnect events.
- **[`DeviceListChangedEventArgs`](xref:DeckSurf.SDK.Models.DeviceListChangedEventArgs)** with `Added`/`Removed` deltas (replaces bare `EventHandler`).
- **[`CommandArgumentParser`](xref:DeckSurf.SDK.Util.CommandArgumentParser)** for plugin argument parsing.
- **[`DeckSurfConfiguration.LoggerFactory`](xref:DeckSurf.SDK.Core.DeckSurfConfiguration)** for optional structured logging via `Microsoft.Extensions.Logging`.
- **`DisplayName`** property on [`ConnectedDevice`](xref:DeckSurf.SDK.Models.ConnectedDevice) for UI binding.
- **`IsListening`** property to query whether a device is actively listening for button presses.
- `GetDeviceList()` now returns `IReadOnlyList<ConnectedDevice>` instead of `IEnumerable<ConnectedDevice>`.
- `SetKey`/`SetKeyColor` now return `void` (previously returned `bool` but never returned `false`).
- `StartListening()` throws `InvalidOperationException` if the device is already listening.

### Breaking naming changes

Several names have been updated for consistency:

| Old name | New name |
|---|---|
| `OnButtonPress` event | `ButtonPressed` |
| `OnDeviceDisconnected` event | `DeviceDisconnected` |
| `OnDeviceError` event | `DeviceErrorOccurred` |
| `FlipType` property | `ImageRotation` |
| `Rotate180FlipNone` enum value | `Rotate180` |
| `Rotate270FlipNone` enum value | `Rotate270` |
| `IDSCommand` interface | `IDeckSurfCommand` |
| `IDSPlugin` interface | `IDeckSurfPlugin` |
| `ImageHelpers` class | `ImageHelper` |
| `DataHelpers` class | `DataHelper` |
| `VId` property | `VendorId` |
| `ButtonEventKind.DOWN`/`UP` | `ButtonEventKind.Down`/`Up` |

### Device architecture improvements

- New intermediate base classes (`JpegButtonsDevice`, `BitmapButtonsDevice`, `ScreenDevice`) reduce duplicated device code significantly.
- `DeviceRegistry` factory replaces the previous large switch statement, and supports extensibility via `DeviceRegistry.Register()`.
- Multi-device fix: HID device lookup now matches by VID+PID+DevicePath instead of just VID+PID.
- `SetupDevice` prefers serial-based matching over index-based for stability across re-plugs.
- New lookup methods: `GetDeviceBySerial()`, `GetDeviceByPath()`, and their `TryGet*` variants.

### Error handling and reliability

- All public methods now check for disposed state and throw `ObjectDisposedException` when appropriate.
- `SetKeyColor`, `SetBrightness`, and `SetScreen` wrap I/O errors in custom exception types.
- `KeyPressCallback` handles USB disconnection gracefully — no more unhandled exceptions on device unplug.
- Race condition fix: null-check on `UnderlyingInputStream` in the read callback before calling `BeginRead`.

### Test coverage

This release adds **412 tests** (up from zero), covering value type equality, data helpers, image validation, device specs (parameterized across all 9 models), key setup headers, button kind parsing, the exception hierarchy, error event args, device registry, configuration roundtrips, input validation, and command argument parsing. Coverage thresholds are enforced at build time via coverlet.

## Installing package

You can see the package [on NuGet](https://www.nuget.org/packages/DeckSurf.SDK/).

```powershell
Install-Package DeckSurf.SDK -Version 0.0.7
```
