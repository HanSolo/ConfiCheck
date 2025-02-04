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
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject           private var model             : ConfiModel
    @StateObject                 private var viewModel         : ProfileModel = ProfileModel()
    @State                       private var speakerName       : String       = Properties.instance.speakerName!
    @State                       private var speakerBlueSky    : String       = Properties.instance.speakerBlueSky!
    @State                       private var speakerBio        : String       = Properties.instance.speakerBio!
    @State                       private var speakerExperience : String       = Properties.instance.speakerExperience!
    @State                       private var profileUIImage    : UIImage? {
        didSet {
            debugPrint("Profile uiimage set")
        }
    }
    @State                       private var profileImage      : Image? {
        didSet {
            debugPrint("Profile image set")
        }
    }
    @State                       private var showNotice        : Bool         = false
    
    
    private let pasteBoard = UIPasteboard.general
    
    
    var body: some View {
        ZStack {
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
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    Spacer()
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                EditableCircularProfileImage(viewModel: viewModel)
                if self.profileImage != nil {
                    HStack(alignment: .center, spacing: 20) {
                        ShareLink(item: self.profileImage!, preview: SharePreview("Profile image", image: self.profileImage!)) {
                            Label("Share Image", systemImage: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        .foregroundStyle(.primary)
                        
                        Button {
                            pasteBoard.image = self.profileUIImage!
                            self.showNotice = true
                        } label: {
                            Label("Copy Image", systemImage: "document.on.document")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        .foregroundStyle(.primary)
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                }
                
                Form {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Name")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                pasteBoard.string = self.speakerName                                
                                showNotice = true
                            } label: {
                                Label("", systemImage: "document.on.document")
                                    .font(.system(size: 10, weight: .light, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .frame(minWidth: 16, maxWidth: 16)
                        }
                        
                        TextField("Your first name and name", text: self.$speakerName, axis: .vertical)
                            .disableAutocorrection(true)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .cornerRadius(5)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .accentColor(.accentColor)
                    }
                    .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                    
                    VStack(alignment: .leading) {
                        Divider()
                        HStack {
                            Text("BlueSky")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                pasteBoard.string = self.speakerBlueSky
                                self.showNotice = true
                            } label: {
                                Label("", systemImage: "document.on.document")
                                    .font(.system(size: 10, weight: .light, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .frame(minWidth: 16, maxWidth: 16)
                        }
                                                                
                        TextField("@YOUR_BLUESKY_NAME", text: self.$speakerBlueSky, axis: .vertical)
                            .disableAutocorrection(true)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .cornerRadius(5)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .accentColor(.accentColor)
                    }
                    .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                                    
                    VStack(alignment: .leading) {
                        Divider()
                        HStack(alignment: .top) {
                            Text("Bio")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                pasteBoard.string = self.speakerBio
                                self.showNotice = true
                            } label: {
                                Label("", systemImage: "document.on.document")
                                    .font(.system(size: 10, weight: .light, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .frame(minWidth: 16, maxWidth: 16)
                        }
                    
                        TextField("Your Bio", text: self.$speakerBio, axis: .vertical)
                            .disableAutocorrection(true)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .cornerRadius(5)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .accentColor(.accentColor)
                    }
                    .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                    
                    VStack(alignment: .leading) {
                        Divider()
                        HStack {
                            Text("Experience")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                pasteBoard.string = self.speakerName
                                self.showNotice = true
                            } label: {
                                Label("", systemImage: "document.on.document")
                                    .font(.system(size: 10, weight: .light, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .frame(minWidth: 16, maxWidth: 16)
                        }
                        
                        TextField("Conferences you spoke at", text: self.$speakerExperience, axis: .vertical)
                            .disableAutocorrection(true)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .cornerRadius(5)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .accentColor(.accentColor)
                    }
                    .listRowBackground(self.colorScheme == .dark ? Color.black : Color.white)
                }
                
                Spacer()
            }
            if showNotice {
                FloatingNotice(showNotice: $showNotice)
                    .zIndex(1)
            }
        }
        .background(self.colorScheme == .dark ? .black : .white)
        .scrollContentBackground(.hidden)
        .onAppear {
            let profileUIImage : UIImage? = Helper.loadProfileUIImage()
            //let profileImage : Image? = Helper.loadProfileImage()
            if profileUIImage != nil {
                self.profileUIImage       = profileUIImage!
                self.profileImage         = Image(uiImage: profileUIImage!)
                self.viewModel.imageState = .success(profileImage!)
            } else {
                debugPrint("profileImage == nil")
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
