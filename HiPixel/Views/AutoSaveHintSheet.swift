//
//  AutoSaveHintSheet.swift
//  HiPixel
//
//  Created by okooo5km(十里) on 2026/3/13.
//

import SwiftUI

struct AutoSaveHintSheet: View {
    @Binding var isPresented: Bool

    @AppStorage(HiPixelConfiguration.Keys.ManualSaveControl)
    var manualSaveControl: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)

                Text("Enable Auto Save?")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Auto save processed images to the source directory.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            // Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto Save")
                        .fontWeight(.medium)
                    Text("Save processed images to the source directory automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { !manualSaveControl },
                    set: { manualSaveControl = !$0 }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(.horizontal, 4)

            // Button
            Button("Got It") {
                isPresented = false
            }
            .buttonStyle(.gradient(configuration: .primary))
        }
        .padding(16)
        .frame(width: 320)
        .background(.regularMaterial)
    }
}

#Preview {
    AutoSaveHintSheet(isPresented: .constant(true))
}
