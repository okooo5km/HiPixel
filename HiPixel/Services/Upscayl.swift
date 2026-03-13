//
//  Upscayl.swift
//  HiPixel
//
//  Created by 十里 on 2024/10/31.
//

import SwiftUI

struct CommandResult: CustomStringConvertible {
    let output: String
    let error: Process.TerminationReason
    let status: Int32

    var description: String {
        "error:\(error.rawValue), output:\(output), status:\(status)"
    }
}
enum Upscayl {
    // MARK: - Types

    /// Processing source to determine if manual save control should be applied
    enum ProcessingSource {
        case userDirect  // User drag & drop, file picker, reprocess button
        case automated  // URL Scheme, AppIntents, folder monitoring
    }

    struct CommandResult: CustomStringConvertible {
        let output: String
        let error: Process.TerminationReason
        let status: Int32

        var description: String {
            "error:\(error.rawValue), output:\(output), status:\(status)"
        }
    }

    // MARK: - Constants

    private enum Constants {
        static let progressPrefix = "UPSCAYL_PROGRESS:"
    }

    // MARK: - Configuration Helper

    /// Get effective configuration from options, filling defaults from shared if needed
    private static func effectiveConfig(_ options: UpscaylOptions?) -> UpscaylOptions {
        return options ?? UpscaylOptions()
    }

    /// Get unified model from options
    private static func getUnifiedModel(from options: UpscaylOptions) -> UnifiedModel {
        return options.resolvedCurrentUnifiedModel
    }

    // MARK: - Public Methods

    static func process(
        _ item: UpscaylDataItem,
        progressHandler: @escaping (_ progress: Double) -> Void,
        completedHandler: @escaping (_ url: URL?) -> Void,
        options: UpscaylOptions? = nil,
        source: ProcessingSource = .userDirect
    ) {
        let effectiveOptions = Self.effectiveConfig(options)
        if effectiveOptions.resolvedDoubleUpscayl {
            processDouble(
                item,
                stageProgressHandler: { progress, _ in
                    progressHandler(progress)
                }, completedHandler: completedHandler, options: effectiveOptions, source: source)
        } else {
            processSingle(
                item,
                stageProgressHandler: { progress, _ in
                    progressHandler(progress)
                }, completedHandler: completedHandler, options: effectiveOptions, source: source)
        }
    }

    static func process(
        _ item: UpscaylDataItem,
        progressHandler: @escaping (_ progress: Double, _ stage: Int) -> Void,
        completedHandler: @escaping (_ url: URL?) -> Void,
        options: UpscaylOptions? = nil,
        source: ProcessingSource = .userDirect
    ) {
        let effectiveOptions = Self.effectiveConfig(options)
        if effectiveOptions.resolvedDoubleUpscayl {
            processDouble(
                item, stageProgressHandler: progressHandler, completedHandler: completedHandler,
                options: effectiveOptions, source: source)
        } else {
            processSingle(
                item, stageProgressHandler: progressHandler, completedHandler: completedHandler,
                options: effectiveOptions, source: source)
        }
    }

    private static func processSingle(
        _ item: UpscaylDataItem,
        progressHandler: @escaping (_ progress: Double) -> Void,
        completedHandler: @escaping (_ url: URL?) -> Void,
        options: UpscaylOptions,
        source: ProcessingSource
    ) {
        let arguments = makeArguments(for: item, options: options, source: source)
        let formatStr = determineFormatString(for: item, options: options)
        let newURL = makeOutputURL(for: item, ext: formatStr, options: options, source: source)
        Common.logger.debug("\(arguments)")
        if FileManager.default.fileExists(atPath: newURL.path)
            && !options.resolvedOverwritePreviousUpscale
        {
            completedHandler(newURL)
            return
        }
        let result = run(arguments: arguments, progressHandler: progressHandler)

        // Handle compression if needed
        if result.status == 0 && options.resolvedImageCompression > 0 {
            if options.resolvedEnableZipicCompression
                && AppInstallationChecker.isAppInstalled(bundleIdentifier: "studio.5km.zipic")
            {
                // Use Zipic for compression
                let saveDir: URL? =
                    options.resolvedEnableSaveOutputFolder && options.resolvedSaveOutputFolder != nil
                    ? URL(string: options.resolvedSaveOutputFolder!)?.standardizedFileURL : nil
                ZipicCompressor.compress(
                    url: newURL,
                    saveDirectory: saveDir,
                    format: formatStr,
                    level: Double(options.resolvedImageCompression) / 16.5  // Convert 0-99 to 1-6 range
                )
            }
        }

        // Preserve metadata from original image to processed image if processing succeeded
        if result.status == 0 {
            EXIFMetadataManager.compareAndCopyMetadata(from: item.url, to: newURL)
        }

        completedHandler(result.status == 0 ? newURL : nil)
    }

