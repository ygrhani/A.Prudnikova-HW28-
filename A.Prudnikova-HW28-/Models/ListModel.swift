//
//  ListModel.swift
//  A.Prudnikova-HW28-
//
//  Created by Ann Prudnikova on 12.01.23.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
