<h1 align="center">
  <a href="https://ebos.net" target="_blank"><img src="images/github-banner.png" alt="Eb" width="800"></a>
</h1>
  <p align="center">
    <a href="https://github.com/EBOS/EBOS/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/ebos-os/ebos?style=for-the-badge&logo=github&color=1A91FF"/></a>
    <a href="https://github.com/EBOS/EBOS/graphs/contributors"><img alt="Contributors" src="https://img.shields.io/github/contributors/ebos-os/ebos?style=for-the-badge&color=1A91FF" /></a>
    <a href="https://github.com/EBOS/EBOS/releases/latest"><img alt="Release" src="https://img.shields.io/github/release/ebos-os/ebos?style=for-the-badge&color=1A91FF" /></a>
    <a href="https://github.com/EBOS/.github/blob/main/profile/CODE_OF_CONDUCT.md"><img alt="Code of Conduct" src="https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg?style=for-the-badge&color=1A91FF" /></a>
  </p>
<p align="center">A transparent and lightweight modification to Windows, designed to optimize performance, privacy and usability.</p>

<p align="center">
  <a href="https://ebos.net" target="_blank">🌐 Website</a>
  •
  <a href="https://docs.ebos.net" target="_blank">📚 Documentation</a>
  •
  <a href="https://discord.ebos.net" target="_blank">☎️ Discord</a>
  •
  <a href="https://github.com/EBOS/EBOS/discussions" target="_blank">💬 Discussions</a>
</p>

## 📚 **Important Documentation**
- [Installation](https://docs.ebos.net/getting-started/installation/)
- [Install FAQ](https://docs.ebos.net/install-faq/removed-features/)
- [General FAQ](https://docs.ebos.net/general-faq/ebos-and-security/)
- [Contribution Guidelines](https://docs.ebos.net/contributing/contribution-guidelines/)
- [Branding](https://docs.ebos.net/branding/)

## 🤔 What is EBOS?

EBOS, or EBOS, is an open-source project that enhances Windows by conveniently applying privacy, usability, and performance optimizations, all while maintaining functionality and [customizability](https://docs.ebos.net/getting-started/post-installation/ebos-folder/general-configuration/).

## 👀 Why EBOS?
### 🔒 Enhanced Privacy
EBOS removes the majority of telemetry embedded within Windows and implements numerous group policies to minimize data collection. However, it cannot ensure privacy outside the scope of Windows, such as browsers and other third-party applications.

### 📈 Optimized Performance
EBOS strikes a balance between performance and compatibility. It implements numerous meaningful changes to improve Windows performance and responsiveness without breaking essential features. EBOS will not do tweaks for a placebo effect or marginal gains, making EBOS more stable and compatible.

### 🛡️ Security Features
Most Windows modifications remove key security features most users need to maintain a secure system. On the other hand, EBOS allows users to customize their security at their own risk while informing users about each option's [pros and cons](https://docs.ebos.net/getting-started/post-installation/ebos-folder/security/).

Some optional security features are:

- Windows Defender & SmartScreen
- Windows Update
- Automatic updates are toggleable
- CPU mitigations
- User Account Control
- Core isolation features

### ✅ Increased Usability
EBOS applies many modifications and default settings to make Windows easier to use. This includes removing commonly unneeded applications (which are reinstallable), configuring many aspects of the interface, disabling advertisements, and much more.

### 🔍 Open Source and Transparent

Unlike custom Windows ISOs, EBOS is more straightforward to audit due to the use of [AME Wizard](https://amelabs.net). AME Wizard is controlled by Playbooks, a customizable script-esque system that can perform various tasks.

Playbooks are renamed **.zip** archives, with the password [`malte`](https://docs.amelabs.net/developers/getting-started/creation.html). As they primarily consist of plain text, Playbooks enable transparency, unlike custom Windows ISOs, which have many entry points for malicious activity.

The few binaries in the Playbook are open source in our [`utilities` repository](https://github.com/EBOS/utilities), with the [hashes listed here](https://github.com/EBOS/EBOS/blob/main/src/playbook/Executables/EBOSModules/README.md).

Although the GUI is not open source for AME Wizard, AME Wizard's entire backend (called [TrustedUninstaller](https://github.com/Ameliorated-LLC/trusted-uninstaller-cli)) is open source under MIT, which contains each action used to run EBOS. The EBOS Playbook is open source under the [CC BY-SA 4.0 license](https://github.com/EBOS/EBOS/blob/main/LICENSE).

### 🔒 Legal Compliance
As EBOS doesn't redistribute a modified Windows ISO, it complies with the [Microsoft Windows Usage Terms](https://www.microsoft.com/content/dam/microsoft/usetm/documents/windows/11/oem-(pre-installed)/UseTerms_OEM_Windows_11_English.pdf). In addition, EBOS does not alter activation in Windows.

## ReviOS integration and attribution

This repository integrates the [ReviOS Playbook](https://github.com/meetrevision/playbook), which is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/). In accordance with the license, this repository is also licensed under CC BY-SA 4.0, and all credit for the ReviOS components goes to the [Revision team](https://github.com/meetrevision).

### Included playbooks

This repository contains two playbook systems that co-exist:

- **EBOS** — located under [`src/playbook/`](src/playbook/), this is the main EBOS playbook.
- **ReviOS** — located under [`src/Configuration/`](src/Configuration/), [`src/Executables/`](src/Executables/), and [`src/Images/`](src/Images/), with its own manifest at [`src/playbook.conf`](src/playbook.conf).

The EBOS playbook imports the integrated ReviOS tasks through [`src/playbook/Configuration/revios.yml`](src/playbook/Configuration/revios.yml), which runs the ReviOS tasks before the EBOS tasks. EBOS tasks run afterward and remain authoritative for any overlapping settings.

> [!WARNING]
> Component removal (such as removing Windows features or packages) is intended for a **fresh Windows installation only**. Applying component removal to an existing, in-use system can cause irreversible damage.

## 🎨 Brand kit
Want to create your own EBOS wallpaper with some original creative designs? Visit our [Branding Kit on Docs](https://docs.ebos.net/branding/) and share your creations on our [GitHub Discussions](https://github.com/EBOS/EBOS/discussions/categories/community-artwork)!

## 💙 Contributors
<a href="https://github.com/EBOS/EBOS/graphs/contributors" target="_blank"><img src="https://contrib.rocks/image?repo=EBOS/EBOS&columns=18" alt="Avatars of all contributors"></a>
