//
//  MainImageSelecterViewController.swift
//  UglySweaterApp
//
//  Created by Cristian Palage on 2021-01-15.
//

import Foundation
import UIKit
import Firebase

class MainImageSelectorViewController: UIViewController {

    var currentImage: UIImage?

    var resultsText: [String] = [String]() {
        didSet {
            guard !resultsText.isEmpty else { return }
            getCaption(for: getCaptionRequest(words: resultsText)) { [weak self] (result) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self?.showImageAndCaption(response)
                    }
                    return
                case .failure(let error):
                    return
                }
            }
        }
    }

    lazy var vision = Vision.vision()

    var button: UIButton = {
        let button = UIButton()
        button.setTitle("Take an image", for: .normal)
        button.addTarget(self, action: #selector(UIImagePickerController.takePicture), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 60)
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }()

    var secondaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Camera roll", for: .normal)
        button.addTarget(self, action: Selector(("getImage")), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 60)
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }()

    var tertiaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Find me an AI caption!", for: .normal)
        button.addTarget(self, action: Selector(("nextPage")), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 60)
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
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
        //setUpNavigationControllerBarButtonItem()

        self.view.addSubview(containerView)
        self.containerView.addSubview(imageView)

        self.containerView.addSubview(button)
        self.containerView.addSubview(secondaryButton)
        self.containerView.addSubview(tertiaryButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            imageView.topAnchor.constraint(equalTo: self.containerView.safeAreaLayoutGuide.topAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            imageView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -15)
        ])

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            button.bottomAnchor.constraint(equalTo: tertiaryButton.topAnchor, constant: -10),
            button.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -5),
            button.heightAnchor.constraint(equalToConstant: button.frame.height)
        ])

        NSLayoutConstraint.activate([
            secondaryButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 5),
            secondaryButton.bottomAnchor.constraint(equalTo: tertiaryButton.topAnchor, constant: -10),
            secondaryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            secondaryButton.heightAnchor.constraint(equalToConstant: secondaryButton.frame.height)
        ])


        NSLayoutConstraint.activate([
            tertiaryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            tertiaryButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tertiaryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            tertiaryButton.heightAnchor.constraint(equalToConstant: tertiaryButton.frame.height)
        ])



        button.layer.cornerRadius = 20
        secondaryButton.layer.cornerRadius = 20
        tertiaryButton.layer.cornerRadius = 20
        imageView.layer.cornerRadius = 20
    }
}

extension MainImageSelectorViewController {
    @objc func getImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    @objc func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    @objc func dismissDetailsVC() {
        self.dismiss(animated: true)
    }

    func showImageAndCaption(_ caption: String) {
        let vc = DetailsViewController(caption: caption, image: self.currentImage ?? UIImage())
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.setValue(true, forKey: "hidesShadow")
        navController.title = "Settings"
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissDetailsVC))

        self.navigationController!.present(navController, animated: true, completion: nil)
    }
    

    @objc func nextPage() {
        clearResults()

        let options = VisionCloudTextRecognizerOptions()
        options.modelType = .dense
        detectTextInCloud(image: imageView.image, options: options)

        detectDocumentTextInCloud(image: imageView.image)

        detectCloudLabels(image: imageView.image)


        detectCloudLandmarks(image: imageView.image)
    }

    func clearResults() {
        self.resultsText = []
    }

    func setUpNavigationControllerBarButtonItem() {

        let rightBarButtonItem: UIBarButtonItem = {
            let bbi = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
            return bbi
        }()
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc func openSettings() {
        return
    }
}

extension MainImageSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        currentImage = image
        //image = ResizeImage(image!, targetSize: CGSize(width: view.frame.width, height: 400))
        imageView.image = image
        self.dismiss(animated: true, completion: nil)

    }
}


extension MainImageSelectorViewController {

    private func transformMatrix() -> CGAffineTransform {
        guard let image = imageView.image else { return CGAffineTransform() }
        let imageViewWidth = imageView.frame.size.width
        let imageViewHeight = imageView.frame.size.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        let imageViewAspectRatio = imageViewWidth / imageViewHeight
        let imageAspectRatio = imageWidth / imageHeight
        let scale = (imageViewAspectRatio > imageAspectRatio)
            ? imageViewHeight / imageHeight : imageViewWidth / imageWidth

        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
        let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)

