//
//  DummyVC.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//

import UIKit

class DummyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        configureStuff()
        fetchStuff()
    }

    func fetchStuff() {
        let users = try? DataManager.shared.context.fetch(User.fetchRequest())
        print(users?.count ?? -1)
        print(users![0].name)
        let teams = try? DataManager.shared.context.fetch(Team.fetchRequest())
        print(teams?.count ?? -1)
    }

    func configureStuff() {

        print("creating")
        
        let team1 = Team(context: DataManager.shared.context)
        team1.teamID = UUID()
        team1.categories = ["Very High Priority", "High Priority", "Regular Priority", "Low Priority"]
        team1.teamName = "Yoho"
        team1.teamJoinPasscode = "JoinYoho"
        team1.tasks = []

        let team2 = Team(context: DataManager.shared.context)
        team2.teamID = UUID()
        team2.categories = ["Important", "Normal", "Less Important"]
        team2.teamName = "Bccenture"
        team2.teamJoinPasscode = "JoinBccenture"
        team2.tasks = []

        let user1 = User(context: DataManager.shared.context)
        user1.userID = UUID()
        user1.username = "arun_prasadh"
        user1.password = "Test@123"
        user1.emailID = "arun@gmail.com"
        user1.name = "Arunprasadh"

        let user2 = User(context: DataManager.shared.context)
        user2.userID = UUID()
        user2.username = "devi_ks"
        user2.password = "Test@123"
        user2.emailID = "devi.ks@gmail.com"
        user2.name = "Devi"

        let user3 = User(context: DataManager.shared.context)
        user3.userID = UUID()
        user3.username = "sathya_jsn"
        user3.password = "Test@123"
        user3.emailID = "sathya.jd@gmail.com"
        user3.name = "Sathya Narayanan"

        let user4 = User(context: DataManager.shared.context)
        user4.userID = UUID()
        user4.username = "madhu_s"
        user4.password = "Test@123"
        user4.emailID = "madhu.s@gmail.com"
        user4.name = "Madhu"

        let user5 = User(context: DataManager.shared.context)
        user5.userID = UUID()
        user5.username = "sankar"
        user5.password = "Test@123"
        user5.emailID = "sankar@gmail.com"
        user5.name = "Sankar"

        let user6 = User(context: DataManager.shared.context)
        user6.userID = UUID()
        user6.username = "shivaneesh"
        user6.password = "Test@123"
        user6.emailID = "shivaneesh@gmail.com"
        user6.name = "Shivaneesh"

        let user7 = User(context: DataManager.shared.context)
        user7.userID = UUID()
        user7.username = "durga_devi"
        user7.password = "Test@123"
        user7.emailID = "durgadevi@gmail.com"
        user7.name = "DurgaDevi"

        let user8 = User(context: DataManager.shared.context)
        user8.userID = UUID()
        user8.username = "dinesh"
        user8.password = "Test@123"
        user8.emailID = "dinesh@gmail.com"
        user8.name = "Dinesh"

        let user9 = User(context: DataManager.shared.context)
        user9.userID = UUID()
        user9.username = "ajay"
        user9.password = "Test@123"
        user9.emailID = "ajay@gmail.com"
        user9.name = "Ajay"

        let user10 = User(context: DataManager.shared.context)
        user10.userID = UUID()
        user10.username = "sasi"
        user10.password = "Test@123"
        user10.emailID = "sasi.sd@gmail.com"
        user10.name = "Sasi"

        let user11 = User(context: DataManager.shared.context)
        user11.userID = UUID()
        user11.username = "amalan"
        user11.password = "Test@123"
        user11.emailID = "amalan@gmail.com"
        user11.name = "Amalan"

        let user12 = User(context: DataManager.shared.context)
        user12.userID = UUID()
        user12.username = "nabusan"
        user12.password = "Test@123"
        user12.emailID = "nabusan@gmail.com"
        user12.name = "Nabusan"

        team1.teamOwner = user1
        team1.teamAdmins = [user2, user3]
        team1.teamMembers = [user5, user6, user7]

        team2.teamOwner = user4
        team2.teamAdmins = [user5, user8]
        team2.teamMembers = [user2, user9, user10]

        user1.teams = [team1]
        user2.teams = [team1, team2]
        user3.teams = [team1]
        user4.teams = [team2]
        user5.teams = [team1, team2]
        user6.teams = [team1]
        user7.teams = [team1]
        user8.teams = [team2]
        user9.teams = [team2]
        user10.teams = [team2]
        user11.teams = []
        user12.teams = []

        print("saving")
        DataManager.shared.saveContext()
    }

}
