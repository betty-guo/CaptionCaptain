//
//  MainImageSelecterViewController.swift
//  UglySweaterApp
//
//  Created by Cristian Palage on 2021-01-15.
//

import Foundation
import UIKit

class MainImageSelectorViewController: UIViewController {

    var button: UIButton = {
        let button = UIButton()
        button.setTitle("Take an image", for: .normal)
        button.addTarget(self, action: "getImage", for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        return button
    }()

    var secondaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get my ugly", for: .normal)
        button.addTarget(self, action: "nextPage", for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()



    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView)
        self.containerView.addSubview(button)
        self.containerView.addSubview(secondaryButton)
        self.containerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            button.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: button.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            secondaryButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            secondaryButton.topAnchor.constraint(equalTo: imageView .bottomAnchor),
            secondaryButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        ])
    }
}

extension MainImageSelectorViewController {
    @objc func getImage() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    @objc func nextPage() {
        let vc = PrivacyPolicyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainImageSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        image = ResizeImage(image!, targetSize: CGSize(width: view.frame.width, height: 400))
        imageView.image = image
        self.dismiss(animated: true, completion: nil)

    }
}


func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size

    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
}
