# HiPixel

Using my apps is also a way to [support me](https://5km.tech):

<p align="center">
  <a href="https://zipic.app"><img src="https://5km.tech/products/zipic/icon.png" width="60" height="60" alt="Zipic" style="border-radius: 12px; margin: 4px;"></a>
  <a href="https://orchard.5km.tech"><img src="https://5km.tech/products/orchard/icon.png" width="60" height="60" alt="Orchard" style="border-radius: 12px; margin: 4px;"></a>
  <a href="https://apps.apple.com/cn/app/timego-clock/id6448658165?l=en-GB&mt=12"><img src="https://5km.tech/products/timego/icon.png" width="60" height="60" alt="TimeGo Clock" style="border-radius: 12px; margin: 4px;"></a>
  <a href="https://keygengo.5km.tech"><img src="https://5km.tech/products/keygengo/icon.png" width="60" height="60" alt="KeygenGo" style="border-radius: 12px; margin: 4px;"></a>
  <a href="https://hipixel.5km.tech"><img src="https://hipixel.5km.tech/_next/image?url=%2Fappicon.png&w=256&q=75" width="60" height="60" alt="HiPixel" style="border-radius: 12px; margin: 4px;"></a>
</p>

---

<p align="center">
  <img src="HiPixel/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width="128" height="128" alt="HiPixel Logo" style="border-radius: 16px;">
</p>

<h1 align="center">HiPixel</h1>

<p align="center">
  <a href="https://github.com/yourusername/hipixel/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-AGPL%20v3-blue.svg" alt="License: AGPL v3" style="border-radius: 8px;">
  </a>
  <a href="https://developer.apple.com/swift">
    <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9" style="border-radius: 8px;">
  </a>
  <a href="https://developer.apple.com/macos">
    <img src="https://img.shields.io/badge/Platform-macOS-lightgrey.svg" alt="Platform: macOS" style="border-radius: 8px;">
  </a>
  <a href="https://developer.apple.com/macos">
    <img src="https://img.shields.io/badge/macOS-13.0%2B-brightgreen.svg" alt="macOS 13.0+" style="border-radius: 8px;">
  </a>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">中文</a>
</p>

---

## AI-Powered Image Super-Resolution for macOS

HiPixel is a native macOS application for AI-powered image super-resolution, built with SwiftUI and leveraging Upscayl's powerful AI models.

<p align="center">
  <img src="screenshot.jpeg" width="600" alt="HiPixel Screenshot" style="border-radius: 16px;">
</p>

## ✨ Features

- 🖥️ Native macOS application with SwiftUI interface
- 🎨 High-quality image upscaling using AI models
- 🚀 Fast processing with GPU acceleration
- 🖼️ Supports various image formats
- 📁 Folder monitoring for automatic processing of newly added images
- 💻 Modern, intuitive user interface

### 💡 Why HiPixel?

While [Upscayl](https://github.com/upscayl/upscayl) already offers an excellent macOS application, HiPixel was developed with specific goals in mind:

1. **Native macOS Experience**
   - Built as a native SwiftUI application while utilizing Upscayl's powerful binary tools and AI models
   - Provides a seamless, platform-native experience that feels right at home on macOS

2. **Enhanced Workflow Efficiency**
   - Streamlined interaction with drag-and-drop processing - images are processed automatically upon dropping
   - Batch processing support for handling multiple images simultaneously
   - URL Scheme support for third-party integration, enabling automation and workflow extensions
   - Folder monitoring capability that automatically processes new images added to designated folders
   - Simplified interface focusing on the most commonly used features, making the upscaling process more straightforward

HiPixel aims to complement Upscayl by offering an alternative approach focused on workflow efficiency and native macOS integration, while building upon Upscayl's excellent AI upscaling foundation.

### 🔗 URL Scheme Support

HiPixel supports URL Scheme for processing images via external applications or scripts. You can specify image processing options via URL query parameters, which will override the default settings in the app.

#### Basic URL Format

```text
hipixel://?path=/path/to/image1&path=/path/to/image2
```

#### URL Parameters

| Parameter | Type | Description | Example Values |
|-----------|------|-------------|----------------|
| `path` | String | **Required.** Path to image file(s) or folder(s). Multiple paths can be specified by repeating this parameter. | `/Users/username/Pictures/image.jpg` |
| `saveImageAs` | String | Output image format. | `PNG`, `JPG`, `WEBP`, `Original` |
| `imageScale` | Number | Upscaling factor (multiplier). | `2.0`, `4.0`, `8.0` |
| `imageCompression` | Number | Compression level (0-99). Only applies when not using Zipic compression. | `0`, `50`, `90` |
| `enableZipicCompression` | Boolean | Enable Zipic compression (requires Zipic app installed). | `true`, `false`, `1`, `0` |
| `enableSaveOutputFolder` | Boolean | Save output to a custom folder instead of the same directory as source. | `true`, `false`, `1`, `0` |
| `saveOutputFolder` | String | Custom output folder path (URL encoded). Requires `enableSaveOutputFolder=true`. | `/Users/username/Output` |
| `overwritePreviousUpscale` | Boolean | Overwrite existing upscaled images if they already exist. | `true`, `false`, `1`, `0` |
| `gpuID` | String | GPU ID to use for processing. Empty string uses default GPU. | `0`, `1`, `2` |
| `customTileSize` | Number | Custom tile size for processing. `0` uses default. | `0`, `128`, `256`, `512` |
| `customModelsFolder` | String | Custom folder path for AI models (URL encoded). | `/Users/username/Models` |
| `upscaylModel` | String | Built-in AI model to use. | `upscayl-standard-4x`, `upscayl-lite-4x`, `high-fidelity-4x`, `digital-art-4x` |
| `selectedCustomModel` | String | Custom model name to use. Conflicts with `upscaylModel` (custom model takes precedence). | `my-custom-model` |
| `doubleUpscayl` | Boolean | Enable double upscaling (upscale twice for higher resolution). | `true`, `false`, `1`, `0` |
| `enableTTA` | Boolean | Enable Test Time Augmentation for better quality (slower processing). | `true`, `false`, `1`, `0` |

#### Example Usage

**Terminal:**

```bash
# Process a single image with default settings
open "hipixel://?path=/Users/username/Pictures/image.jpg"

# Process multiple images
open "hipixel://?path=/Users/username/Pictures/image1.jpg&path=/Users/username/Pictures/image2.jpg"

# Process with custom options: 4x scale, PNG format, double upscaling enabled
open "hipixel://?path=/Users/username/Pictures/image.jpg&imageScale=4.0&saveImageAs=PNG&doubleUpscayl=true"

# Process with custom output folder and Zipic compression
open "hipixel://?path=/Users/username/Pictures/image.jpg&enableSaveOutputFolder=true&saveOutputFolder=/Users/username/Output&enableZipicCompression=true"

# Process with specific AI model and TTA enabled
open "hipixel://?path=/Users/username/Pictures/image.jpg&upscaylModel=high-fidelity-4x&enableTTA=true"
```

**AppleScript:**

```applescript
tell application "Finder"
    set selectedFiles to selection as alias list
    set urlString to "hipixel://"
    set firstFile to true
    repeat with theFile in selectedFiles
        if firstFile then
            set urlString to urlString & "?path=" & POSIX path of theFile
            set firstFile to false
        else
            set urlString to urlString & "&path=" & POSIX path of theFile
        end if
    end repeat
    -- Add processing options
    set urlString to urlString & "&imageScale=4.0&saveImageAs=PNG"
    open location urlString
end tell
```

**Shell Script:**

```bash
#!/bin/bash
# Process all images in a folder with custom settings

IMAGE_PATH="/Users/username/Pictures"
OUTPUT_FOLDER="/Users/username/Upscaled"

for image in "$IMAGE_PATH"/*.{jpg,jpeg,png}; do
    if [ -f "$image" ]; then
        open "hipixel://?path=$image&imageScale=4.0&enableSaveOutputFolder=true&saveOutputFolder=$OUTPUT_FOLDER&doubleUpscayl=true"
    fi
done
```

#### Notes

- All parameters except `path` are optional. If not specified, the app will use the default settings configured in the app preferences.
- Multiple `path` parameters can be specified to process multiple images or folders in a single call.
- Boolean values accept: `true`, `false`, `1`, `0`, `yes`, `no`, `on`, `off` (case-insensitive).
- File paths and folder paths containing special characters should be URL encoded.
- When both `upscaylModel` and `selectedCustomModel` are specified, `selectedCustomModel` takes precedence.
- If `enableSaveOutputFolder=true` but `saveOutputFolder` is not provided, the output will be saved in the same directory as the source image.

### 🚀 Installation

<p align="center">
  <a href="https://hipixel.5km.tech">
    <img src="https://img.shields.io/badge/Download-HiPixel-3498DB?style=for-the-badge&logo=apple&logoColor=white&labelColor=2C3E50" alt="Download HiPixel" style="border-radius: 8px;">
  </a>
</p>

#### Via Homebrew

```bash
brew install okooo5km/tap/hipixel
```

#### Manual Download

1. Visit [hipixel.5km.tech](https://hipixel.5km.tech) to download the latest version
2. Move HiPixel.app to your Applications folder
3. Launch HiPixel

> **Note**: HiPixel requires macOS 13.0 (Ventura) or later.

### 🛠️ Building from Source

1. Clone the repository:

```bash
git clone https://github.com/okooo5km/hipixel
cd hipixel
```

2. Open HiPixel.xcodeproj in Xcode
3. Build and run the project

### 📝 License

HiPixel is licensed under the GNU Affero General Public License v3.0 (AGPLv3). This means:

- ✅ You can use, modify, and distribute this software
- ✅ If you modify the software, you must:
  - Make your modifications available under the same license
  - Provide access to the complete source code
  - Preserve all copyright notices and attributions

This software uses Upscayl's binaries and AI models, which are also licensed under AGPLv3.

### ☕️ Support the Project

If you find HiPixel helpful, please consider supporting its development:

- ⭐️ Star the project on GitHub
- 🐛 Report bugs or suggest features
- 💝 Support via:

<p align="center">
  <a href="https://www.buymeacoffee.com/okooo5km" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
</p>

<details>
<summary>More ways to support</summary>

- 🛍️ **[One-time Support via LemonSqueezy](https://okooo5km.lemonsqueezy.com/buy/4f1e3249-2683-4000-acd4-6b05ae117b40?discount=0)**

- **WeChat Pay**

  <p>
    <img src="https://storage.5km.host/wechatpay.png" width="200" alt="WeChat Pay QR Code" style="border-radius: 16px;" />
  </p>

- **Alipay**

  <p>
    <img src="https://storage.5km.host/alipay.png" width="200" alt="Alipay QR Code" style="border-radius: 16px;" />
  </p>

</details>

Your support helps maintain and improve HiPixel!

### 👉 Recommended Tool

- **[Zipic](https://zipic.app)** - Smart image compression tool with AI optimization
  - 🔄 **Perfect Pairing**: After upscaling images with HiPixel, use Zipic for intelligent compression to reduce file size while maintaining clarity
  - 🎯 **Workflow Suggestion**: HiPixel upscaling → Zipic compression → Optimized output image
  - ✨ **Enhanced Results**: Compared to using either tool alone, combined use provides the optimal balance of quality and file size

Explore more [5KM Tech](https://5km.tech) products that bring simplicity to complex tasks.

### 🙏 Attribution

HiPixel uses the following components from [Upscayl](https://github.com/upscayl/upscayl):

- upscayl-bin - The binary tool for AI upscaling (AGPLv3)
- AI Models - The AI models for image super-resolution (AGPLv3)

Special thanks to [zaotang.xyz](https://zaotang.xyz) for designing the new application icon and main window interaction interface for HiPixel v0.2.

HiPixel also uses:

- [FSWatcher](https://github.com/okooo5km/FSWatcher) - A high-performance, Swift-native file system watcher for macOS and iOS with intelligent monitoring (MIT License)
- [Sparkle](https://github.com/sparkle-project/Sparkle) - A software update framework for macOS applications (MIT License)
- [NotchNotification](https://github.com/Lakr233/NotchNotification) - A custom notch-style notification banner for macOS (MIT License)
- [GeneralNotification](https://github.com/okooo5km/GeneralNotification) - A custom notification banner for macOS (MIT License)
