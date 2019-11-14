# Application Icons for Microsoft Intune

[![License][license-badge]][license]
[![Build status][appveyor-badge]][appveyor-build]

A set of application icons for Windows, macOS, Android and iOS platforms for use when adding applications to Intune (or other MDM and application deployment solutions).

Applications are displayed in the Intune Company Portal app or at [https://portal.manage.microsoft.com/](https://portal.manage.microsoft.com/) for end-user self-service install. Using high quality product icons ensures users see a familiar interface when accessing these applications.

Icons have been added in their largest size and best possible quality. All icons have been optimised for size using PNGCrush or PNGOUT. Icons are optimised and coverted to PNG format by scripts run by AppVeyor builds. All non-PNG files are then removed from the icons folder in the repository and pushed back to GitHub.

![Icons](https://raw.githubusercontent.com/Insentra/intune-icons/master/icons.png)

## License

While the repository is licensed with an MIT license, the icons themselves remain the property of their respective software vendors.

[appveyor-badge]: https://img.shields.io/appveyor/ci/aaronparker/intune-icons/master.svg?style=flat-square&logo=appveyor
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/intune-icons
[license-badge]: https://img.shields.io/github/license/insentra/intune-icons.svg?style=flat-square
[license]: https://github.com/insentra/intune-icons/blob/master/LICENSE
