//
//  MenuProvider.swift
//  ProjX
//
//  Created by Sathya on 29/03/23.
//

import UIKit

class MenuProvider {
    static func getTeamProfileOptionsMenu(for team: Team, delegate: TeamOptionsDelegate?) -> UIMenu {
        let menuElement = UIDeferredMenuElement.uncached { [weak delegate] completion in
            var children: [UIMenuElement] = []

            let selectTitle = team.isSelected ? "Selected" : "Select"
            let image = team.isSelected ? UIImage(systemName: "checkmark.circle") : nil
            children.append(UIAction(title: selectTitle, image: image, attributes: team.isSelected ? [.disabled] : []) { _ in
                delegate?.teamSelectButtonPressed()
            })

            if SessionManager.shared.signedInUser!.isOwner(team) {
                children.append(UIAction(title: "Edit", image: UIImage(systemName: "")) { _ in
                    delegate?.teamEditButtonPressed()
                })
            }

            let exitTitle = SessionManager.shared.signedInUser!.isOwner(team) ? "Delete" : "Leave"
            let exitImage = SessionManager.shared.signedInUser!.isOwner(team) ? UIImage(systemName: "trash") : UIImage(systemName: "rectangle.portrait.and.arrow.right")
            children.append(UIAction(title: exitTitle, image: exitImage, attributes: .destructive) { _ in
                delegate?.teamExitButtonPressed()
            })

            completion(children)
        }

        let menu = UIMenu(children: [menuElement])
        return menu
    }
}
