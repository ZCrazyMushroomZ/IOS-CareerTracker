//
//  AppGeneralView.swift
//  CareerTracker
//
//  Created by Yi Ling on 5/2/24.
//

import Foundation
import SwiftUI

struct AppGeneralView: View {
    @ObservedObject var appStateVM : AppStateViewModel
    @ObservedObject var profileRep : ProfileRepository
    @State var isSheetPresented = false
    @State var dummy = false
    
    var body: some View {
        VStack(alignment:.leading){
            VStack(alignment:.leading){
                Text("Applications")
                    .font(.title)
                    .bold()
                    .padding(.leading, 10)
            }
            List{
                ForEach(Array(profileRep.profile.userApplications.applicationsList.enumerated()), id: \.1.id){ (idx, item) in
                    NavigationLink{
                        ApplicationItemDetailView(appStateVM: appStateVM, profileRep: profileRep,applicationItem:item)
                    } label: {
                        HStack{
                           Text("\(idx + 1).")
                               .alignmentGuide(.leading) { _ in 0 }
                               .padding(.trailing, 8)
                               .frame(width: 30, alignment: .leading)
                               .font(.headline)
                               .foregroundColor(.secondary)
                           Text("\(item.companyName)")
                               .alignmentGuide(.leading) { _ in 0 }
                               .padding(.trailing, 8)
//                                .font(.body)
                               .font(.system(size: 18))
                               .foregroundColor(.primary)
                               .bold()
                           Spacer()
                           Text("\(item.roleName)")
                               .alignmentGuide(.leading) { _ in 0 }
                               .font(.callout)
                               .foregroundColor(.gray)
                               .bold()
                       }
                       .padding(.vertical, 8)
                    }
                    .swipeActions {
                        Button {
                            DispatchQueue.main.async {
                                if profileRep.profile.userApplications.applicationsList.indices.contains(idx){
                                    profileRep.profile.userApplications.applicationsList.remove(at: idx)
                                    print(profileRep.profile.userApplications.applicationsList)
                                    profileRep.updateProfile()
                                }
                            }
                        }label: {
                            Text("Delete")
                                .padding()
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
            Button {
                isSheetPresented = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("Add New Application")
                }
                .padding()
            }
            .sheet(isPresented: $isSheetPresented) {
                NavigationStack {
                    var newApplication = ApplicationItem()
                    ApplicationItemDetailView(appStateVM: appStateVM, profileRep: profileRep,applicationItem:newApplication)
                        .onDisappear{
                            DispatchQueue.main.async {
                                profileRep.profile.userApplications.applicationsList.append(newApplication)
                                print(profileRep.profile.userApplications.applicationsList)
                                profileRep.updateProfile()
                                dummy.toggle()
                            }
                        }
                }
            }
        }
    }
}
