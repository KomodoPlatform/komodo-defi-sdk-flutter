<p align="center">
    <a href="https://github.com/KomodoPlatform/komodo-defi-framework" alt="Contributors">
        <img width="420" src="https://user-images.githubusercontent.com/24797699/252396802-de8f9264-8056-4430-a17d-5ecec9668dfc.png" />
    </a>
</p>

# Komodo Defi Framework SDK for Flutter

A series of Flutter packages for integrating the [Komodo DeFi Framework](https://komodoplatform.com/en/komodo-defi-framework.html) into Flutter applications. This enhances devex by handling all binary/media file fetching and reduces what previously would have taken weeks/months to build a Flutter dApp with KDF integration into a matter of days.

See the Komodo DeFi Framework source repository at [KomodoPlatform/komodo-defi-framework](https://github.com/KomodoPlatform/komodo-defi-framework) and view the demo site (source in [example](.example)) project at [https://komodo-playground.web.app](https://komodo-playground.web.app).

This project supports building for macOS (more native platforms coming soon) and the web. KDF can either be run as a local Rust binary or you can connect to a remote instance. 1-Click setup for DigitalOcean and AWS deployment is in progress.

The primary entry point ([komodo_defi_sdk](/packages/komodo_defi_sdk/README.md)) is a high-level opinionated library that provides a simple way to build cross-platform Komodo Defi Framework applications (primarily focused on wallets). This repository consists of multiple other child-packages in the [packages](.packages) folder which are orchestrated by the `komodo_defi_sdk` package.

For an unopinionated implementation which gives access to the underlying KDF methods, use the [komodo_defi_framework](packages/komodo_defi_sdk) package.

The structure for this repository is inspired by the [Flutter BLoC](https://github.com/felangel/bloc) project.

This project generally aligns itself with the guidelines and high-standard set by [Very Good Ventures](https://vgv.dev/).

TODO: Add a comprehensive README

TODO: Contribution guidelines and architecture overview
