//
//  EditProfileView.swift
//  MovieListApp
//
//  Created by Yi Ling on 4/19/24.
//

import SwiftUI
import UIKit

struct EditProfileView: View {
    @EnvironmentObject var appStateVM: AppStateViewModel
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var profileRep: ProfileRepository
    @ObservedObject var leetCodeData : LeetCodeData
    
    @State var username = ""
    @State var gender = ""
    @State var mood = ""
    @State var lcUsername = ""
    @State var dummy = false
    
    var body: some View {
        ScrollView{
            Spacer()
            VStack(spacing: 16) {
                    
                HStack {
                    Spacer()
                    EditableCircularProfileImage(viewModel: profileRep)
                    Spacer()
                }
                    
                TextField("username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                TextField("gender", text: $gender)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                TextField("mood", text: $mood)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                TextField("Leetcode Username", text: $lcUsername)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                DispatchQueue.main.async {
                    profileRep.profile.username = username
                    profileRep.profile.gender = gender
                    profileRep.profile.mood = mood
                    profileRep.profile.lcUsername = lcUsername
                    switch profileRep.imageState {
                    case .empty:
                        print("Empity image!")
                    case .loading(let progress):
                        print("Loading image!")
                    case .success(let image):
                        profileRep.uploadProfileImage(image:image)
                    case .failure(let error):
                        print("Fail to load image")
                    }
                    leetCodeData.getLCData(username: profileRep.profile.lcUsername)
                    profileRep.updateProfile()
                    username = ""
                    gender = ""
                    mood = ""
                    lcUsername = ""
                }
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.vertical)
            
            if let error = appStateVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
            Spacer()
            
            
        }
        .navigationBarTitle("Profile")
        .onAppear {
            DispatchQueue.main.async {
                appStateVM.errorMessage = ""
                profileRep.subscribe()
                username = profileRep.profile.username
                gender = profileRep.profile.gender
                mood = profileRep.profile.mood
                lcUsername = profileRep.profile.lcUsername
                profileRep.setOnlineImage()
            }
        }
    }
}
