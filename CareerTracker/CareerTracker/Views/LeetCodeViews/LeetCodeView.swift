//
//  LeetCodeView.swift
//  CareerTracker
//
//  Created by Yi Ling on 5/2/24.
//

import SwiftUI

struct LeetCodeView: View {
    @ObservedObject var appStateVM : AppStateViewModel
    @ObservedObject var profileRep : ProfileRepository
    @ObservedObject var leetCodeData: LeetCodeData
    
    var body: some View {
        VStack(alignment:.leading){
            VStack(alignment:.leading){
                Text("Recent Submissions")
                    .font(.title)
                    .bold()
                    .padding(.leading, 10)
            }
            List{
                ForEach(Array(leetCodeData.lcData.recentSubmissionList.enumerated()), id: \.1.id){ (idx, item) in
                    HStack{
                        Text("\(idx + 1)")
                            .alignmentGuide(.leading) { _ in 0 }
                            .padding(.trailing, 8)
                            .frame(width: 30, alignment: .leading)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(item.title)")
                            .alignmentGuide(.leading) { _ in 0 }
                            .padding(.trailing, 8)
                            .font(.body)
                            .foregroundColor(.primary)
                            .bold()
                        
                        Spacer()
                        Text("\(item.statusDisplay)")
                            .font(.callout)
                            .foregroundColor(item.statusDisplay == "Accepted" ? .green : .red)
                            .bold()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
