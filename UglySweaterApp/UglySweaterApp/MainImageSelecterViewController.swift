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

    var resultsText: [String] = [String]() {
        didSet {
            print(resultsText)
            getCaption(for: getCaptionRequest(words: resultsText)) { [weak self] (result) in
                switch result {
                case .success(let response):
                    return
                case .failure(let error):
                    return
                }
            }
        }
    }

    lazy var vision = Vision.vision()

    // Image counter.
    var currentImage = 0

    var button: UIButton = {
        let button = UIButton()
        button.setTitle("Take an image", for: .normal)
        button.addTarget(self, action: Selector(("getImage")), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        return button
    }()

    var secondaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get my ugly", for: .normal)
        button.addTarget(self, action: Selector(("nextPage")), for: .touchUpInside)
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
}

extension MainImageSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        image = ResizeImage(image!, targetSize: CGSize(width: view.frame.width, height: 400))
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
