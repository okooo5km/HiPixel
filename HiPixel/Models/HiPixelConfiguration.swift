//
//  Configuration.swift
//  HiPixel
//
//  Created by 十里 on 2024/6/22.
//

import SwiftUI

struct HiPixelConfiguration {

    static var shared = HiPixelConfiguration()

    enum Keys {
        static let FirstLaunch = "HIPixel-FirstLaunch"
        static let ColorScheme = "HIPixel-ColorScheme"
        static let NotificationMode = "HIPixel-NotificationMode"
        static let SaveImageAs = "HIPixel-SaveImageAs"
        static let ImageScale = "HIPixel-ImageScale"
        static let ImageCompression = "HIPixel-ImageCompression"
        static let EnableZipicCompression = "HiPixel-EnableZipicCompression"
        static let EnableSaveOutputFolder = "HIPixel-EnableSaveOutputFolder"
        static let SaveOutputFolder = "HIPixel-SaveOutputFolder"
        static let OverwritePreviousUpscale = "HIPixel-OverwritePreviousUpscale"
        static let GPUID = "HIPixel-GPUID"
        static let CustomTileSize = "HIPixel-CustomTileSize"
        static let CustomModelsFolder = "HIPixel-CustomModelsFolder"
        static let UpscaylModel = "HIPixel-UpscaylModel"
        static let UpscaylModelVersion: String = "HIPixel-UpscaylModel-Version"
        static let SelectedCustomModel = "HIPixel-SelectedCustomModel"
        static let DoubleUpscayl = "HIPixel-DoubleUpscayl"
        static let EnableTTA = "HIPixel-EnableTTA"
        static let SelectedAppIcon = "HIPixel-AppIconSelected"
        static let ManualSaveControl = "HIPixel-ManualSaveControl"
        static let HideDockIcon = "HIPixel-HideDockIcon"
        static let ShowMenuBarExtra = "HIPixel-ShowMenuBarExtra"
        static let LaunchSilently = "HIPixel-LaunchSilently"
        static let HasShownAutoSaveHint = "HIPixel-HasShownAutoSaveHint"
    }

    enum ColorScheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"

        var icon: String {
            switch self {
            case .light:
                return "sun.max.fill"
            case .dark:
                return "moon.fill"
            case .system:
                return "circle.righthalf.filled"
            }
        }

        var localized: String {
            switch self {
            case .light:
                return NSLocalizedString("Light", comment: "")
            case .dark:
                return NSLocalizedString("Dark", comment: "")
            case .system:
                return NSLocalizedString("System", comment: "")
            }
        }

