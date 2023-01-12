//
//  StorageManager.swift
//  A.Prudnikova-HW28-
//
//  Created by Ann Prudnikova on 12.01.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error: \(error)")
        }
    }
    
    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self)//.sorted(byKeyPath: "name")
    }
    
    static func saveTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                realm.add(tasksList)
            }
        } catch {
            print("saveTasksList error: \(error)")
        }
    }
    
    static func deleteList(_ tasksList: TasksList) {
        do {
            try realm.write {
                let tasks = tasksList.tasks
                // последовательно удаляем tasks и tasksList
                realm.delete(tasks)
                realm.delete(tasksList)
            }
        } catch {
            print("deleteList error: \(error)")
        }
    }
    
    static func editList(_ tasksList: TasksList,
                         newListName: String,
                         complition: @escaping () -> Void) {
        do {
            try realm.write {
                tasksList.name = newListName
                complition()
            }
        } catch {
            print("editList error: \(error)")
        }
    }
}
