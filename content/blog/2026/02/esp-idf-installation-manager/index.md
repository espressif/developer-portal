---
title: "ESP-IDF Installation Manager 0.8: Streamlined Setup for ESP-IDF Development"
date: 2026-02-22
tags:
  - ESP-IDF
  - IDF-IM
  - installation
  - tooling
  - espressif
showAuthor: false
featureAsset: "featured.webp"
authors:
    - "petr-gadorek"
summary: "The ESP-IDF Installation Manager (EIM) 0.8 introduces simplified installation across Windows, macOS, and Linux through native package managers. This article covers the new release features, installation methods, offline capabilities, and headless usage for CI/CD pipelines."
---

## Introducing ESP-IDF Installation Manager 0.8

The ESP-IDF Installation Manager (EIM) is a cross-platform tool designed to simplify the installation and management of the Espressif IoT Development Framework. Version 0.8 brings significant improvements, including native package manager support for all major platforms, enhanced offline installation capabilities, and streamlined CI/CD integration.

EIM addresses a common pain point in embedded development: configuring toolchains and dependencies across different operating systems. Whether you're a developer working on a single project or part of a team requiring reproducible builds, EIM provides a consistent experience across Windows, macOS, and Linux.

## Installation Methods

EIM 0.8 offers multiple installation options to suit different workflows and preferences.

### Package Manager Installation (Recommended)

The simplest way to install EIM is through your platform's native package manager.

**Windows (winget):**

```powershell
# Install GUI version
winget install Espressif.EIM

# Install CLI version only
winget install Espressif.EIM-CLI
```

**macOS (Homebrew):**

```bash
# First add the EIM tap
brew tap espressif/eim

# Install GUI version
brew install --cask eim-gui

# Or install CLI version only
brew install eim
```

**Linux (Debian/Ubuntu):**

```bash
# Add the EIM APT repository
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | \
    sudo tee /etc/apt/sources.list.d/espressif.list

# Update package lists
sudo apt update

# Install CLI version
sudo apt install eim-cli

# Or install GUI version
sudo apt install eim
```

**Linux (Fedora/RHEL):**

```bash
# Download and install the RPM repository configuration
sudo dnf install https://dl.espressif.com/dl/eim/rpm/eim-repo-latest.noarch.rpm

# Install CLI version
sudo dnf install eim-cli

# Or install GUI version
sudo dnf install eim
```

### Portable Binary Installation

For users who prefer self-contained binaries or lack package manager access, visit the [EIM downloads page](https://dl.espressif.com/dl/eim/) for platform-specific binaries and detailed installation instructions.

## Offline Installation

For air-gapped environments, networks with restricted access, or simply when you want the fastest and most reliable installation experience, EIM supports fully offline installation through pre-built archives. Pre-packaged offline archives for every supported ESP-IDF version and platform are available at [https://dl.espressif.com/dl/eim/?tab=offline](https://dl.espressif.com/dl/eim/?tab=offline).

![Offline installation in GUI](./img/installation_methods.webp)

Download the appropriate archive for your platform and ESP-IDF version, then install using:

```bash
# Install from a downloaded archive
eim install --use-local-archive /path/to/archive.zip
```

Offline installation is also available directly through the GUI for users who prefer a visual interface.

**Why choose offline installation?**

- **Fastest method**: Skip all downloads and verification steps—everything is already included
- **Most reliable**: No network issues, no server timeouts, no corrupted downloads
- **Tested and verified**: Each archive is pre-built and tested before publication
- **Fail-safe solution**: When other installation methods encounter issues, offline archives almost always succeed
- **Recommended for mainland China**: For Windows users in mainland China, offline archives provide the most consistent experience due to network considerations

This method is particularly valuable for:
- Industrial environments with restricted network access
- CI/CD runners in private networks
- Team environments requiring consistent tool versions
- Users in regions with network connectivity challenges

## Headless and CLI Usage

EIM operates in headless (non-interactive) mode by default, making it ideal for automation and CI/CD pipelines.

For complete CLI command documentation, including installation, version management, and configuration options, see the [EIM CLI Commands Reference](https://docs.espressif.com/projects/idf-im-ui/en/latest/cli_commands.html).

## Activating ESP-IDF Environment

Traditional ESP-IDF installation methods used `install.sh` and `export.sh` scripts from the IDF repository. EIM replaces these with a modern, cross-platform approach.

### Installation is Now Simpler

The `install.sh` script from the ESP-IDF repository is no longer needed. EIM handles all toolchain and dependency installation automatically through the commands described above.

### Activation Scripts Replace export.sh

The `export.sh` script has been replaced by version-specific activation scripts. After installing ESP-IDF with EIM, activate the environment by sourcing the activation script:

```bash
# Activate a specific ESP-IDF version
source ~/.espressif/tools/activate_idf_v5.3.2.sh
```

To find the activation script path for any installed version, use:

```bash
eim select
```

This command displays all installed versions along with their activation script paths.

### Opening IDF Shell

**Windows**: EIM creates an IDF Shell shortcut on your desktop. Additionally, an IDF Shell fragment is added to the Windows Terminal shell dropdown menu for quick access.

**All Platforms**: In the EIM GUI, navigate to the Version Manager view and click "Open IDF Shell" next to the desired version to open a terminal with the ESP-IDF environment already activated.

## CI/CD Integration

### GitHub Actions

Use the official [install-esp-idf-action](https://github.com/espressif/install-esp-idf-action) for GitHub workflows:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Install ESP-IDF
    uses: espressif/install-esp-idf-action@v1
    with:
      version: "v5.0"
      path: "/custom/path/to/esp-idf"
      tools-path: "/custom/path/to/tools"
```

### Docker Integration

For Docker and containerized build environments, see the [Headless Usage documentation](https://docs.espressif.com/projects/idf-im-ui/en/latest/headless_usage.html#docker-integration) for comprehensive examples.

### Custom Repository Configuration

For organizations using modified ESP-IDF forks:

```bash
# For GitHub repositories
eim install -i v5.3.2 --repo-stub my-github-user/my-custom-idf

# For GitLab or self-hosted repositories
eim install -i v5.3.2 --mirror https://gitlab.example.com --repo-stub my-gitlab-user/my-custom-idf
```

## Version Management

EIM makes it easy to manage multiple ESP-IDF versions on a single system. Switch between versions instantly without reinstalling tools.

![Version management in GUI](img/version_management.webp)

## Documentation and Resources

- **EIM Documentation**: [https://docs.espressif.com/projects/idf-im-ui/en/latest/](https://docs.espressif.com/projects/idf-im-ui/en/latest/)
- **EIM Repository**: [https://github.com/espressif/idf-im-ui](https://github.com/espressif/idf-im-ui)
- **EIM Downloads**: [https://dl.espressif.com/dl/eim/](https://dl.espressif.com/dl/eim/)
- **ESP-IDF Documentation**: [https://docs.espressif.com/projects/esp-idf/en/latest/](https://docs.espressif.com/projects/esp-idf/en/latest/)

## Conclusion

EIM 0.8 simplifies ESP-IDF installation across all major platforms through native package managers, supports offline deployments for restricted environments, and integrates seamlessly with CI/CD pipelines. Whether you're setting up a new development machine or configuring automated builds, EIM provides a consistent and reliable installation experience.

Upgrade to EIM 0.8 today and streamline your ESP-IDF development workflow.