    private static func processSingle(
        _ item: UpscaylDataItem,
        stageProgressHandler: @escaping (_ progress: Double, _ stage: Int) -> Void,
        completedHandler: @escaping (_ url: URL?) -> Void,
        options: UpscaylOptions,
        source: ProcessingSource
    ) {
        let arguments = makeArguments(for: item, options: options, source: source)
        let formatStr = determineFormatString(for: item, options: options)
        let newURL = makeOutputURL(for: item, ext: formatStr, options: options, source: source)
        Common.logger.debug("\(arguments)")
        if FileManager.default.fileExists(atPath: newURL.path)
            && !options.resolvedOverwritePreviousUpscale
        {
            completedHandler(newURL)
            return
        }
        let result = run(arguments: arguments) { progress in
            stageProgressHandler(progress, 1)
        }

        // Handle compression if needed
        if result.status == 0 && options.resolvedImageCompression > 0 {
            if options.resolvedEnableZipicCompression
                && AppInstallationChecker.isAppInstalled(bundleIdentifier: "studio.5km.zipic")
            {
                // Use Zipic for compression
                let saveDir: URL? =
                    options.resolvedEnableSaveOutputFolder && options.resolvedSaveOutputFolder != nil
                    ? URL(string: options.resolvedSaveOutputFolder!)?.standardizedFileURL : nil
                ZipicCompressor.compress(
                    url: newURL,
                    saveDirectory: saveDir,
                    format: formatStr,
                    level: Double(options.resolvedImageCompression) / 16.5  // Convert 0-99 to 1-6 range
                )
            }
        }

        // Preserve metadata from original image to processed image if processing succeeded
        if result.status == 0 {
            EXIFMetadataManager.compareAndCopyMetadata(from: item.url, to: newURL)
        }

        completedHandler(result.status == 0 ? newURL : nil)
    }

    private static func processDouble(
        _ item: UpscaylDataItem,
        stageProgressHandler: @escaping (_ progress: Double, _ stage: Int) -> Void,
        completedHandler: @escaping (_ url: URL?) -> Void,
        options: UpscaylOptions,
        source: ProcessingSource
    ) {
        let formatStr = determineFormatString(for: item, options: options)
        let finalURL = makeOutputURL(for: item, ext: formatStr, options: options, source: source)

        // Check if final result already exists
        if FileManager.default.fileExists(atPath: finalURL.path)
            && !(options.overwritePreviousUpscale ?? false)
        {
            completedHandler(finalURL)
            return
        }

        // Create temporary file for first processing stage
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileName = "temp_\(UUID().uuidString).\(formatStr)"
        let tempURL = tempDir.appendingPathComponent(tempFileName)

        // First processing stage
        let firstArguments = makeArguments(for: item, outputURL: tempURL, options: options)
        Common.logger.debug("First stage: \(firstArguments)")

        let firstResult = run(arguments: firstArguments) { progress in
            // Show raw progress for first stage
            stageProgressHandler(progress, 1)
        }

        guard firstResult.status == 0 else {
            // First stage failed, clean up and return failure
            try? FileManager.default.removeItem(at: tempURL)
            completedHandler(nil)
            return
        }

        // Second processing stage using the temporary file as input
        var secondItem = item
        secondItem.url = tempURL
        let secondArguments = makeArguments(for: secondItem, outputURL: finalURL, options: options)
        Common.logger.debug("Second stage: \(secondArguments)")

        let secondResult = run(arguments: secondArguments) { progress in
            // Show raw progress for second stage
            stageProgressHandler(progress, 2)
        }

        // Clean up temporary file
        try? FileManager.default.removeItem(at: tempURL)

        guard secondResult.status == 0 else {
            completedHandler(nil)
            return
        }

        // Handle compression if needed
        if options.resolvedImageCompression > 0 {
            if options.resolvedEnableZipicCompression
                && AppInstallationChecker.isAppInstalled(bundleIdentifier: "studio.5km.zipic")
            {
                // Use Zipic for compression
                let saveDir: URL? =
                    options.resolvedEnableSaveOutputFolder && options.resolvedSaveOutputFolder != nil
                    ? URL(string: options.resolvedSaveOutputFolder!)?.standardizedFileURL : nil
                ZipicCompressor.compress(
                    url: finalURL,
                    saveDirectory: saveDir,
                    format: formatStr,
                    level: Double(options.resolvedImageCompression) / 16.5  // Convert 0-99 to 1-6 range
                )
            }
        }

        // Preserve metadata from original image to processed image
        EXIFMetadataManager.compareAndCopyMetadata(from: item.url, to: finalURL)

        completedHandler(finalURL)
    }