        static func change(to mode: ColorScheme) {
            @AppStorage(Keys.ColorScheme)
            var colorScheme: ColorScheme = .system

            colorScheme = mode

            switch mode {
            case .light:
                NSApp.appearance = NSAppearance(named: .aqua)
            case .dark:
                NSApp.appearance = NSAppearance(named: .darkAqua)
            case .system:
                NSApp.appearance = nil
            }
        }
    }

    enum NotificationMode: Int, Codable, CaseIterable {
        case None, HiPixel, Notch, System

        var localized: String {
            switch self {
            case .None:
                return NSLocalizedString("Disable Notification", comment: "")
            case .HiPixel:
                return NSLocalizedString("HiPixel Notification", comment: "")
            case .Notch:
                return NSLocalizedString("Notch Notification", comment: "")
            case .System:
                return NSLocalizedString("System Notification", comment: "")
            }
        }
    }

    enum ImageFormat: String, Codable, CaseIterable {
        case png = "PNG"
        case jpg = "JPG"
        case webp = "WEBP"
        case original = "Original"

        var localized: String {
            switch self {
            case .png:
                return NSLocalizedString("PNG", comment: "")
            case .jpg:
                return NSLocalizedString("JPG", comment: "")
            case .webp:
                return NSLocalizedString("WEBP", comment: "")
            case .original:
                return NSLocalizedString("Original", comment: "")
            }
        }
    }

    enum UpscaylModel: String, Codable, CaseIterable {
        case Upscayl_Standard = "upscayl-standard-4x"
        case Upscayl_Lite = "upscayl-lite-4x"
        case High_Fidenlity = "high-fidelity-4x"
        case Digital_Art = "digital-art-4x"

        static let description: LocalizedStringKey = "UpscaylModel description"

        var id: String {
            self.rawValue
        }

        var text: String {
            switch self {
            case .Upscayl_Standard:
                return "Standard".localized
            case .Upscayl_Lite:
                return "Lite".localized
            case .High_Fidenlity:
                return "High Fidelity".localized
            case .Digital_Art:
                return "Digital Art".localized
            }
        }

        func isAvaliable(at directory: URL) -> Bool {
            let binURL = directory.appendingPathComponent("\(self.id).bin")
            let paramURL = directory.appendingPathComponent("\(self.id).param")
            let fileManager = FileManager.default
            return fileManager.fileExists(atPath: binURL.path) && fileManager.fileExists(atPath: paramURL.path)
        }
    }

    enum AppIcon: String, CaseIterable {
        case primary = "AppIcon"
        case secondary = "SecondaryAppIcon"

        var displayName: LocalizedStringKey {
            switch self {
            case .primary:
                return "Designed by zaotang.xyz"
            case .secondary:
                return "Designed by @okooo5km"
            }
        }

        var previewImage: NSImage? {
            NSImage(named: self.rawValue)
        }
    }

    @AppStorage(Keys.FirstLaunch)
    var firstLaunch: Bool = true

    @AppStorage(Keys.ColorScheme)
    var colorScheme: ColorScheme = .system

    @AppStorage(Keys.NotificationMode)
    var notification: NotificationMode = .HiPixel

    @AppStorage(Keys.SaveImageAs)
    var saveImageAs: ImageFormat = .original

    @AppStorage(Keys.ImageScale)
    var imageScale: Double = 4.0

    @AppStorage(Keys.ImageCompression)
    var imageCompression: Int = 0

    @AppStorage(Keys.EnableZipicCompression)
    var enableZipicCompression: Bool = false

    @AppStorage(Keys.EnableSaveOutputFolder)
    var enableSaveOutputFolder: Bool = false

    @AppStorage(Keys.SaveOutputFolder)
    var saveOutputFolder: String?

    @AppStorage(Keys.OverwritePreviousUpscale)
    var overwritePreviousUpscale: Bool = true

    @AppStorage(Keys.GPUID)
    var gpuID: String = ""

    @AppStorage(Keys.CustomTileSize)
    var customTileSize: Int = 0

    @AppStorage(Keys.CustomModelsFolder)
    var customModelsFolder: String?

    @AppStorage(Keys.DoubleUpscayl)
    var doubleUpscayl: Bool = false

    @AppStorage(Keys.EnableTTA)
    var enableTTA: Bool = false

    @AppStorage(Keys.UpscaylModel)
    var upscaleModel: UpscaylModel = .Upscayl_Standard

    @AppStorage(Keys.UpscaylModelVersion)
    var upscaleModelVersion: String = "2.14.0"

    @AppStorage(Keys.SelectedCustomModel)
    var selectedCustomModel: String?

    @AppStorage(Keys.ManualSaveControl)
    var manualSaveControl: Bool = true

    @AppStorage(Keys.HasShownAutoSaveHint)
    var hasShownAutoSaveHint: Bool = false

    @AppStorage(Keys.HideDockIcon)
    var hideDockIcon: Bool = false

    @AppStorage(Keys.ShowMenuBarExtra)
    var showMenuBarExtra: Bool = false

    @AppStorage(Keys.LaunchSilently)
    var launchSilently: Bool = false

    // Computed property to get the current unified model
    var currentUnifiedModel: UnifiedModel {
        get {
            return UnifiedModel.fromStoredValue(upscaleModel, customModelName: selectedCustomModel)
        }
        set {
            let storageData = newValue.storageData
            upscaleModel = storageData.builtInModel
            selectedCustomModel = storageData.customModelName
        }
    }

    func reset() {
        saveImageAs = .png
        imageScale = 4.0
        imageCompression = 0
        enableSaveOutputFolder = false
        enableZipicCompression = false
        saveOutputFolder = nil
        overwritePreviousUpscale = true
        gpuID = ""
        customTileSize = 0
        customModelsFolder = nil
        doubleUpscayl = false
        enableTTA = false
        upscaleModel = .Upscayl_Standard
        selectedCustomModel = nil
        notification = .HiPixel
        manualSaveControl = true
        hasShownAutoSaveHint = false
        hideDockIcon = false
        showMenuBarExtra = false
        launchSilently = false
    }
}

// MARK: - Upscayl Options

/// Simple options structure for passing temporary configuration to processing methods
struct UpscaylOptions {
    var saveImageAs: HiPixelConfiguration.ImageFormat?
    var imageScale: Double?
    var imageCompression: Int?
    var enableZipicCompression: Bool?
    var enableSaveOutputFolder: Bool?
    var saveOutputFolder: String?
    var overwritePreviousUpscale: Bool?
    var gpuID: String?
    var customTileSize: Int?
    var customModelsFolder: String?
    var upscaylModel: HiPixelConfiguration.UpscaylModel?
    var selectedCustomModel: String?
    var doubleUpscayl: Bool?
    var enableTTA: Bool?
    var manualSaveControl: Bool?

