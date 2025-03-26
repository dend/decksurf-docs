# December 2024 Regular Cadence Update

Release version: `0.0.4`

Release date: `12/26/2024`

## Changelog

- Re-architecting how devices are structured. Device parameters are now captured properly in device-specific classes rather than `DeviceConstants`.
- Setting the foundations for other Stream Deck models, such as Neo, Mini, and the original.
- Adding support for Stream Deck+ (including knobs and the new screen).
- Cleaning up the code from faulty logic around setting key images.
- Button presses now carry more metadata to the event handler. You can now tell what event kinds, button kinds, screen coordinates, and knob parameters are used.
- `InitializeDevice()` became `StartListening()` because it's a more explicit way to tell developers what the function does.
- Upgrading to .NET 9.

## Installing package

You can see the package [on NuGet](https://www.nuget.org/packages/DeckSurf.SDK/).

```powershell
Install-Package DeckSurf.SDK -Version 0.0.4
```
