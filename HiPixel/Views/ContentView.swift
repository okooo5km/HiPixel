//
//  ContentView.swift
//  HiPixel
//
//  Created by 十里 on 2024/6/16.
//

import AppKit
import SwiftUI

struct ContentView: View, DropDelegate {

    @AppStorage(HiPixelConfiguration.Keys.ColorScheme)
    var colorScheme: HiPixelConfiguration.ColorScheme = .system

    @AppStorage(HiPixelConfiguration.Keys.ManualSaveControl)
    var manualSaveControl: Bool = true

    @State var isOptionsPresented: Bool = false

    @State var isFilePanelPresented: Bool = false

    @State private var dropOver = false
    @State private var hovering = false
    @State private var buttonHovering = false
    @State private var saveButtonHovering = false

    @State private var item: UpscaylDataItem? = nil
    @State private var showResourceDownloadSheet = false
    @State private var showAutoSaveHint = false

    @StateObject private var resourceDownloadManager = ResourceDownloadManager.shared
    @EnvironmentObject var upscaylData: UpscaylData

    private var cornerRadius: CGFloat {
        if #available(macOS 26.0, *) {
            return 12
        } else {
            return 8
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 16) {
                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isOptionsPresented.toggle()
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .popover(isPresented: $isOptionsPresented) {
                            UpscaleSettingsView()
                                .font(.caption)
                                .frame(width: 320)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            VStack {
                if let item = upscaylData.selectedItem, !dropOver {
                    switch item.state {
                    case .processing:
                        GeometryReader { geometry in
                            AsyncImage(url: item.url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .blur(radius: 16)
                            } placeholder: {
                                Color.gray
                            }
                            .overlay(alignment: .center) {
                                VStack(spacing: 8) {
                                    BreathingProcessingView()
                                        .font(.title)
                                    Text("\(item.progress, specifier: "%.0f")%")
                                        .font(.title)
                                        .fontDesign(.monospaced)
                                    Text(
                                        HiPixelConfiguration.shared.doubleUpscayl
                                            ? "Processing... (\(item.processingStage)/2)" : "Processing..."
                                    )
                                    .font(.caption)
                                }
                                .padding(16)
                                .background(cornerRadius: 16, fill: .background.opacity(0.8))
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                            }
                        }
                    case .failed:
                        GeometryReader { geometry in
                            AsyncImage(url: item.url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            } placeholder: {
                                Color.gray
                            }
                            .overlay(alignment: .center) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label(
                                        "\(item.size.width, specifier: "%.0f")×\(item.size.height, specifier: "%.0f") px",
                                        systemImage: "viewfinder.rectangular"
                                    )
                                    .font(.caption)
                                    Text("Failed to process")
                                        .font(.headline)
                                }
                                .padding(16)
                                .background(cornerRadius: 16, fill: .background.opacity(0.8))
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                            }
                        }
                    case .success:
                        ImageComparationViewer(leftImage: item.url, rightImage: item.newURL)
                            .overlay(alignment: .top) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Original Image")
                                            .font(.headline)
                                        Label(
                                            "\(item.size.width, specifier: "%.0f")×\(item.size.height, specifier: "%.0f") px",
                                            systemImage: "viewfinder.rectangular"
                                        )
                                        .font(.caption)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.background.opacity(0.8))
                                            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 0.4)
                                    )
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 8) {
                                        Text("HiPixeled Image")
                                            .font(.headline)
                                        Label(
                                            "\(item.newSize.width, specifier: "%.0f")×\(item.newSize.height, specifier: "%.0f") px",
                                            systemImage: "viewfinder.rectangular"
                                        )
                                        .font(.caption)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.background.opacity(0.8))
                                            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 0.4)
                                    )
                                }
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                                .padding(6)
                            }
                            .overlay(alignment: .bottomTrailing) {
                                HStack(spacing: 8) {
                                    // Save button (only show when manual save control is enabled and processing is successful)
                                    if manualSaveControl && item.state == .success {
                                        Button {
                                            saveImage(from: item)
                                        } label: {
                                            Image(systemName: "square.and.arrow.down")
                                                .padding(8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(.background.opacity(0.8))
                                                        .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 0.4)
                                                )
                                                .scaleEffect(saveButtonHovering ? 1.1 : 1.0)
                                        }
                                        .buttonStyle(.plain)
                                        .onHover { hovering in
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                saveButtonHovering = hovering
                                            }
                                        }
                                    }

                                    // Reprocess button
                                    Button {
                                        Upscayl.process([item.url], by: upscaylData, source: .userDirect)
                                    } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.background.opacity(0.8))
                                                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 0.4)
                                            )
                                            .scaleEffect(buttonHovering ? 1.1 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                    .onHover { hovering in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            buttonHovering = hovering
                                        }
                                    }
                                }
                                .padding(12)
                            }
                            .background {
                                ZStack {
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .fill(.background.opacity(hovering ? 0.7 : 0.8))

                                    GeometryReader { geometry in
                                        HStack(spacing: 40) {
                                            ForEach(0..<59) { _ in
                                                Rectangle()
                                                    .fill(.background.opacity(hovering ? 0.5 : 0.4))
                                                    .frame(width: 40)
                                            }
                                        }
                                        .frame(width: geometry.size.width)
                                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                    }
                                }
                            }
                    }
                } else {
                    VStack {
                        ZStack {
                            Image(hovering || dropOver ? .hipixelboard2 : .hipixelboard1)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.6),
                                    value: hovering
                                )
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.6),
                                    value: dropOver
                                )

                            Image(.magicbar)
                                .scaleEffect(0.92)
                                .rotationEffect(.init(degrees: hovering || dropOver ? 7 : -5))
                                .offset(x: hovering || dropOver ? -48 : 24, y: hovering || dropOver ? -8 : -12)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.6),
                                    value: hovering
                                )
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.6),
                                    value: dropOver
                                )
                        }
                        .padding(.bottom, -24)

                        if dropOver {
                            Text("✨ Release to Process Images ✨")
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .font(.system(size: 15, weight: .heavy))
                        } else {
                            Text("✨ Drag image files or folders here ✨")
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .font(.system(size: 15, weight: .heavy))
                        }

                        Text("**PNG** • **JPEG** • **WebP**")
                            .font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(dropOver || hovering ? .primary : .secondary)
                    .overlay(alignment: .bottom) {
                        Text("AI Image Upscaler Wrapping **[Upscayl](https://github.com/upscayl/upscayl)**")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.75))
                            .padding(12)
                    }
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(.background.opacity(hovering ? 0.7 : 0.8))

                            GeometryReader { geometry in
                                HStack(spacing: 40) {
                                    ForEach(0..<59) { _ in
                                        Rectangle()
                                            .fill(.background.opacity(hovering ? 0.5 : 0.4))
                                            .frame(width: 40)
                                    }
                                }
                                .frame(width: geometry.size.width)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            }

                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                .foregroundStyle(.primary.opacity(hovering ? 0.24 : 0.12))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .background(
                cornerRadius: cornerRadius,
                strokeColor: .primary.opacity(upscaylData.selectedItem == nil ? 0 : 0.1),
                fill: .background.opacity(upscaylData.selectedItem == nil ? 0 : 0.4)
            )
            .padding(
                .init(
                    top: 8,
                    leading: 8,
                    bottom: upscaylData.items.isEmpty ? 8 : 0,
                    trailing: 8
                ))

            if !(upscaylData.items.isEmpty) {
                HStack(spacing: 8) {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 8) {
                            ForEach(upscaylData.items, id: \.id) { item in
                                ThumbnailView(item: item)
                                    .contextMenu {
                                        Button(action: {
                                            upscaylData.selectedItem = nil
                                            upscaylData.remove(item)
                                        }) {
                                            Label("Remove The Image", systemImage: "rectangle.badge.minus")
                                        }

                                        Button(action: {
                                            upscaylData.selectedItem = nil
                                            upscaylData.removeAll()
                                        }) {
                                            Label("Remove History List", systemImage: "rectangle.stack.badge.minus")
                                        }
                                    }
                            }
                        }
                        .frame(height: 80)
                    }
                }
                .frame(height: 80)
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                .padding(.horizontal, 8)
            }
        }
        .background(VibrantBackground().ignoresSafeArea(.all))
        .fileImporter(
            isPresented: $isFilePanelPresented,
            allowedContentTypes: [.jpeg, .png, .webP, .folder],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Upscayl.process(urls, by: upscaylData, source: .userDirect)
            case .failure(let error):
                Common.logger.error("Failed to import files: \(error)")
            }
        }
        .onDrop(of: [.png, .jpeg, .webP], delegate: self)
        .onHover { inHover in
            if inHover != hovering {
                hovering = inHover
            }
        }
        .onAppear {
            // Check if resources are missing and show download sheet if needed
            let binPath = Common.directory.appendingPathComponent("bin")
            let modelsPath = Common.directory.appendingPathComponent("models")
            let fileManager = FileManager.default

            let binExists = fileManager.fileExists(atPath: binPath.path)
            let modelsExists = fileManager.fileExists(atPath: modelsPath.path)

            Common.logger.info("Resource check on startup - bin exists: \(binExists), models exists: \(modelsExists)")

            if !binExists || !modelsExists {
                Common.logger.info("Resources missing - showing download sheet")
                showResourceDownloadSheet = true
            } else {
                Common.logger.info("Resources exist - checking for updates in background")
                Task {
                    await resourceDownloadManager.downloadResourcesIfNeeded()
                }
            }
        }
        .sheet(isPresented: $showResourceDownloadSheet) {
            ResourceDownloadSheet()
        }
        .sheet(isPresented: $showAutoSaveHint) {
            AutoSaveHintSheet(isPresented: $showAutoSaveHint)
        }
        .onChange(of: resourceDownloadManager.downloadState) { state in
            // Auto-dismiss sheet when download is completed
            if case .completed = state {
                showResourceDownloadSheet = false
            }
        }
        .focusable(false)
    }

    func dropEntered(info: DropInfo) {
        withAnimation {
            dropOver = true
        }
        //        DispatchQueue.main.async {
        //            SoundManager.shared.playSound()
        //        }
    }

    func dropExited(info: DropInfo) {
        withAnimation {
            dropOver = false
        }
    }

    func validateDrop(info: DropInfo) -> Bool {
        if info.hasItemsConforming(to: [.png, .jpeg, .webP]) {
            return true
        }
        return false
    }

    func performDrop(info: DropInfo) -> Bool {

        let queue = DispatchQueue(label: "parsing url ...", attributes: .concurrent)
        let group = DispatchGroup()

        var urls = [URL]()

        withAnimation {
            dropOver = false
        }

        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        for provider in info.itemProviders(for: [.fileURL]) {
            if !provider.canLoadObject(ofClass: URL.self) {
                continue
            }
            group.enter()
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                defer {
                    group.leave()
                }
                guard let data = item as? Data,
                    let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL?
                else {
                    return
                }
                if !url.hasDirectoryPath && !url.isImageFile {
                    return
                }
                urls.append(url)
            }
        }

        group.notify(queue: queue) {
            DispatchQueue.main.async {
                Upscayl.process(urls, by: upscaylData, source: .userDirect)
            }
        }

        return true
    }

    private func saveImage(from item: UpscaylDataItem) {
        // Only allow saving if processing is successful
        guard item.state == .success else { return }

        let sourceURL = item.newURL

        // Generate default filename based on configuration
        let config = HiPixelConfiguration.shared
        let scale = Int(config.imageScale)
        let effectiveScale = config.doubleUpscayl ? scale * scale : scale
        let unifiedModel = config.currentUnifiedModel
        let modelID = unifiedModel.modelName

        let originalName = item.url.deletingPathExtension().lastPathComponent
        let postfix = "_hipixel_\(effectiveScale)x_\(modelID)"

        // Determine file extension based on save format
        let fileExtension: String
        switch config.saveImageAs {
        case .png:
            fileExtension = "png"
        case .jpg:
            fileExtension = "jpg"
        case .webp:
            fileExtension = "webp"
        case .original:
            fileExtension = item.url.pathExtension.isEmpty ? "png" : item.url.pathExtension
        }

        let defaultFileName = originalName + postfix + "." + fileExtension

        let savePanel = NSSavePanel()
        // Set allowed content types based on file extension
        switch fileExtension.lowercased() {
        case "png":
            savePanel.allowedContentTypes = [.png]
        case "jpg", "jpeg":
            savePanel.allowedContentTypes = [.jpeg]
        case "webp":
            savePanel.allowedContentTypes = [.webP]
        default:
            savePanel.allowedContentTypes = [.png, .jpeg, .webP]
        }
        savePanel.nameFieldStringValue = defaultFileName
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false

        // Set default directory to original image's directory
        savePanel.directoryURL = item.url.deletingLastPathComponent()

        savePanel.begin { result in
            if result == .OK, let destinationURL = savePanel.url {
                do {
                    // Copy file from temporary location to user-selected location
                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                    // First save success — show auto-save hint if not shown before
                    if !HiPixelConfiguration.shared.hasShownAutoSaveHint {
                        HiPixelConfiguration.shared.hasShownAutoSaveHint = true
                        showAutoSaveHint = true
                    }
                } catch {
                    Common.logger.error("Failed to save image: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(UpscaylData.shared)
}
