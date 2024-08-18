//
//  ApplicationItemDetailView.swift
//  CareerTracker
//
//  Created by Yi Ling on 5/2/24.
//

import Foundation
import SwiftUI

struct ApplicationItemDetailView: View {
    @ObservedObject var appStateVM : AppStateViewModel
    @ObservedObject var profileRep : ProfileRepository
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var applicationItem: ApplicationItem
    @State var companyName = ""
    @State var roleName = ""
    @State var submissionDate = Date()
    @State var updateDate = Date()
    @State var status = 0
    let statusOptions = ["Not Created", "Submitted", "OA received", "interview scheduled","offer", "rejected"]
    
    
    var body: some View {
        ScrollView{
            Spacer()
            VStack(spacing: 16) {
                  
                TextField("Company", text: $companyName)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                TextField("Role", text: $roleName)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                DatePicker("Submission Date", selection: $submissionDate, displayedComponents: [.date])
                DatePicker("Last Update", selection: $updateDate, displayedComponents: [.date])
                HStack{
                    Text("Status")
                    Spacer()
                    Picker(selection: $status, label: Text("Application status")) {
                       ForEach(0..<statusOptions.count) { index in
                           Text(self.statusOptions[index]).tag(index)
                       }
                   }
               }
                
            }
            .padding(.horizontal)
            
            Button(action: {
                DispatchQueue.main.async {
                    applicationItem.companyName = companyName
                    applicationItem.roleName = roleName
                    applicationItem.submissionDate = submissionDate
                    applicationItem.updateDate = updateDate
                    applicationItem.status = status
                    companyName = ""
                    roleName = ""
                    submissionDate = Date()
                    updateDate = Date()
                    status = -1
                    profileRep.updateProfile()
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
        .navigationBarTitle("Application")
        .onAppear {
            DispatchQueue.main.async {
                appStateVM.errorMessage = ""
                companyName = applicationItem.companyName
                roleName = applicationItem.roleName
                submissionDate = applicationItem.submissionDate
                updateDate = applicationItem.updateDate
                status = applicationItem.status
            }
        }
    }
}
