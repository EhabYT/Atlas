# EBOS + ReviOS Change Log

This document records the complete change set on `arena/01a03633-atlas` relative to the session base commit `1ed9630616b29f0c7974e8bd76a94fc06f60388c`.

## Overview

- Rebranded Atlas / AtlasOS assets, configuration, metadata, desktop folders, and module paths as **EBOS**.
- Integrated ReviOS source material and its task set into the EBOS playbook flow, with EBOS configured to run afterward for overlapping settings.
- Added optional performance, diagnostics, troubleshooting, taskbar-styling, Liquid Glass, and EB Tool desktop utilities.
- Refreshed EBOS themes, wallpapers, lock screens, and profile avatar branding.
- Updated documentation, attribution, and licensing information for the ReviOS integration.

> **Important:** The unified playbook includes destructive ReviOS package/component/service operations. Test only on a fresh Windows installation with a backup.

## Commits


## Functional Changes

### EBOS rebrand

- Renamed Atlas-branded configuration folders, desktop folders, module folders, themes, wallpaper filenames, SXSC definitions, registry paths, scripts, build metadata, and GitHub templates to EBOS equivalents.
- Changed package copyright metadata to EBOS.
- Added EBOS branding assets and updated the default profile image.

### ReviOS integration

- Fused ReviOS fully into a single EBOS playbook; the standalone ReviOS source tree and release workflows are not kept.
- Added ReviOS-compatible task files within `src/playbook/Configuration/revios/` and linked them from EBOS configuration.
- Imported ReviOS package, WinSxS, Appx, service, registry, revert, finalization, and support script tasks.
- Added collision-safe ReviOS executable aliases for file associations and OneDrive actions.
- Added attribution and CC BY-SA licensing material.

### New optional desktop tools

- Performance controls: HAGS, Game Mode, windowed-game optimizations, power throttling, app GPU preference, Auto HDR, VRR, power plans, DirectX shader-cache cleanup, storage maintenance, and diagnostics.
- Network tools: DNS controls, latency testing, DNS cache flushing, network configuration, and adapter settings.
- System tools: EB Tool installer, system-information report, battery report, Reliability Monitor, System Restore Point, Event Viewer, and Windows Memory Diagnostic.
- Interface tools: Liquid Glass effect controls, Windhawk taskbar-styling guide, and Liquid Glass taskbar preset link.

### Themes and artwork

- Added EBOS Cyan and EBOS Liquid Glass themes with matching desktop and lock-screen wallpapers.
- Replaced the EBOS desktop, lock-screen, and profile imagery with EB-focused assets.
- Updated theme identities and accent colors.

## Validation Performed

- `git diff --check`
- `yamllint` with the repository workflow’s relaxed configuration
- Static validation of imported ReviOS task-path references

## Complete File Manifest

The following is the complete Git file-status manifest relative to the base commit.

```text
```

## Publishing Status

The local branch contains the changes above. GitHub push/PR creation is currently blocked by the connected GitHub App lacking permission to update `.github/workflows/apbx.yaml`; it needs **Workflows: read/write** permission.
