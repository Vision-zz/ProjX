//
//  DummyVC.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//

import Foundation

class DataConfiguration {

    static func dataExists() -> Bool {
        let users = try? DataManager.shared.context.fetch(User.fetchRequest())
        let teams = try? DataManager.shared.context.fetch(Team.fetchRequest())
        let tasks = try? DataManager.shared.context.fetch(TaskItem.fetchRequest())

        guard let users = users, let teams = teams, let tasks = tasks else { return false }
        if users.isEmpty || teams.isEmpty || tasks.isEmpty { return false }
        return true
    }

    static func deleteAllData() {
        let teams = try? DataManager.shared.context.fetch(Team.fetchRequest())
        guard let teams = teams else {
            return
        }
        print(teams.count)
        for team in teams {
            DataManager.shared.context.delete(team)
        }
        let users = try? DataManager.shared.context.fetch(User.fetchRequest())
        guard let users = users else {
            return
        }
        print(users.count)
        for user in users {
            DataManager.shared.context.delete(user)
        }
        let tasks = try? DataManager.shared.context.fetch(TaskItem.fetchRequest())
        guard let tasks = tasks else {
            return
        }
        print(tasks.count)
        for taskItem in tasks {
            DataManager.shared.context.delete(taskItem)
        }
        DataManager.shared.saveContext()
    }

