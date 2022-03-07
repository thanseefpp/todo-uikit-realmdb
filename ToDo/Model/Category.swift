//
//  Category.swift
//  ToDo
//
//  Created by THANSEEF on 06/03/22.
//

import Foundation
import RealmSwift


class Category : Object {
    @objc dynamic var name : String = ""
//    @objc dynamic var descData : String = ""
    @objc dynamic var colorpicked : String = ""
    
    //relationship creating to the category table.
    let items = List<TodoModel>()
}