    /// Fill missing values from HiPixelConfiguration.shared
    mutating func fillDefaults(from config: HiPixelConfiguration = HiPixelConfiguration.shared) {
        if saveImageAs == nil { saveImageAs = config.saveImageAs }
        if imageScale == nil { imageScale = config.imageScale }
        if imageCompression == nil { imageCompression = config.imageCompression }
        if enableZipicCompression == nil { enableZipicCompression = config.enableZipicCompression }
        if enableSaveOutputFolder == nil { enableSaveOutputFolder = config.enableSaveOutputFolder }
        if saveOutputFolder == nil { saveOutputFolder = config.saveOutputFolder }
        if overwritePreviousUpscale == nil { overwritePreviousUpscale = config.overwritePreviousUpscale }
        if gpuID == nil { gpuID = config.gpuID }
        if customTileSize == nil { customTileSize = config.customTileSize }
        if customModelsFolder == nil { customModelsFolder = config.customModelsFolder }
        if upscaylModel == nil { upscaylModel = config.upscaleModel }
        if selectedCustomModel == nil { selectedCustomModel = config.selectedCustomModel }
        if doubleUpscayl == nil { doubleUpscayl = config.doubleUpscayl }
        if enableTTA == nil { enableTTA = config.enableTTA }
        if manualSaveControl == nil { manualSaveControl = config.manualSaveControl }
    }

    /// Create options from URL query parameters
    static func fromURLQueryItems(_ queryItems: [URLQueryItem]) -> UpscaylOptions {
        var options = UpscaylOptions()

        // Configuration mapping for URL parsing
        let configMap: [String: (String) -> Any?] = [
            "saveImageAs": { HiPixelConfiguration.ImageFormat(rawValue: $0.uppercased()) },
            "imageScale": { Double($0) },
            "imageCompression": { Int($0) },
            "enableZipicCompression": { Bool($0) },
            "enableSaveOutputFolder": { Bool($0) },
            "saveOutputFolder": { ($0.removingPercentEncoding ?? $0) as String },
            "overwritePreviousUpscale": { Bool($0) },
            "gpuID": { $0 as String },
            "customTileSize": { Int($0) },
            "customModelsFolder": { ($0.removingPercentEncoding ?? $0) as String },
            "upscaylModel": { HiPixelConfiguration.UpscaylModel(rawValue: $0) },
            "selectedCustomModel": { ($0.removingPercentEncoding ?? $0) as String },
            "doubleUpscayl": { Bool($0) },
            "enableTTA": { Bool($0) },
        ]

        for item in queryItems {
            guard let value = item.value else { continue }

            switch item.name {
            case "saveImageAs":
                if let parsed = configMap[item.name]?(value) as? HiPixelConfiguration.ImageFormat {
                    options.saveImageAs = parsed
                }
            case "imageScale":
                if let parsed = configMap[item.name]?(value) as? Double {
                    options.imageScale = parsed
                }
            case "imageCompression":
                if let parsed = configMap[item.name]?(value) as? Int {
                    options.imageCompression = parsed
                }
            case "enableZipicCompression":
                if let parsed = configMap[item.name]?(value) as? Bool {
                    options.enableZipicCompression = parsed
                }
            case "enableSaveOutputFolder":
                if let parsed = configMap[item.name]?(value) as? Bool {
                    options.enableSaveOutputFolder = parsed
                }
            case "saveOutputFolder":
                if let parsed = configMap[item.name]?(value) as? String {
                    options.saveOutputFolder = parsed
                }
            case "overwritePreviousUpscale":
                if let parsed = configMap[item.name]?(value) as? Bool {
                    options.overwritePreviousUpscale = parsed
                }
            case "gpuID":
                if let parsed = configMap[item.name]?(value) as? String {
                    options.gpuID = parsed
                }
            case "customTileSize":
                if let parsed = configMap[item.name]?(value) as? Int {
                    options.customTileSize = parsed
                }
            case "customModelsFolder":
                if let parsed = configMap[item.name]?(value) as? String {
                    options.customModelsFolder = parsed
                }
            case "upscaylModel":
                if let parsed = configMap[item.name]?(value) as? HiPixelConfiguration.UpscaylModel {
                    options.upscaylModel = parsed
                    options.selectedCustomModel = nil  // Clear custom model when built-in is specified
                }
            case "selectedCustomModel":
                if let parsed = configMap[item.name]?(value) as? String {
                    options.selectedCustomModel = parsed
                    // Clear built-in model when custom model is specified
                    options.upscaylModel = HiPixelConfiguration.UpscaylModel.Upscayl_Standard
                }
            case "doubleUpscayl":
                if let parsed = configMap[item.name]?(value) as? Bool {
                    options.doubleUpscayl = parsed
                }
            case "enableTTA":
                if let parsed = configMap[item.name]?(value) as? Bool {
                    options.enableTTA = parsed
                }
            default:
                break
            }
        }

        return options
    }