    static let semaphore = DispatchSemaphore(value: 1)

    static func process(
        _ urls: [URL],
        by data: UpscaylData,
        options: UpscaylOptions? = nil,
        source: ProcessingSource = .userDirect
    ) {
        if urls.isEmpty { return }
        let effectiveOptions = Self.effectiveConfig(options)
        let group = DispatchGroup()

        guard let first = urls.first else { return }

        let baseDir: URL = first.deletingLastPathComponent()
        var saveDir = baseDir

        if effectiveOptions.resolvedEnableSaveOutputFolder,
            let folderPath = effectiveOptions.resolvedSaveOutputFolder,
            let folderURL = URL(string: folderPath)
        {
            saveDir = folderURL
            do {
                try FileManager.default.createDirectory(at: saveDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Common.logger.error("Failed to create directory at \(baseDir), \(error)")
            }
        }

        struct SignURL {
            let url: URL
            let dirURL: URL?
        }

        var signURLs: [SignURL] = []
        for url in urls {
            if url.hasDirectoryPath {
                let imageURLs = url.imageContents
                let _signURLs = imageURLs.map { SignURL(url: $0, dirURL: url) }
                signURLs.append(contentsOf: _signURLs)
            } else {
                if !url.isImageFile { continue }
                signURLs.append(SignURL(url: url, dirURL: nil))
            }
        }

        if signURLs.isEmpty { return }

        let operationQueue = QueueManager.shared.allocate(count: signURLs.count)

        for signURL in signURLs {
            let imageURL = signURL.url
            let url = signURL.dirURL

            if imageURL.fileSize == .zero {
                continue
            }

            let operation = BlockOperation {
                var _saveDir = saveDir

                if url != nil {
                    let baseURL = url!.deletingLastPathComponent()
                    let relativePath = imageURL.path
                        .replacingOccurrences(of: baseURL.path, with: "")
                        .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                    _saveDir = baseDir.appendingPathComponent(relativePath).deletingLastPathComponent()

                    let fileManager = FileManager.default

                    do {
                        try fileManager.createDirectory(
                            at: _saveDir, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        Common.logger.error("An error occurred: \(error)")
                    }
                }

                /// Check if it has been synced from iCloud
                if !imageURL.exists {
                    return
                }

                var item = UpscaylDataItem(imageURL)
                if let nsImage = NSImage(contentsOf: imageURL) {
                    item.size = nsImage.pixelSize
                    let scale = effectiveOptions.resolvedImageScale
                    let effectiveScale = effectiveOptions.resolvedDoubleUpscayl ? scale * scale : scale
                    item.newSize = CGSize(
                        width: item.size.width * effectiveScale,
                        height: item.size.height * effectiveScale
                    )
                    if let thumbnail = nsImage.thumbnail(with: 128).saveAtThumbnailDirectory(as: item.fileName) {
                        item.thumbnail = thumbnail
                    } else {
                        item.thumbnail = imageURL
                    }
                }

                DispatchQueue.main.async {
                    data.append(item)
                    data.selectedItem = item
                }

                Upscayl.process(
                    item,
                    progressHandler: { progress, stage in
                        item.progress = progress
                        item.processingStage = stage
                        DispatchQueue.main.async {
                            data.update(item)
                            if data.selectedItem?.url == item.url {
                                data.selectedItem = item
                            }
                        }
                    },
                    completedHandler: { url in
                        if let url = url {
                            // Preserve metadata from original image to processed image
                            EXIFMetadataManager.compareAndCopyMetadata(from: imageURL, to: url)

                            item.newURL = url
                            item.newFileSize = url.fileSize
                            item.timeInterval = Date.now.timeIntervalSince(item.startAt)
                            item.state = .success
                            Common.logger.debug("\(item.newURL)")
                        } else {
                            item.state = .failed
                        }
                        DispatchQueue.main.async {
                            data.update(item)
                            data.selectedItem = item
                        }
                    },
                    options: effectiveOptions,
                    source: source
                )
            }

            operation.completionBlock = {
                group.leave()
            }

            group.enter()
            operationQueue.addOperation(operation)
        }

        group.notify(queue: DispatchQueue.main) {
            if HiPixelConfiguration.shared.notification != .None {
                let isManualSave = effectiveOptions.resolvedManualSaveControl && source == .userDirect

                let message: String
                if isManualSave {
                    message = String(
                        format: NSLocalizedString("Upscale completed: %d images", comment: ""),
                        signURLs.count
                    )
                } else if effectiveOptions.resolvedEnableSaveOutputFolder,
                          let folderPath = effectiveOptions.resolvedSaveOutputFolder {
                    message = String(
                        format: NSLocalizedString("Upscale completed: %d images, saved to %@", comment: ""),
                        signURLs.count,
                        (folderPath as NSString).lastPathComponent
                    )
                } else {
                    let uniqueDirs = Set(signURLs.map {
                        $0.url.deletingLastPathComponent().lastPathComponent
                    })
                    if uniqueDirs.count == 1, let dirName = uniqueDirs.first {
                        message = String(
                            format: NSLocalizedString("Upscale completed: %d images, saved to %@", comment: ""),
                            signURLs.count,
                            dirName
                        )
                    } else {
                        message = String(
                            format: NSLocalizedString("Upscale completed: %d images, saved to source directories", comment: ""),
                            signURLs.count
                        )
                    }
                }

                NotificationX.push(message: message)
            }
        }
    }

    // MARK: - Private Methods

    private static func run(
        arguments: [String],
        progressHandler: ((Double) -> Void)? = nil
    ) -> CommandResult {
        let pipe = Pipe()
        let process = configureProcess(with: arguments, pipe: pipe)
        let outputData = executeProcess(process, pipe: pipe, progressHandler: progressHandler)

        let output = String(data: outputData, encoding: .utf8)
        let result = CommandResult(
            output: output ?? "",
            error: process.terminationReason,
            status: process.terminationStatus
        )

        logErrorIfNeeded(result: result, arguments: arguments)
        return result
    }

    private static func configureProcess(with arguments: [String], pipe: Pipe) -> Process {
        let process = Process()
        process.executableURL = URL(
            fileURLWithPath: ResourceManager.binaryPath().path,
            isDirectory: false,
            relativeTo: NSRunningApplication.current.bundleURL
        )
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe
        return process
    }

    private static func executeProcess(
        _ process: Process,
        pipe: Pipe,
        progressHandler: ((Double) -> Void)?
    ) -> Data {
        var outputData = Data()

        pipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            if !data.isEmpty {
                outputData.append(data)
                handleProcessOutput(data, progressHandler: progressHandler)
            }
            outputData.append(handler.availableData)
        }

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            Common.logger.error("command: upscayl-bin \(process.arguments?.joined(separator: " ") ?? ""), \(error)")
        }

        pipe.fileHandleForReading.readabilityHandler = nil
        try? pipe.fileHandleForReading.close()

        return outputData
    }

