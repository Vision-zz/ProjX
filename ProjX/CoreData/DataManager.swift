//
//  DataRouter.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import CoreData
import UIKit

class DataManager {

    static let shared: DataManager = DataManager()

    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let saveContext: () -> Void = (UIApplication.shared.delegate as! AppDelegate).saveContext

    private init() {}

    func getAllUsers() -> [User] {
        let users = try? context.fetch(User.fetchRequest())
        guard let users = users else { return [] }
        return users
    }

}
