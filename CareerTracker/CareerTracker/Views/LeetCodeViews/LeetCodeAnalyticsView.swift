//
//  LeetCodeAnalyticsView.swift
//  CareerTracker
//
//  Created by Yi Ling on 5/2/24.
//

import SwiftUI
import SwiftUICharts

struct LeetCodeAnalyticsView: View {
    @ObservedObject var appStateVM : AppStateViewModel
    @ObservedObject var profileRep : ProfileRepository
    @ObservedObject var leetCodeData: LeetCodeData
    @State var inputData : [(String, Double)] = [("Easy", 0.0), ("Medium", 0.0), ("Hard", 0.0)]
    @State var totalPassed = 0
    @State var dummy = false
    @State var ratioData : [(String, Double)] = [("Easy", 0.0), ("Medium", 0.0), ("Hard", 0.0), ("All", 0.0)]
    @State var rawData : [[Int]] = [[0, 0], [0, 0], [0, 0], [0, 0]]
    
    
    var body: some View {
        VStack(alignment:.leading){
            if dummy {
                VStack(alignment:.leading){
                    Text("Solved: \(totalPassed)")
                        .font(.title)
                        .bold()
                        .padding(.horizontal, 30)
                }
                VStack{
                    BarChartView(data: ChartData(values: inputData), title: "Solved", form: ChartForm.extraLarge)
                        .padding()
                    BarChartView(data: ChartData(values: ratioData), title: "Accepted Rate", form: ChartForm.extraLarge)
                        .padding(30)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear{
            for item in leetCodeData.lcData.matchedUser.submitStats.acSubmissionNum{
                if item.difficulty == "Easy"{
                    inputData[0] = ("Easy", Double(item.count))
                    rawData[0][0] = item.submissions
                } else if item.difficulty == "Medium" {
                    inputData[1] = ("Medium", Double(item.count))
                    rawData[1][0] = item.submissions
                } else if item.difficulty == "Hard" {
                    inputData[2] = ("Hard", Double(item.count))
                    rawData[2][0] = item.submissions
                } else {
                    totalPassed = item.count
                    rawData[3][0] = item.submissions
                }
            }
            for item in leetCodeData.lcData.matchedUser.submitStats.totalSubmissionNum{
                if item.difficulty == "Easy"{
                    rawData[0][1] = item.submissions
                    if rawData[0][1] != 0{
                        ratioData[0] = ("Easy", Double(rawData[0][0] * 100/rawData[0][1]))
                    }
                } else if item.difficulty == "Medium" {
                    rawData[1][1] = item.submissions
                    if rawData[1][1] != 0{
                        ratioData[1] = ("Medium", Double(rawData[1][0] * 100/rawData[1][1]))
                    }
                } else if item.difficulty == "Hard" {
                    rawData[2][1] = item.submissions
                    if rawData[2][1] != 0{
                        ratioData[2] = ("Hard", Double(rawData[2][0] * 100/rawData[2][1]))
                    }
                } else {
                    rawData[3][1] = item.submissions
                    if rawData[3][1] != 0{
                        ratioData[3] = ("All", Double(rawData[3][0] * 100/rawData[3][1]))
                    }
                }
            }
            print(rawData,ratioData)
            dummy.toggle()
        }
    }
}
