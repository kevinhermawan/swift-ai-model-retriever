//
//  AppViewModel.swift
//  Playground
//
//  Created by Kevin Hermawan on 10/14/24.
//

import Foundation

@Observable
final class AppViewModel {
    var cohereAPIKey: String
    var groqAPIKey: String
    var openaiAPIKey: String
    
    init() {
        self.cohereAPIKey = UserDefaults.standard.string(forKey: "cohereAPIKey") ?? ""
        self.groqAPIKey = UserDefaults.standard.string(forKey: "groqAPIKey") ?? ""
        self.openaiAPIKey = UserDefaults.standard.string(forKey: "openaiAPIKey") ?? ""
    }
    
    func saveAPIKeys() {
        UserDefaults.standard.set(cohereAPIKey, forKey: "cohereAPIKey")
        UserDefaults.standard.set(groqAPIKey, forKey: "groqAPIKey")
        UserDefaults.standard.set(openaiAPIKey, forKey: "openaiAPIKey")
    }
}
