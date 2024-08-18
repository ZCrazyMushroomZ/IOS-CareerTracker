//
//  ContentView.swift
//  MovieListApp
//
//  Created by Yi Ling on 2/24/24.
//

import SwiftUI

struct TopView: View {
    @State var updateView = false
    @ObservedObject var appStateVM = AppStateViewModel()
    @State var chosenType: String? = "null"
    @State var profileRep = ProfileRepository()
    @State var isEditViewPresented = false
    @State var page = 0
    @ObservedObject var leetCodeData = LeetCodeData()
    
    var body: some View {
        if appStateVM.isSignedIn {
            NavigationView{
                VStack(alignment:.leading){
                    if page == 0{
                        AppGeneralView(appStateVM: appStateVM, profileRep: profileRep)
                    } else if page == 1{
                        LeetCodeView(appStateVM: appStateVM, profileRep: profileRep, leetCodeData: leetCodeData)
                    } else {
                        LeetCodeAnalyticsView(appStateVM: appStateVM, profileRep: profileRep, leetCodeData: leetCodeData)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Text(appStateVM.currentUserEmail)
                            Button("Profile"){
                                isEditViewPresented.toggle()
                            }
                            Button{
                                DispatchQueue.main.async{
                                    profileRep.unsubscribe()
                                    appStateVM.signOut()
                                }
                            } label: {
                                Text("Sign Out")
                            }
                        } label: {
                            Image(systemName: "person.fill")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            page = 2
                        } label: {
                            Image(systemName: "chart.bar.fill")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            page = 1
                        } label: {
                            Image(systemName: "list.number")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            page = 0
                        } label: {
                            Image(systemName: "note.text")
                        }
                    }
                }
                .sheet(isPresented: $isEditViewPresented) {
                    EditProfileView(profileRep: profileRep,leetCodeData : leetCodeData)
                }
            }
            .onAppear{
                leetCodeData.getLCData(username: profileRep.profile.lcUsername)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(appStateVM)
            .onAppear{
                profileRep.subscribe()
            }
        }
        else {
            LoginView(profileRep:profileRep, leetCodeData: leetCodeData).environmentObject(appStateVM)
        }
    }
    
}

#Preview {
    TopView()
}
