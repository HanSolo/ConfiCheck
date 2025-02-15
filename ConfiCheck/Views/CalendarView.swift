//
//  CalendarView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 14.02.25.
//

import SwiftUI
import CoreGraphics


struct CalendarView: View {
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject           private var model : ConfiModel
        
    private let calendar      : Calendar      = Calendar.current
    private let dateFormatter : DateFormatter = {
        let formatter : DateFormatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d M")
        return formatter
    }()
    
    
    var body: some View {
        // Show conferences from the last 4 weeks and the next 12 weeks -> 16 weeks
        GeometryReader { geometry in
            Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { ctx, size in
                let fgdColor                   : Color  = .primary
                let width                      : Double = size.width
                let height                     : Double = size.height
                let scaleXFontSize             : Double = height * 0.08
                let scaleXFont                 : Font   = Font.system(size: scaleXFontSize, weight: .regular, design: .rounded)
                let topY                       : Double = scaleXFontSize * 1.8
                let numberOfVisibleDays        : Int    = 16 * 7
                let tickStepX                  : Double = width / Double(numberOfVisibleDays)
                let minDate                    : Double = calendar.startOfDay(for: Date.now.addingTimeInterval(-Constants.SECONDS_PER_WEEK * 4)).timeIntervalSince1970
                let fourWeeks                  : Double = 28 * tickStepX
                var maxNoOfConferencesPerMonth : Int    = 0
                for items in self.model.conferencesPerMonth.values { maxNoOfConferencesPerMonth = max(items.count, maxNoOfConferencesPerMonth) }
                let availableHeight            : Double = height - topY
                let scaleY                     : Double = availableHeight / Double(maxNoOfConferencesPerMonth)
                let rectOffsetY                : Double = scaleY * 0.1
                let rectHeight                 : Double = scaleY * 0.8
                let valueFontSize              : Double = scaleY
                let valueFont                  : Font   = Font.system(size: valueFontSize, weight: .regular, design: .rounded)
                
                // Draw the top xAxis
                var topXAxis : Path = Path()
                topXAxis.move(to: CGPoint(x: 0, y: topY))
                topXAxis.addLine(to: CGPoint(x: width, y: topY))
                ctx.stroke(topXAxis, with: Constants.GC_GRAY)
                                
                
                for n in 0..<numberOfVisibleDays {
                    let date      : Date   = Date(timeIntervalSince1970: minDate + Double(n) * Constants.SECONDS_PER_DAY)
                    let day       : Int    = calendar.component(.day, from: date)
                    let x         : Double = Double(n) * tickStepX
                    let isToday   : Bool   = x == fourWeeks
                    let lineWidth : Double = day == 1 ? 1.0 : isToday ? 0.5 : 0.25
                    var tick      : Path   = Path()
                    tick.move(to: CGPoint(x: x, y: topY))
                    tick.addLine(to: CGPoint(x: x, y: topY + availableHeight))
                    ctx.stroke(tick, with: isToday ? Constants.GC_RED : Constants.GC_GRAY, lineWidth: lineWidth)
                    if n % 3 == 0 && n != 0 && n != numberOfVisibleDays - 1 {
                        let dayText    : Text   = Text(verbatim: "\(dateFormatter.string(from: date))")
                            .foregroundStyle(fgdColor)
                            .font(scaleXFont)
                        ctx.draw(dayText, at: CGPoint(x: x, y: topY * 0.5), anchor: .center)
                    }
                    
                    let month      : Int    = calendar.component(.month, from: date)
                    let startOfDay : Double = calendar.startOfDay(for: date).timeIntervalSince1970
                    var confCount  : Double = 0.0
                    for conference in self.model.conferencesPerMonth[month] ?? [] {
                        let startDate : Double = calendar.startOfDay(for: conference.date).timeIntervalSince1970
                        let length    : Double = tickStepX * conference.days
                        if startDate >= startOfDay && startDate + Constants.SECONDS_PER_DAY <= startOfDay + Constants.SECONDS_PER_DAY {
                            var fillColor : GraphicsContext.Shading = Constants.GC_PURPLE
                            if self.model.attendence.keys.contains(where: { $0 == conference.id }) {
                                let index : Int = self.model.attendence[conference.id] ?? 0
                                fillColor = index == 2 ? Constants.GC_GREEN : Constants.GC_PURPLE
                            }
                            let y    : Double = topY + confCount * scaleY
                            var path : Path  = Path()
                            path.addRect(CGRect(x: x, y: y + rectOffsetY, width: length, height: rectHeight))                            
                            ctx.fill(path, with: fillColor)
                            
                            let confNameText : Text = Text(verbatim: conference.name)
                                                    .foregroundStyle(fgdColor)
                                                    .font(valueFont)
                            ctx.draw(confNameText, at: CGPoint(x: x + length + 0.5, y: y + scaleY * 0.5), anchor: .leading)
                        }
                        confCount += 1.0
                    }
                }
            }
        }
    }
}
