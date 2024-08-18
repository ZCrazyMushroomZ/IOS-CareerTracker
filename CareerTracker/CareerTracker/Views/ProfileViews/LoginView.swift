//
//  LoginView.swift
//  MovieListApp
//
//  Created by Yi Ling on 4/19/24.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var appStateVM: AppStateViewModel
    @ObservedObject var profileRep: ProfileRepository
    @ObservedObject var leetCodeData : LeetCodeData
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack(spacing: 16) {
                    
                    Image("icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 40)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                }
                .padding(.horizontal)
                
                Button(action: {
                    DispatchQueue.main.async{
                        appStateVM.login(email: email, password: password)
                    }
                }) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                NavigationLink(destination: SignUpView(profileRep:profileRep, leetCodeData : leetCodeData).environmentObject(appStateVM))
                {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                
                if let error = appStateVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                
            }
            .navigationBarTitle("Log In")
            .onAppear {
                appStateVM.errorMessage = ""
            }
        }
        
        
    }
}