    private static func handleProcessOutput(_ data: Data, progressHandler: ((Double) -> Void)?) {
        guard let str = String(data: data, encoding: .utf8) else { return }

        Common.logger.info("\(str)")
        str.components(separatedBy: .newlines).forEach { line in
            if line.contains("%") {
                extractAndUpdateProgress(from: line, handler: progressHandler)
            }
        }
    }

    private static func extractAndUpdateProgress(from line: String, handler: ((Double) -> Void)?) {
        DispatchQueue.main.async {
            let percentStr = line.replacingOccurrences(of: "%", with: "")
            if let percent = Double(percentStr) {
                handler?(percent)
            }
        }
    }

    private static func makeArguments(
        for item: UpscaylDataItem, options: UpscaylOptions, source: ProcessingSource = .userDirect
    ) -> [String] {
        let formatString = determineFormatString(for: item, options: options)
        let outputURL = makeOutputURL(for: item, ext: formatString, options: options, source: source)
        return makeArguments(for: item, outputURL: outputURL, options: options)
    }

    private static func makeArguments(
        for item: UpscaylDataItem, outputURL: URL, options: UpscaylOptions
    ) -> [String] {
        let formatString = outputURL.pathExtension == "jpeg" ? "jpeg" : outputURL.pathExtension
        let currentModel = getUnifiedModel(from: options)

        // Determine model path and name based on model type
        let modelPath: String
        let modelName: String

        switch currentModel {
        case .builtIn(let builtInModel):
            modelPath = ResourceManager.modelsURL.path
            modelName = builtInModel.id
        case .custom(let customModel):
            modelPath = customModel.path
            modelName = customModel.name
        }

        var args = [
            "-i", item.url.path,
            "-o", outputURL.path,
            "-s", "\(Int(options.resolvedImageScale))",
            "-m", modelPath,
            "-n", modelName,
            "-f", formatString,
        ]

        // Only add compression if not using Zipic
        if options.resolvedImageCompression > 0 && !options.resolvedEnableZipicCompression {
            args.append(contentsOf: ["-c", "\(options.resolvedImageCompression)"])
        }

        let gpuID = options.resolvedGpuID
        if !gpuID.isEmpty {
            args.append(contentsOf: ["-g", gpuID])
        }

        let customTileSize = options.resolvedCustomTileSize
        if customTileSize != 0 {
            args.append(contentsOf: ["-t", "\(customTileSize)"])
        }

        if options.resolvedEnableTTA {
            args.append("-x")
        }

        return args
    }