        var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
        transform = transform.scaledBy(x: scale, y: scale)
        return transform
    }

    private func pointFrom(_ visionPoint: VisionPoint) -> CGPoint {
        return CGPoint(x: CGFloat(visionPoint.x.floatValue), y: CGFloat(visionPoint.y.floatValue))
    }

    private func process(_ visionImage: VisionImage, with textRecognizer: VisionTextRecognizer?) {
        textRecognizer?.process(visionImage) { text, error in
            guard error == nil, let text = text else {
                return
            }
            let words = self.stringParse(words: text.text)
            self.resultsText.append(contentsOf: words)
        }
    }

    private func process(_ visionImage: VisionImage, with documentTextRecognizer: VisionDocumentTextRecognizer?) {
        documentTextRecognizer?.process(visionImage) { text, error in
            guard error == nil, let text = text else {
                return
            }
            let words = self.stringParse(words: text.text)
            self.resultsText.append(contentsOf: words)
        }
    }

    func stringParse(words: String) -> [String] {
        var returnArray = [String]()
        let wordsArray = Array(words)
        var word = ""

        for character in wordsArray {
            if character != "\n" && character != " " {
                word.append(character)
            } else {
                returnArray.append(word.lowercased())
                word = ""
            }
        }

        return returnArray
    }
}

extension MainImageSelectorViewController {

    func detectTextInCloud(image: UIImage?, options: VisionCloudTextRecognizerOptions? = nil) {
        guard let image = image else { return }

        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)

        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata

        var cloudTextRecognizer: VisionTextRecognizer?
        var modelTypeString = Constants.sparseTextModelName
        if let options = options {
            modelTypeString = (options.modelType == .dense)
                ? Constants.denseTextModelName : modelTypeString
            cloudTextRecognizer = vision.cloudTextRecognizer(options: options)
        } else {
            cloudTextRecognizer = vision.cloudTextRecognizer()
        }

        process(visionImage, with: cloudTextRecognizer)
    }

    func detectDocumentTextInCloud(image: UIImage?) {
        guard let image = image else { return }

        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)

        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata

        let cloudDocumentTextRecognizer = vision.cloudDocumentTextRecognizer()

        process(visionImage, with: cloudDocumentTextRecognizer)
    }

    func detectCloudLandmarks(image: UIImage?) {
        guard let image = image else { return }

        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)

        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata

        let options = VisionCloudDetectorOptions()
        options.modelType = .stable
        options.maxResults = 20

        let cloudDetector = vision.cloudLandmarkDetector(options: options)

        cloudDetector.detect(in: visionImage) { landmarks, error in
            guard error == nil, let landmarks = landmarks, !landmarks.isEmpty else {
                return
            }

            self.resultsText.append(contentsOf: landmarks.map({ $0.landmark ?? "" }))
        }
    }

    func detectCloudLabels(image: UIImage?) {
        guard let image = image else { return }

        let cloudLabeler = vision.cloudImageLabeler()
        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)

        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata

        cloudLabeler.process(visionImage) { labels, error in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                return
            }

            self.resultsText.append(contentsOf: labels.map({ $0.text }))
        }
    }
}

// MARK: - Enums

private enum DetectorPickerRow: Int {
    case detectTextInCloudSparse = 0

    case
        detectTextInCloudDense,
        detectDocumentTextInCloud,
        detectImageLabelsInCloud,
        detectLandmarkInCloud

    static let rowsCount = 5
    static let componentsCount = 1

    public var description: String {
        switch self {
        case .detectTextInCloudSparse:
            return "Text in Cloud (Sparse)"
        case .detectTextInCloudDense:
            return "Text in Cloud (Dense)"
        case .detectDocumentTextInCloud:
            return "Document Text in Cloud"
        case .detectImageLabelsInCloud:
            return "Image Labeling in Cloud"
        case .detectLandmarkInCloud:
            return "Landmarks in Cloud"
        }
    }
}

private enum Constants {

    static let detectionNoResultsMessage = "No results returned."
    static let sparseTextModelName = "Sparse"
    static let denseTextModelName = "Dense"

    static let labelConfidenceThreshold: Float = 0.75
    static let smallDotRadius: CGFloat = 5.0
    static let largeDotRadius: CGFloat = 10.0
    static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.clear.cgColor
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
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
