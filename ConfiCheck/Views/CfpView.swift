//
//  CfpView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 22.01.25.
//

import SwiftUI

struct CfpView: View {
    @State var endDate : Date?
    @State var link    : String?
    
    let formatter : DateFormatter
    
    
    init(endDate: Date?, link: String?) {
        self.endDate = endDate
        self.link    = link
        formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd MM yyyy")
    }
    

    var body: some View {
        if endDate == nil {
            Spacer()
        } else {
            HStack {
                HStack {
                    Text("CFP")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.primary)
                    if link != nil || !link!.isEmpty {
                        Link(destination: URL(string: self.link!)!) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.primary)
                                .rotationEffect(.degrees(90))
                        }
                    }
                    
                    Text(verbatim: "\(self.formatter.string(from: self.endDate!))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                        .background(
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 5,
                                    style       : .continuous
                                )
                                .fill(Helper.getColorForCfpDate(date: self.endDate!))
                                RoundedRectangle(
                                    cornerRadius: 5,
                                    style       : .continuous
                                )
                                .stroke(Helper.getColorForCfpDate(date: self.endDate!), lineWidth: 1)
                            }
                        )
                    }
                }
                .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                .background(
                    ZStack {
                        RoundedRectangle(
                            cornerRadius: 5,
                            style       : .continuous
                        )
                        .fill(.tertiary)
                        RoundedRectangle(
                            cornerRadius: 5,
                            style       : .continuous
                        )
                        .stroke(.tertiary)
                    }
                )
                Spacer()
            }
        }
    }

