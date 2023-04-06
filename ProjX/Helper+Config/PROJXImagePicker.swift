//
//  PROJXImagePicker.swift
//  ProjX
//
//  Created by Sathya on 30/03/23.
//

import UIKit
import PhotosUI

class PROJXImagePicker {

    static let shared = PROJXImagePicker()

    typealias CompletionHandler = (UIImage?) -> Void

    private var completion: CompletionHandler? = nil

    lazy var config: PHPickerConfiguration = {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.any(of: [.images, .screenshots, .depthEffectPhotos])
        config.selectionLimit = 1
        return config
    }()


    private init() { }

    func presentPicker(from viewController: UIViewController, handler: @escaping CompletionHandler) {
        self.completion = handler
        viewController.present(createPicker(), animated: true)
    }

    private func createPicker() -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        return picker
    }
}

extension PROJXImagePicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        DispatchQueue.main.async {
            picker.dismiss(animated: true)
        }
        guard !results.isEmpty, let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion?(nil)
            completion = nil
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            self?.completion?(image as? UIImage)
            self?.completion = nil
        }
    }

}

