//
//  TodoModel.swift
//  ToDo
//
//  Created by THANSEEF on 06/03/22.
//

import Foundation
import RealmSwift

class TodoModel : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateTime : Date?
//    @objc dynamic var colorstore : String = ""
    // inverse relationship to the category table items.
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
