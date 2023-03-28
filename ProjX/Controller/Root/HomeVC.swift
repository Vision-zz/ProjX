//
//  HomeVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeVC: PROJXCollectionViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    enum CollectionViewElement {
        static let headerKind = "CollectionViewHeaderKind"
        static let headerReuseIdentifier = "CollectionViewHeader"
    }

    struct SectionData {
        let sectionName: String
        let sectionIndex: Int
        var rows: [TaskItem]
        var sortRowsBy: ((TaskItem, TaskItem) -> Bool)? {
            didSet {
                guard let sortRowsBy = sortRowsBy else { return }
                rows.sort(by: sortRowsBy)
            }
        }
    }

    var dataSource: [SectionData] = []

    var emptyPlaceholder: [(large: String, secondary: String)] = [
        ("Don't see anything?", "Great! You don't have any upcoming tasks"),
        ("Can't find what you're looking for?", "Create some tasks to view them here"),
        ("No tasks?", "Create a task for yourself and be productive"),
        ("Hmm.. There's nothing here?", "Looks like you don't have much tasks assigned to you"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureDatasource()
        updateHomeLayout()
        registerSubviews()
    }

    private func registerSubviews() {
        self.collectionView.register(HomeCollectionViewTaskCell.self, forCellWithReuseIdentifier: HomeCollectionViewTaskCell.identifier)
        self.collectionView.register(HomeCollectionViewEmptyPlaceholderCell.self, forCellWithReuseIdentifier: HomeCollectionViewEmptyPlaceholderCell.identifier)
        self.collectionView.register(HomeCollectionViewHeaderView.self, forSupplementaryViewOfKind: CollectionViewElement.headerKind, withReuseIdentifier: CollectionViewElement.headerReuseIdentifier)
    }

    private func configureUI() {
        title = "Home"
    }

    private func updateHomeLayout() {
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { [unowned self] (section, environment) in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupWidth: NSCollectionLayoutDimension = .fractionalWidth(dataSource[section].rows.count == 0 ? 1 : GlobalConstants.Device.isIpad ? 0.232 : 0.43)
            let groupHeight: NSCollectionLayoutDimension = .fractionalWidth(dataSource[section].rows.count == 0 ? 1 :GlobalConstants.Device.isIpad ? 0.18 : 0.30)
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(GlobalConstants.Device.isIpad ? 0.10 : 0.20))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: CollectionViewElement.headerKind, alignment: .top)

            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.boundarySupplementaryItems = [sectionHeader]
            layoutSection.interGroupSpacing = 12
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

            layoutSection.orthogonalScrollingBehavior = self.dataSource[section].rows.count == 0 ? .none : .continuousGroupLeadingBoundary
            return layoutSection
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(sectionProvider: provider, configuration: config)
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    private func configureDatasource() {
        let selectedTeam = SessionManager.shared.signedInUser?.selectedTeam
        guard let selectedTeam = selectedTeam else { return }
        guard !selectedTeam.tasks.isEmpty else { return }

        var upcomingTasks = [TaskItem]()
        var recentlyCreated = [TaskItem]()
        var createdByYou = [TaskItem]()
        var otherTasks = [TaskItem]()

        for task in selectedTeam.tasks {
            let assignedToYouCondition = task.assignedTo != nil && task.assignedTo!.userID == SessionManager.shared.signedInUser?.userID
            let upcomingTaskCondition = task.deadline! < Date().addingTimeInterval(3 * 24 * 60 * 60 * 1000)
            let recentlyCreatedCondition = task.createdAt!.isToday()
            let createdByYouCondition = task.createdBy != nil && task.createdBy!.userID == SessionManager.shared.signedInUser?.userID

            if  upcomingTaskCondition && assignedToYouCondition {
                upcomingTasks.append(task)
            }
            if recentlyCreatedCondition && assignedToYouCondition {
                recentlyCreated.append(task)
            }
            if createdByYouCondition && assignedToYouCondition {
                createdByYou.append(task)
            }
            if !upcomingTaskCondition && !recentlyCreatedCondition && !createdByYouCondition && assignedToYouCondition {
                otherTasks.append(task)
            }
        }

        dataSource.append(SectionData(sectionName: "Upcoming Tasks", sectionIndex: 0, rows: upcomingTasks))
        dataSource.append(SectionData(sectionName: "Recently Created", sectionIndex: 1, rows: recentlyCreated))
        dataSource.append(SectionData(sectionName: "Created by You", sectionIndex: 2, rows: createdByYou))
        dataSource.append(SectionData(sectionName: "Other Tasks", sectionIndex: 3, rows: otherTasks))
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].rows.count == 0 ? 1 : dataSource[section].rows.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataSource[indexPath.section].rows.count == 0 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewEmptyPlaceholderCell.identifier, for: indexPath) as! HomeCollectionViewEmptyPlaceholderCell
            cell.configureTitles(large: emptyPlaceholder[indexPath.section].large, secondary: emptyPlaceholder[indexPath.section].secondary)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewTaskCell.identifier, for: indexPath) as! HomeCollectionViewTaskCell
        cell.data = dataSource[indexPath.section].rows[indexPath.row]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewElement.headerReuseIdentifier, for: indexPath)
        return headerView
    }


    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }

}