    static func configureStuff(force: Bool) {

        if !force && dataExists() { return }
        deleteAllData()

        let names = [
            "sathya_narayanan",
            "shaheen",
            "shivaneesh",
            "sankar",
            "naveen",
            "raja_rajkumar",
            "loganathan",
            "muthu_prakash",
            "vivek_rajendran",
            "sivrish_thangamani",
            "ajith_madhan",
            "madhu_sudhanan",
            "ajay",
            "sasidharan",
            "amalan",
            "nabusan",
            "raghul",
            "arun_prasadh",
            "nithish_kumar",
            "dinesh",
            "devi",
            "durga_devi",
            "yogeshwaran",
            "avinash",
            "venu_gopal",
            "ranjith",
            "subhiksha",
            "jithin_murali",
            "shakthi_sri",
            "sriponbala",
            "mohammed_arif",
            "deebika",
            "arun_ray",
            "radhakrishnan",
            "gunaseelan",
            "surya_prakash"
        ]

        print("Creating Users")

        var users = [User]()
        for name in names {
            let user = DataManager.shared.createUser(username: name, password: "Test@123", name: name.replacingOccurrences(of: "_", with: " ").capitalized, emailID: "\(name)@gmail.com")
            switch user {
                case .success(let usr):
                    users.append(usr)
                default:
                    print("Cant create user \(name)")
            }
        }

        let teamNames = [
            "Zoho",
            "Accenture",
            "TCS",
            "Cognizant",
            "IBM",
            "Microsoft",
            "Google",
            "Meta",
            "Amazon",
            "Apple",
        ]

        print("Creating teams")

        var teams = [Team]()
        for team in teamNames {
            let user = users.randomElement()!
            let newTeam = DataManager.shared.createTeam(name: team, createdBy: user, image: nil)
            teams.append(newTeam)
        }

        print("Adding users to teams")

        for team in teams {
            var i = 0
            while i < 3 {
                let user = users.randomElement()!
                guard user.roleIn(team: team) == .none else { continue }
                team.teamAdmins.append(user)
                user.teams.append(team)
                if user.selectedTeam == nil {
                    user.selectedTeam = team
                }
                i += 1
            }

            var j = 0
            while j < 12 {
                let user = users.randomElement()!
                guard user.roleIn(team: team) == .none, !user.userTeams!.contains(team.teamID!) else { continue }
                team.teamMembers.append(user)
                user.teams.append(team)
                if user.selectedTeam == nil {
                    user.selectedTeam = team
                }
                j += 1
            }

            var tasks = [TaskItem]()
            for k in  0...15 {

                let createdBy = team.allTeamMembers.randomElement()!
                let assignedTo = createdBy.roleIn(team: team) == .member ? createdBy : team.allTeamMembers.randomElement()!

                let task = TaskItem(context: DataManager.shared.context)
                task.taskID = UUID()
                let randomDateInPreviousWeek = Date(timeInterval: TimeInterval.random(in: 0...604800), since: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
                task.createdAt = randomDateInPreviousWeek
                task.title = "Task \(k)"
                task.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 1"
                task.deadline = Date(timeInterval: TimeInterval.random(in: 0...604800), since: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
                task.createdByUser = createdBy
                task.assignedToUser = assignedTo
                task.statusUpdates = []
                if arc4random_uniform(100) < 25 {
                    task.taskStatus = .complete
                    task.completedAt = Date()
                } else {
                    task.taskStatus = .incomplete
                }
                team.tasks.append(task)

                tasks.append(task)
            }

        }



        print("saving")
        DataManager.shared.saveContext()
    }

    func dumm() {


        print("creating")

        let team1 = Team(context: DataManager.shared.context)
        team1.teamID = UUID()
        team1.teamName = "Yoho"
        team1.teamJoinPasscode = "JoinYoho"
        team1.tasks = []
        team1.teamCreatedAt = Date()

        let team2 = Team(context: DataManager.shared.context)
        team2.teamID = UUID()
        team2.teamName = "Bccenture"
        team2.teamJoinPasscode = "JoinBccenture"
        team2.tasks = []
        team2.teamCreatedAt = Date()

        let user1 = User(context: DataManager.shared.context)
        user1.userID = UUID()
        user1.username = "arun_prasadh"
        user1.password = "Test@123"
        user1.emailID = "arun@gmail.com"
        user1.name = "Arunprasadh"
        user1.notificationUpdates = []
        user1.selectedTeam = team1
        user1.createdAt = Date()

        let user2 = User(context: DataManager.shared.context)
        user2.userID = UUID()
        user2.username = "devi_ks"
        user2.password = "Test@123"
        user2.emailID = "devi.ks@gmail.com"
        user2.name = "Devi"
        user2.notificationUpdates = []
        user2.selectedTeam = team1
        user2.createdAt = Date()

        let user3 = User(context: DataManager.shared.context)
        user3.userID = UUID()
        user3.username = "sathya_jsn"
        user3.password = "Test@123"
        user3.emailID = "sathya.jd@gmail.com"
        user3.name = "Sathya Narayanan"
        user3.notificationUpdates = []
        user3.selectedTeam = team1
        user3.createdAt = Date()

        let user4 = User(context: DataManager.shared.context)
        user4.userID = UUID()
        user4.username = "madhu_s"
        user4.password = "Test@123"
        user4.emailID = "madhu.s@gmail.com"
        user4.name = "Madhu"
        user4.notificationUpdates = []
        user4.selectedTeam = team2
        user4.createdAt = Date()

        let user5 = User(context: DataManager.shared.context)
        user5.userID = UUID()
        user5.username = "sankar"
        user5.password = "Test@123"
        user5.emailID = "sankar@gmail.com"
        user5.name = "Sankar"
        user5.notificationUpdates = []
        user5.selectedTeam = team1
        user5.createdAt = Date()

        let user6 = User(context: DataManager.shared.context)
        user6.userID = UUID()
        user6.username = "shivaneesh"
        user6.password = "Test@123"
        user6.emailID = "shivaneesh@gmail.com"
        user6.name = "Shivaneesh"
        user6.notificationUpdates = []
        user6.selectedTeam = team1
        user6.createdAt = Date()

        let user7 = User(context: DataManager.shared.context)
        user7.userID = UUID()
        user7.username = "durga_devi"
        user7.password = "Test@123"
        user7.emailID = "durgadevi@gmail.com"
        user7.name = "Durga Devi"
        user7.notificationUpdates = []
        user7.selectedTeam = team1
        user7.createdAt = Date()

        let user8 = User(context: DataManager.shared.context)
        user8.userID = UUID()
        user8.username = "dinesh"
        user8.password = "Test@123"
        user8.emailID = "dinesh@gmail.com"
        user8.name = "Dinesh"
        user8.notificationUpdates = []
        user8.selectedTeam = team2
        user8.createdAt = Date()

        let user9 = User(context: DataManager.shared.context)
        user9.userID = UUID()
        user9.username = "ajay"
        user9.password = "Test@123"
        user9.emailID = "ajay@gmail.com"
        user9.name = "Ajay"
        user9.notificationUpdates = []
        user9.selectedTeam = team2
        user9.createdAt = Date()

        let user10 = User(context: DataManager.shared.context)
        user10.userID = UUID()
        user10.username = "sasi"
        user10.password = "Test@123"
        user10.emailID = "sasi.sd@gmail.com"
        user10.name = "Sasi"
        user10.notificationUpdates = []
        user10.selectedTeam = team2
        user10.createdAt = Date()

        let user11 = User(context: DataManager.shared.context)
        user11.userID = UUID()
        user11.username = "amalan"
        user11.password = "Test@123"
        user11.emailID = "amalan@gmail.com"
        user11.name = "Amalan"
        user11.notificationUpdates = []
        user11.selectedTeam = team1
        user11.createdAt = Date()

        let user12 = User(context: DataManager.shared.context)
        user12.userID = UUID()
        user12.username = "nabusan"
        user12.password = "Test@123"
        user12.emailID = "nabusan@gmail.com"
        user12.name = "Nabusan"
        user12.notificationUpdates = []
        user12.selectedTeam = team1
        user12.createdAt = Date()

        team1.teamOwner = user1
        team1.teamAdmins = [user2, user3]
        team1.teamMembers = [user5, user6, user7, user12, user11, user10]

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
        user10.teams = [team1, team2]
        user11.teams = [team1]
        user12.teams = [team1]

        let task1 = TaskItem(context: DataManager.shared.context)
        task1.taskID = UUID()
        task1.createdAt = Date()
        task1.title = "Task 1"
        task1.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 1"
        task1.deadline = Date(timeIntervalSinceNow: 300000)
        task1.createdByUser = user1
        task1.assignedToUser = user2
        task1.statusUpdates = []
        task1.taskStatus = .incomplete
        team1.tasksID?.append(task1.taskID!)

        let task2 = TaskItem(context: DataManager.shared.context)
        task2.taskID = UUID()
        task2.createdAt = Date()
        task2.title = "Task 2"
        task2.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 2"
        task2.deadline = Date(timeIntervalSinceNow: 400000)
        task2.createdByUser = user8
        task2.assignedToUser = user10
        task2.statusUpdates = []
        task2.taskStatus = .incomplete
        team2.tasksID?.append(task2.taskID!)

        let task3 = TaskItem(context: DataManager.shared.context)
        task3.taskID = UUID()
        task3.createdAt = Date()
        task3.title = "Task 3"
        task3.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 3"
        task3.deadline = Date(timeIntervalSinceNow: 700000)
        task3.createdByUser = user7
        task3.assignedToUser = user7
        task3.statusUpdates = []
        task3.taskStatus = .incomplete
        team1.tasksID?.append(task3.taskID!)

        let task4 = TaskItem(context: DataManager.shared.context)
        task4.taskID = UUID()
        task4.createdAt = Date()
        task4.title = "Task 4"
        task4.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 4"
        task4.deadline = Date(timeIntervalSinceNow: 900000)
        task4.createdByUser = user4
        task4.assignedToUser = user2
        task4.statusUpdates = []
        task4.taskStatus = .incomplete
        team2.tasksID?.append(task4.taskID!)

        let task5 = TaskItem(context: DataManager.shared.context)
        task5.taskID = UUID()
        task5.createdAt = Date()
        task5.title = "Task 5"
        task5.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 5"
        task5.deadline = Date(timeIntervalSinceNow: 200000)
        task5.createdByUser = user2
        task5.assignedToUser = user12
        task5.statusUpdates = []
        task5.taskStatus = .incomplete
        team1.tasksID?.append(task5.taskID!)


        let task6 = TaskItem(context: DataManager.shared.context)
        task6.taskID = UUID()
        task6.createdAt = Date()
        task6.title = "Task 6. This title is to test the marquee scroll of the titles if it is long"
        task6.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 6"
        task6.deadline = Date(timeIntervalSinceNow: 300000)
        task6.createdByUser = user5
        task6.assignedToUser = user5
        task6.statusUpdates = []
        task6.taskStatus = .incomplete
        team1.tasksID?.append(task6.taskID!)

        let task7 = TaskItem(context: DataManager.shared.context)
        task7.taskID = UUID()
        task7.createdAt = Date()
        task7.title = "Task 7"
        task7.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 7"
        task7.deadline = Date(timeIntervalSinceNow: 400000)
        task7.createdByUser = user4
        task7.assignedToUser = user5
        task7.statusUpdates = []
        task7.taskStatus = .incomplete
        team2.tasksID?.append(task7.taskID!)

        let task8 = TaskItem(context: DataManager.shared.context)
        task8.taskID = UUID()
        task8.createdAt = Date()
        task8.title = "Task 8"
        task8.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 8"
        task8.deadline = Date(timeIntervalSinceNow: 700000)
        task8.createdByUser = user3
        task8.assignedToUser = user8
        task8.statusUpdates = []
        task8.taskStatus = .complete
        team1.tasksID?.append(task8.taskID!)

        let task9 = TaskItem(context: DataManager.shared.context)
        task9.taskID = UUID()
        task9.createdAt = Date()
        task9.title = "Task 9"
        task9.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 9"
        task9.deadline = Date(timeIntervalSinceNow: 900000)
        task9.createdByUser = user8
        task9.assignedToUser = user10
        task9.statusUpdates = []
        task9.taskStatus = .complete
        team2.tasksID?.append(task9.taskID!)

        let task10 = TaskItem(context: DataManager.shared.context)
        task10.taskID = UUID()
        task10.createdAt = Date()
        task10.title = "Task 10"
        task10.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 10"
        task10.deadline = Date(timeIntervalSinceNow: 200000)
        task10.createdByUser = user2
        task10.assignedToUser = user11
        task10.statusUpdates = []
        task10.taskStatus = .complete
        team1.tasksID?.append(task10.taskID!)

        let task11 = TaskItem(context: DataManager.shared.context)
        task11.taskID = UUID()
        task11.createdAt = Date()
        task11.title = "Task 11"
        task11.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task 11"
        task11.deadline = Date(timeIntervalSinceNow: 200000)
        task11.createdByUser = user2
        task11.assignedToUser = user2
        task11.statusUpdates = []
        task11.taskStatus = .complete
        team2.tasksID?.append(task10.taskID!)

    }
}

