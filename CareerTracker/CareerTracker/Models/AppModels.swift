//
//  Movies.swift
//  MovieListApp
//
//  Created by Yi Ling on 2/24/24.
//
import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

class Profile: ObservableObject, Identifiable, Codable {
    @DocumentID var id: String?
    @Published var username: String = ""
    @Published var lcUsername: String = ""
    @Published var gender: String = ""
    @Published var mood: String = ""
    @Published var picUrl: String = ""
    @Published var userApplications = ApplicationsList()

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case gender
        case mood
        case picUrl
        case lcUsername
        case userApplications
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        gender = try container.decode(String.self, forKey: .gender)
        mood = try container.decode(String.self, forKey: .mood)
        picUrl = try container.decode(String.self, forKey: .picUrl)
        lcUsername = try container.decode(String.self, forKey: .lcUsername)
        userApplications = try container.decode(ApplicationsList.self, forKey: .userApplications)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(gender, forKey: .gender)
        try container.encode(mood, forKey: .mood)
        try container.encode(picUrl, forKey: .picUrl)
        try container.encode(lcUsername, forKey: .lcUsername)
        try container.encode(userApplications, forKey: .userApplications)
    }
}

class ApplicationsList: ObservableObject, Identifiable, Codable{
    @Published var applicationsList : [ApplicationItem] = []
    
    enum CodingKeys: String, CodingKey {
        case applicationList
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        applicationsList = try container.decode([ApplicationItem].self, forKey: .applicationList)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(applicationsList, forKey: .applicationList)
    }
    
}

class ApplicationItem: ObservableObject, Identifiable, Codable{
    @Published var companyName = ""
    @Published var roleName = ""
    @Published var submissionDate = Date()
    @Published var updateDate = Date()
    @Published var status = 0
    
    enum CodingKeys: String, CodingKey {
        case companyName
        case submissionDate
        case updateDate
        case roleName
        case status
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        companyName = try container.decode(String.self, forKey: .companyName)
        roleName = try container.decode(String.self, forKey: .roleName)
        submissionDate = try container.decode(Date.self, forKey: .submissionDate)
        updateDate = try container.decode(Date.self, forKey: .updateDate)
        status = try container.decode(Int.self, forKey: .status)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(companyName, forKey: .companyName)
        try container.encode(roleName, forKey: .roleName)
        try container.encode(submissionDate, forKey: .submissionDate)
        try container.encode(updateDate, forKey: .updateDate)
        try container.encode(status, forKey: .status)
    }
}

class LeetCodeData: ObservableObject, Identifiable, Decodable{
    @Published var lcData = DataItem()
    
    enum CodingKeys: String, CodingKey {
        case lcData = "data"
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lcData = try container.decode(DataItem.self, forKey: .lcData)
    }
    
    func getLCData(username:String){
        DispatchQueue.main.async {
            self.downloadData(username:username) { results in
                self.lcData = results.lcData
            }
        }
    }
    
    func downloadData(username: String, completed: @escaping (LeetCodeData) -> () ) {
        let url = URL(string: "https://leetcode.com/graphql?query=query getUserProfile{ allQuestionsCount { difficulty count } matchedUser(username: \"\(username)\") { username submitStats { totalSubmissionNum { difficulty count submissions } acSubmissionNum { difficulty count submissions } } } recentSubmissionList(username: \"\(username)\", limit: 20) { title titleSlug timestamp statusDisplay lang } }")
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                guard let jsondata = data else { return }
                do {
                    let results = try JSONDecoder().decode(LeetCodeData.self, from: jsondata)
                    print("LC data download successful!")
                    DispatchQueue.main.async {
                        completed(results)
                    }
                }catch {
                    print("LC data Downloading Error!")
                }
            }
        }.resume()
    }
}

class DataItem:ObservableObject, Identifiable, Decodable {
    @Published var allQuestionsCount : [QuestionCountItem] = []
    @Published var matchedUser = matchedUserItem()
    @Published var recentSubmissionList : [LeetCodeItemModel] = []
    
    enum CodingKeys: String, CodingKey {
        case allQuestionsCount
        case matchedUser
        case recentSubmissionList
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        allQuestionsCount = try container.decode([QuestionCountItem].self, forKey: .allQuestionsCount)
        matchedUser = try container.decode(matchedUserItem.self, forKey: .matchedUser)
        recentSubmissionList = try container.decode([LeetCodeItemModel].self, forKey: .recentSubmissionList)
    }
}

class QuestionCountItem:ObservableObject, Identifiable, Decodable{
    @Published var difficulty = ""
    @Published var count = 0
    
    enum CodingKeys: String, CodingKey {
        case difficulty
        case count
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        count = try container.decode(Int.self, forKey: .count)
    }
}

class matchedUserItem: ObservableObject, Identifiable, Decodable  {
    @Published var submitStats = submitStatsModel()
    
    enum CodingKeys: String, CodingKey {
        case submitStats
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        submitStats = try container.decode(submitStatsModel.self, forKey: .submitStats)
    }
}

class submitStatsModel: ObservableObject, Identifiable, Decodable  {
    @Published var totalSubmissionNum : [submissionNumModel] = []
    @Published var acSubmissionNum : [submissionNumModel] = []
    
    enum CodingKeys: String, CodingKey {
        case totalSubmissionNum
        case acSubmissionNum
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalSubmissionNum = try container.decode([submissionNumModel].self, forKey: .totalSubmissionNum)
        acSubmissionNum = try container.decode([submissionNumModel].self, forKey: .acSubmissionNum)
    }
}

class submissionNumModel: ObservableObject, Identifiable, Decodable  {
    @Published var difficulty = ""
    @Published var count = 0
    @Published var submissions = 0
    
    enum CodingKeys: String, CodingKey {
        case difficulty
        case count
        case submissions
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        count = try container.decode(Int.self, forKey: .count)
        submissions = try container.decode(Int.self, forKey: .submissions)
    }
}

class LeetCodeItemModel: ObservableObject, Identifiable, Decodable{
    @Published var title = ""
    @Published var titleSlug = ""
    @Published var statusDisplay = ""
    @Published var lang = ""
    
    enum CodingKeys: String, CodingKey {
        case title
        case titleSlug
        case statusDisplay
        case lang
    }

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        titleSlug = try container.decode(String.self, forKey: .titleSlug)
        statusDisplay = try container.decode(String.self, forKey: .statusDisplay)
        lang = try container.decode(String.self, forKey: .lang)
    }
}



