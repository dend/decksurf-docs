# April 2026 Major Update

Release version: `0.0.7`

Release date: `04/06/2026`

## Changelog

This release is a big one - I've reworked the SDK pretty much top to bottom. .NET 9 is out, **.NET 10** is in. The Windows-only image processing bits are gone in favor of cross-platform alternatives. The public API got a proper cleanup pass. And there are now actual tests.

### Cross-platform support

I swapped out `System.Drawing.Common` for [SixLabors.ImageSharp](https://github.com/SixLabors/ImageSharp), so the SDK now works on **Windows, macOS, and Linux**. The few remaining Windows-only APIs (native HID helpers) are marked with `[SupportedOSPlatform("windows")]`.

I also dropped the x64 platform lock - builds target **Any CPU** now, so ARM64 and x86 work too.

### Public API redesign

The public API got a fairly large facelift:

- **SDK-owned types** instead of `System.Drawing` types: [`DeviceColor`](xref:DeckSurf.SDK.Models.DeviceColor), [`DeviceRotation`](xref:DeckSurf.SDK.Models.DeviceRotation), [`DeviceImageFormat`](xref:DeckSurf.SDK.Models.DeviceImageFormat), [`TouchPoint`](xref:DeckSurf.SDK.Models.TouchPoint).
- **Custom exceptions**: [`DeckSurfException`](xref:DeckSurf.SDK.Exceptions.DeckSurfException) as the base, then [`DeviceCommunicationException`](xref:DeckSurf.SDK.Exceptions.DeviceCommunicationException) (with `IsTransient`), [`DeviceDisconnectedException`](xref:DeckSurf.SDK.Exceptions.DeviceDisconnectedException) (with `DeviceSerial`), [`ImageProcessingException`](xref:DeckSurf.SDK.Exceptions.ImageProcessingException), and [`DeviceNotFoundException`](xref:DeckSurf.SDK.Exceptions.DeviceNotFoundException).
- [`DeviceErrorEventArgs`](xref:DeckSurf.SDK.Models.DeviceErrorEventArgs) with `Category`, `IsTransient`, and `RecoveryHint` fields so you can actually tell what went wrong.
- [`IConnectedDevice`](xref:DeckSurf.SDK.Interfaces.IConnectedDevice) interface if you need to mock devices in your own tests.
- `IDisposable` on [`ConnectedDevice`](xref:DeckSurf.SDK.Models.ConnectedDevice) with a proper dispose pattern.
- [`DeviceWatcher`](xref:DeckSurf.SDK.Core.DeviceWatcher) - monitors for device connect/disconnect by serial number.
- [`DeviceListChangedEventArgs`](xref:DeckSurf.SDK.Models.DeviceListChangedEventArgs) gives you `Added`/`Removed` deltas instead of a bare `EventHandler`.
- [`CommandArgumentParser`](xref:DeckSurf.SDK.Util.CommandArgumentParser) for parsing plugin arguments.
- [`DeckSurfConfiguration.LoggerFactory`](xref:DeckSurf.SDK.Core.DeckSurfConfiguration) - plug in `Microsoft.Extensions.Logging` if you want structured logs.
- `DisplayName` on [`ConnectedDevice`](xref:DeckSurf.SDK.Models.ConnectedDevice) for when you need something UI-friendly.
- `IsListening` property so you can check if a device is already listening.
- `GetDeviceList()` returns `IReadOnlyList<ConnectedDevice>` now (was `IEnumerable<ConnectedDevice>`).
- `SetKey`/`SetKeyColor` return `void` - they returned `bool` before but never actually returned `false`, so that was misleading.
- `StartListening()` throws `InvalidOperationException` if you call it on a device that's already listening.

### Breaking naming changes

I renamed a bunch of things to be more consistent. Here's the full list:

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

### Device architecture

- New base classes (`JpegButtonsDevice`, `BitmapButtonsDevice`, `ScreenDevice`) cut out a lot of copy-pasted code across device implementations.
- `DeviceRegistry` factory replaces the old switch statement, and you can register your own device types with `DeviceRegistry.Register()`.
- Fixed a bug where having multiple Stream Decks connected could mix up devices - HID lookup now matches by VID+PID+DevicePath, not just VID+PID.
- `SetupDevice` tries to match by serial number first, then falls back to index. Serials are stable across re-plugs, indices are not.
- Added `GetDeviceBySerial()`, `GetDeviceByPath()`, and `TryGet*` variants for each.

### Error handling

- Public methods check for disposed state and throw `ObjectDisposedException`.
- `SetKeyColor`, `SetBrightness`, `SetScreen` wrap I/O errors in the new exception types.
- Unplugging a device mid-listen no longer crashes - `KeyPressCallback` catches the disconnection and fires the `DeviceDisconnected` event instead.
- Fixed a race condition where `UnderlyingInputStream` could be null by the time `BeginRead` was called in the callback.

### Tests

There are now **412 tests** where there were none before. They cover value type equality, data helpers, image validation, device specs across all 9 supported models, key setup headers, button kind parsing, the exception hierarchy, error event args, the device registry, configuration roundtrips, input validation, and command argument parsing. Coverage is enforced at build time with coverlet.

## Installing package

You can see the package [on NuGet](https://www.nuget.org/packages/DeckSurf.SDK/).

```powershell
Install-Package DeckSurf.SDK -Version 0.0.7
```
