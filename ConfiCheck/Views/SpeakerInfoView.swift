//
//  SpeakerInfoView.swift
//  ConfiCheck
//
//  Created by Gerrit Grunwald on 27.01.25.
//

import SwiftUI
import PhotosUI


struct SpeakerInfoView: View {
    @Environment(\.dismiss)      private var dismiss
    //@Environment(\.modelContext) private var context
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject           private var model             : ConfiModel
    @State                       private var speakerName       : String       = Properties.instance.speakerName!
    @State                       private var speakerBlueSky    : String       = Properties.instance.speakerBlueSky!
    @State                       private var speakerBio        : String       = Properties.instance.speakerBio!
    @State                       private var speakerExperience : String       = Properties.instance.speakerExperience!
    @State                       private var profileImage      : Image?
    @StateObject                 private var viewModel         : ProfileModel = ProfileModel()
    
    
    var body: some View {
        VStack {
            HStack {
                ShareLink(item: collectSpeakerInfo()) {
                    Label("Share Bio", systemImage: "square.and.arrow.up")
                }
                .padding()
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
            }
            
            HStack {
                Spacer()
                Text("Speaker Info")
                Spacer()
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            
            EditableCircularProfileImage(viewModel: viewModel)
            if self.profileImage != nil {
                ShareLink(item: self.profileImage!, preview: SharePreview("Profile image", image: self.profileImage!)) {
                    Label("Share Image", systemImage: "square.and.arrow.up")
                }
                .foregroundStyle(.primary)
            }
            
            Form {
                HStack {
                    Text("Name")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 80)
                    Spacer()
                    TextField("Your first name and name", text: self.$speakerName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .cornerRadius(6)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .accentColor(.accentColor)
                }
                .background(self.colorScheme == .dark ? .black : .white)
                .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                
                HStack {
                    Text("BlueSky")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 80)
                    Spacer()
                    TextField("@YOUR_BLUESKY_NAME", text: self.$speakerBlueSky)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .cornerRadius(6)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .accentColor(.accentColor)
                }
                .background(self.colorScheme == .dark ? .black : .white)
                .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                
                HStack(alignment: .top) {
                    Text("Bio")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 80)
                    Spacer()
                    TextField("Your Bio", text: self.$speakerBio, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .cornerRadius(6)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .accentColor(.accentColor)
                }
                .background(self.colorScheme == .dark ? .black : .white)
                .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                
                HStack(alignment: .top) {
                    Text("Experience")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 80)
                    Spacer()
                    TextField("Conferences you spoke at", text: self.$speakerExperience, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .cornerRadius(6)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .accentColor(.accentColor)
                }
                .background(self.colorScheme == .dark ? .black : .white)
                .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
            }
            
            Spacer()
        }
        .onAppear {
            let profileImage : Image? = Helper.loadProfileImage()
            if profileImage != nil {
                self.profileImage         = profileImage
                self.viewModel.imageState = .success(profileImage!)
            }
        }
        .onDisappear {
            Properties.instance.speakerName       = self.speakerName
            Properties.instance.speakerBlueSky    = self.speakerBlueSky
            Properties.instance.speakerBio        = self.speakerBio
            Properties.instance.speakerExperience = self.speakerExperience
        }
    }
    
    private func collectSpeakerInfo() -> String {
        var info : String = "Name:\n\(Properties.instance.speakerName!)\n\n"
        info += "Blue Sky:\n\(Properties.instance.speakerBlueSky!)\n\n"
        info += "Bio:\n\(Properties.instance.speakerBio!)\n\n"
        info += "Experience:\n\(Properties.instance.speakerExperience!)"
        return info
    }
}