    private static func determineFormatString(
        for item: UpscaylDataItem, options: UpscaylOptions
    ) -> String {
        switch options.resolvedSaveImageAs {
        case .png: return "png"
        case .jpg: return "jpeg"
        case .webp: return "webp"
        case .original: return item.url.imageIdentifier ?? "png"
        }
    }

    private static func makeOutputURL(
        for item: UpscaylDataItem, ext: String, options: UpscaylOptions, source: ProcessingSource = .userDirect
    ) -> URL {
        // If manual save control is enabled AND source is user direct operation, save to temporary directory
        if options.resolvedManualSaveControl && source == .userDirect {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("hipixel")
                .appendingPathComponent("manual-save")

            // Create directory if it doesn't exist
            try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

            let scale = Int(options.resolvedImageScale)
            let effectiveScale = options.resolvedDoubleUpscayl ? scale * scale : scale
            let unifiedModel = getUnifiedModel(from: options)
            let modelID = unifiedModel.modelName
            let postfix = "_hipixel_\(effectiveScale)x_\(modelID)"
            let fileName = item.url.deletingPathExtension().lastPathComponent + postfix
            return tempDir.appendingPathComponent(fileName).appendingPathExtension(ext)
        }

        // Normal save logic
        var url = item.url
        if options.resolvedEnableSaveOutputFolder,
            let saveFolder = options.resolvedSaveOutputFolder,
            let baseDir = URL(string: "file://" + saveFolder)
        {
            url = baseDir.appendingPathComponent(url.lastPathComponent)
        }

        let scale = Int(options.resolvedImageScale)
        let effectiveScale = options.resolvedDoubleUpscayl ? scale * scale : scale
        let unifiedModel = getUnifiedModel(from: options)
        let modelID = unifiedModel.modelName
        let postfix = "_hipixel_\(effectiveScale)x_\(modelID)"
        return url.appendingPostfix(postfix).changingPathExtension(to: ext)
    }

    private static func logErrorIfNeeded(result: CommandResult, arguments: [String]) {
        if result.status != 0 {
            Common.logger.error("command: upscayl-bin \(arguments.joined(separator: " ")), \(result)")
        }
    }
}