    /// Merge with another options instance (other takes precedence)
    func merge(with other: UpscaylOptions) -> UpscaylOptions {
        var merged = self
        if let saveImageAs = other.saveImageAs { merged.saveImageAs = saveImageAs }
        if let imageScale = other.imageScale { merged.imageScale = imageScale }
        if let imageCompression = other.imageCompression { merged.imageCompression = imageCompression }
        if let enableZipicCompression = other.enableZipicCompression {
            merged.enableZipicCompression = enableZipicCompression
        }
        if let enableSaveOutputFolder = other.enableSaveOutputFolder {
            merged.enableSaveOutputFolder = enableSaveOutputFolder
        }
        if let saveOutputFolder = other.saveOutputFolder { merged.saveOutputFolder = saveOutputFolder }
        if let overwritePreviousUpscale = other.overwritePreviousUpscale {
            merged.overwritePreviousUpscale = overwritePreviousUpscale
        }
        if let gpuID = other.gpuID { merged.gpuID = gpuID }
        if let customTileSize = other.customTileSize { merged.customTileSize = customTileSize }
        if let customModelsFolder = other.customModelsFolder { merged.customModelsFolder = customModelsFolder }
        if let upscaylModel = other.upscaylModel { merged.upscaylModel = upscaylModel }
        if let selectedCustomModel = other.selectedCustomModel { merged.selectedCustomModel = selectedCustomModel }
        if let doubleUpscayl = other.doubleUpscayl { merged.doubleUpscayl = doubleUpscayl }
        if let enableTTA = other.enableTTA { merged.enableTTA = enableTTA }
        if let manualSaveControl = other.manualSaveControl { merged.manualSaveControl = manualSaveControl }
        return merged
    }
}

// MARK: - UpscaylOptions Computed Properties

extension UpscaylOptions {
    /// Resolved values with defaults from HiPixelConfiguration.shared
    private var config: HiPixelConfiguration {
        HiPixelConfiguration.shared
    }

    var resolvedSaveImageAs: HiPixelConfiguration.ImageFormat {
        saveImageAs ?? config.saveImageAs
    }

    var resolvedImageScale: Double {
        imageScale ?? config.imageScale
    }

    var resolvedImageCompression: Int {
        imageCompression ?? config.imageCompression
    }

    var resolvedEnableZipicCompression: Bool {
        enableZipicCompression ?? config.enableZipicCompression
    }

    var resolvedEnableSaveOutputFolder: Bool {
        enableSaveOutputFolder ?? config.enableSaveOutputFolder
    }

    var resolvedSaveOutputFolder: String? {
        saveOutputFolder ?? config.saveOutputFolder
    }

    var resolvedOverwritePreviousUpscale: Bool {
        overwritePreviousUpscale ?? config.overwritePreviousUpscale
    }

    var resolvedGpuID: String {
        gpuID ?? config.gpuID
    }

    var resolvedCustomTileSize: Int {
        customTileSize ?? config.customTileSize
    }

    var resolvedCustomModelsFolder: String? {
        customModelsFolder ?? config.customModelsFolder
    }

    var resolvedUpscaylModel: HiPixelConfiguration.UpscaylModel {
        upscaylModel ?? config.upscaleModel
    }

    var resolvedSelectedCustomModel: String? {
        selectedCustomModel ?? config.selectedCustomModel
    }

    var resolvedDoubleUpscayl: Bool {
        doubleUpscayl ?? config.doubleUpscayl
    }

    var resolvedEnableTTA: Bool {
        enableTTA ?? config.enableTTA
    }

    var resolvedManualSaveControl: Bool {
        manualSaveControl ?? config.manualSaveControl
    }

    /// Get unified model from resolved options
    var resolvedCurrentUnifiedModel: UnifiedModel {
        if let customModelName = resolvedSelectedCustomModel,
            let customModel = CustomModelManager.shared.customModels.first(where: { $0.name == customModelName })
        {
            return .custom(customModel)
        }
        return UnifiedModel.fromStoredValue(resolvedUpscaylModel, customModelName: resolvedSelectedCustomModel)
    }
}

// MARK: - Bool Extension for String Conversion
extension Bool {
    init?(_ string: String) {
        let lowercased = string.lowercased()
        switch lowercased {
        case "true", "1", "yes", "on":
            self = true
        case "false", "0", "no", "off":
            self = false
        default:
            return nil
        }
    }
}
