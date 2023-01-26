//
//  ContentModel.swift
//  LearningApp
//
//  Created by Christopher Ching on 2021-03-03.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCore

class ContentModel: ObservableObject {
    
    let db = Firestore.firestore()
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current lesson explanation
    @Published var codeText = NSAttributedString()
    var styleData: Data?
    
    // Current selected content and test
    @Published var currentContentSelected:Int?
    @Published var currentTestSelected:Int?
    
    
    init() {
        
        // Parse local included json data
        getLocalStyles()
        
        getDatabaseModules()
        
        // Download remote json file and parse data
        // getRemoteData()
    }
    
    // MARK: - Data methods
    
    // Getting/Parsing the JSON data from Firebae ONLY when user has clicked into something(Lessons view)
    func getDatabaseLessons(module: Module, completion: @escaping () -> Void) {
        
        // Specify path -- /modules/documentID/subcollection/documentID
        let collection = db.collection("modules").document(module.id).collection("lessons")
    
        // Get documents
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Array to track lessons
                var lessons = [Lesson]()
                
                // Loop through the doucments and build array of lessons
                for doc in snapshot!.documents {
                    
                    // New lesson
                    var l = Lesson()
                    
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // Add the lesson to the array
                    lessons.append(l)
                }
                
                // Setting lessons to the module
                // Loop through published modules array and find the one that matches the id of the copy that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // Find the module we want
                    if m.id == module.id {
                        
                        // Set the lessons
                        self.modules[index].content.lessons = lessons
                        
                        // Call the completion closure
                        completion()
                    }
                }
                
            }
        }
    }
    
    // Getting/Parsing the JSON data from Firebae ONLY when user has clicked into something(Lessons view)
    func getDatabaseQuestions(module: Module, completion: @escaping () -> Void) {
        
        // Specify path -- /modules/documentID/subcollection/documentID
        let collection = db.collection("modules").document(module.id).collection("questions")
    
        // Get documents
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Array to track questions
                var questions = [Question]()
                
                // Loop through the doucments and build array of lessons
                for doc in snapshot!.documents {
                    
                    // New question
                    var q = Question()
                    
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    
                    // Add the question to the array
                    questions.append(q)
                }
                
                // Setting question to the module
                // Loop through published modules array and find the one that matches the id of the copy that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // Find the module we want
                    if m.id == module.id {
                        
                        // Set the question
                        self.modules[index].test.questions = questions
                        
                        // Call the completion closure
                        completion()
                    }
                }
                
            }
        }
         
    }
    
    
    // Getting database modules - (collections)
    func getDatabaseModules() {
        
        // Specify path to collections - modules
        let collection = db.collection("modules")
        
        // Getting documents in modules collection
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Create an array for the modules
                var modules = [Module]()
                
                // Loop through the documents returned
                for doc in snapshot!.documents {
                    
                    // Create a new module instance
                    var m = Module()
                    
                    // Parse out the values from the document into the module instance
                    // id is the field in the document
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // Parse the lesson content(field)
                    let contentMap = doc["content"] as! [String: Any]
                    
                    
                    // Parsing the lesson field's values
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    // Parse the test content(field)
                    let testMap = doc["test"] as! [String: Any]
                    
                    // Parsing the test field's  values
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // Add it to our array
                    modules.append(m)
                }
                
                // Assign our modules to the published property
                DispatchQueue.main.async {
                    
                    self.modules = modules
                    
                }
                
            }
        }
        
    }
    
    
    //func getLocalData() {
    func getLocalStyles() {
        /*
        // Get a url to the json file
        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")
        
        do {
            // Read the file into a data object
            let jsonData = try Data(contentsOf: jsonUrl!)
            
            // Try to decode the json into an array of modules
            let jsonDecoder = JSONDecoder()
            let modules = try jsonDecoder.decode([Module].self, from: jsonData)
            
            // Assign parsed modules to modules property
            self.modules = modules
        }
        catch {
            // TODO log error
            print("Couldn't parse local data")
        }
        
        */ // Keeping Parsing style data
        
        // Parse the style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            
            // Read the file into a data object
            let styleData = try Data(contentsOf: styleUrl!)
            
            self.styleData = styleData
        }
        catch {
            // Log error
            print("Couldn't parse style data")
        }
        
    }
    
    func getRemoteData() {
        
        // String path
        let urlString = "https://codewithchris.github.io/learningapp-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // Couldn't create url
            return
        }
        
        // Create a URLRequest object
        let request = URLRequest(url: url!)
        
        // Get the session and kick off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            // Check if there's an error
            guard error == nil else {
                // There was an error
                return
            }
            
            do {
                // Create json decoder
                let decoder = JSONDecoder()
            
                // Decode
                let modules = try decoder.decode([Module].self, from: data!)
                
                DispatchQueue.main.async {
                    
                    // Append parsed modules into modules property
                    self.modules += modules
                }
                
            }
            catch {
                // Couldn't parse json
            }
        }
        
        // Kick off data task
        dataTask.resume()
        
    }
    
    // MARK: - Module navigation methods
    
    func beginModule(_ moduleid:String) {
        
        // Find the index for this module id
        for index in 0..<modules.count {
            
            if modules[index].id == moduleid {
            
                // Found the matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
    }
    
    func beginLesson(_ lessonIndex:Int) {
        
        // Check that the lesson index is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        
        // Set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStyling(currentLesson!.explanation)
    }
    
    func nextLesson() {
        
        // Advance the lesson index
        currentLessonIndex += 1
        
        // Check that it is within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            
            // Set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
        }
        else {
            // Reset the lesson state
            currentLessonIndex = 0
            currentLesson = nil
        }
    }
    
    func hasNextLesson() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    func beginTest(_ moduleId:String) {
        
        // Set the current module
        beginModule(moduleId)
        
        // Set the current question index
        currentQuestionIndex = 0
        
        // If there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0  > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            
            // Set the question content
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    func nextQuestion() {
        
        // Advance the question index
        currentQuestionIndex += 1
        
        // Check that it's within the range of questions
        if currentQuestionIndex < currentModule!.test.questions.count {
            
            // Set the current question
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
        }
        else {
            // If not, then reset the properties
            currentQuestionIndex = 0
            currentQuestion = nil
        }
        
    }
    
    // MARK: - Code Styling
    
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        // Add the styling data
        if styleData != nil {
            data.append(styleData!)
        }
        
        // Add the html data
        data.append(Data(htmlString.utf8))
        
        // Convert to attributed string
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            
            resultString = attributedString
        }
        
        return resultString
    }
}
