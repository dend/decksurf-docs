# December 2024 (Batch 2) Regular Cadence Update

Release version: `0.0.5`

Release date: `12/26/2024`

## Changelog

- Added bespoke support for Stream Deck Mini (including the updated version), Stream Deck Original (as well as its 2019 refresh), Stream Deck Neo, and Stream Deck MK.2. Additional testing is needed for those devices to ensure that they work as expected.
- Connected device metadata now includes **serial numbers** to make sure that devices can be differentiated by a value other than the index.
- Updated the path for the configuration in `ConfigurationHelper`.

## Installing package

You can see the package [on NuGet](https://www.nuget.org/packages/DeckSurf.SDK/).

```powershell
Install-Package DeckSurf.SDK -Version 0.0.5
```
