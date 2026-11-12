//
//  StripedBackground.swift
//  HiPixel
//
//  Created by okooo5km(十里) on 2026/10/17.
//

import SwiftUI

/// Vertical stripes centered in the rect, drawn as one path instead of dozens of separate views.
struct StripesShape: Shape {
    var stripeWidth: CGFloat = 40
    var spacing: CGFloat = 40
    var count: Int = 59

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard count > 0 else { return path }

        let pitch = stripeWidth + spacing
        let totalWidth = CGFloat(count) * stripeWidth + CGFloat(count - 1) * spacing
        let originX = rect.midX - totalWidth / 2

        for index in 0..<count {
            let stripe = CGRect(
                x: originX + CGFloat(index) * pitch,
                y: rect.minY,
                width: stripeWidth,
                height: rect.height
            ).intersection(rect)
            if !stripe.isNull && stripe.width > 0 {
                path.addRect(stripe)
            }
        }
        return path
    }
}

/// Rounded panel background with translucent stripes, shared by the empty state and the result view.
struct StripedBackground: View {
    var cornerRadius: CGFloat
    var highlighted: Bool
    var showsDashedBorder: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.background.opacity(highlighted ? 0.7 : 0.8))

            StripesShape()
                .fill(.background.opacity(highlighted ? 0.5 : 0.4))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            if showsDashedBorder {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    .foregroundStyle(.primary.opacity(highlighted ? 0.24 : 0.12))
            }
        }
    }
}
