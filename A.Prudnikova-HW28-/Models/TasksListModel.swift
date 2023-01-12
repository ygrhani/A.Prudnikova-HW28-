//
//  TasksList.swift
//  A.Prudnikova-HW28-
//
//  Created by Ann Prudnikova on 12.01.23.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

