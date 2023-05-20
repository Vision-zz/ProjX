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
        print("Deleting \(teams.count) teams")
        for team in teams {
            DataManager.shared.context.delete(team)
        }
        let users = try? DataManager.shared.context.fetch(User.fetchRequest())
        guard let users = users else {
            return
        }
        print("Deleting \(users.count) users")
        for user in users {
            DataManager.shared.context.delete(user)
        }
        let tasks = try? DataManager.shared.context.fetch(TaskItem.fetchRequest())
        guard let tasks = tasks else {
            return
        }
        print("Deleting \(tasks.count) tasks")
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
            "surya_prakash",
            "chandru",
            "franklin_ajay",
            "senthil",
            "aravindan",
            "amalwin_aseer",
            "johny_prince",
            "kovil_pillai",
            "subash",
            "sharan_kumar",
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
            "Wipro",
            "Infosys",
            "L&T",
            "Tech Mahindra",
            "Flipkart",
            "Mindtree",
            "HCL",
            "Deloitte",
            "Oracle",
            "Hexaware Technologies",
            "Capgemini",
            "Airtel",
            "Intel",
            "Vodafone",
            "Reliance Jio"
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
            while j < 15 {
                let user = users.randomElement()!
                guard user.roleIn(team: team) == .none, !user.userTeams!.contains(team.teamID!) else { continue }
                team.teamMembers.append(user)
                user.teams.append(team)
                if user.selectedTeam == nil {
                    user.selectedTeam = team
                }
                j += 1
            }

            let tasksCount = Int.random(in: 75...100)
            print("Configuring \(tasksCount) for \(team.teamName!)")
            for k in  0...tasksCount {
                let createdBy = team.allTeamMembers.randomElement()!
                let assignedTo = createdBy.roleIn(team: team) == .member ? createdBy : team.allTeamMembers.randomElement()!

                let task = TaskItem(context: DataManager.shared.context)
                task.taskID = UUID()
                
                let currentDate = Date()
                let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: currentDate)!
                let createdAt = Date(timeInterval: TimeInterval(arc4random_uniform(UInt32(currentDate.timeIntervalSince(threeYearsAgo)))), since: threeYearsAgo)
                task.createdAt = createdAt
                
                let threeYears: TimeInterval = 3 * 365 * 24 * 60 * 60 // 3 years in seconds
                let futureDate = Date(timeIntervalSinceNow: threeYears)
                let deadline = Date(timeIntervalSince1970: TimeInterval.random(in: currentDate.timeIntervalSince1970...futureDate.timeIntervalSince1970))
                task.deadline = deadline
                
                task.title = "Task \(k)"
                task.taskDescription = "This is a task that needs to be finished within a particular amount of time. This task is named task \(k)"
                task.createdByUser = createdBy
                task.assignedToUser = assignedTo
                
                let priority = Int16.random(in: 0...2)
                task.taskPriority = TaskPriority(rawValue: priority) ?? .low
                
                if Int.random(in: 0...100) < 30 {
                    task.taskStatus = .complete
                    task.completedAt = Date()
                } else {
                    task.taskStatus = .inProgress
                }
                
                let statusUpdateCount = Int.random(in: 10...20)
                
                var statusUpdates = [TaskStatusUpdate]()
                for n in 0...statusUpdateCount {
                    let statusUpdate = TaskStatusUpdate(context: DataManager.shared.context)
                    statusUpdate.subject = "Status update \(n)"
                    statusUpdate.statusDescription = "This is a new status update, this is updated on some day and some time. This is the \(n) update"
                    let start = createdAt.timeIntervalSince1970
                    let end = Date().timeIntervalSince1970
                    let randomTimeInterval = TimeInterval.random(in: min(start, end)...max(start, end))
                    let randomDate = Date(timeIntervalSince1970: randomTimeInterval)
                    statusUpdate.createdAt = randomDate
                    statusUpdates.append(statusUpdate)
                }
                
                task.statusUpdates = statusUpdates
                
                team.tasks.append(task)
            }
        }

        print("Saving")
        DataManager.shared.saveContext()
    }
}

