//
//  BottomRoundedRectangle.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//
import Foundation
import SwiftUICore

struct BottomRoundedRectangle: Shape {
    var radius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))                     // top-left
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))                 // top-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))        // before bottom-right
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))        // bottom
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        path.closeSubpath()
        return path
    }
}

