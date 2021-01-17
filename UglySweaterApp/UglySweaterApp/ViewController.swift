//
//  ViewController.swift
//  UglySweaterApp
//
//  Created by Cristian Palage on 2021-01-15.
//

import UIKit
import UIKit


class DetailsViewController: UIViewController {

    var caption: String
    let keys: [String]
    let image: UIImage

    init(caption: String, image: UIImage, keys: [String]) {
        self.caption = caption
        self.image = image
        self.keys = keys
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let textView: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.backgroundColor = .white
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 20)
        lb.numberOfLines = 100
        return lb
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var randomButton: UIButton = {
        let button = UIButton()
        button.setTitle("Random Caption", for: .normal)
        button.addTarget(self, action: Selector(("randomCaption")), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 60)
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }()

    var tryAgainButton: UIButton = {
        let button = UIButton()
        button.setTitle("Try again", for: .normal)
        button.addTarget(self, action: Selector(("tryAgain")), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 60)
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }()


    override func viewDidLoad() {

        self.view.backgroundColor = .white
        super.viewDidLoad()
        self.view.addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(imageView)
        containerView.addSubview(randomButton)
        containerView.addSubview(tryAgainButton)

        imageView.image = image
        textView.text = caption

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            randomButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 15),
            randomButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15)
        ])

        NSLayoutConstraint.activate([
            tryAgainButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -15),
            tryAgainButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            imageView.topAnchor.constraint(equalTo: self.containerView.safeAreaLayoutGuide.topAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])


        imageView.layer.cornerRadius = 20
    }

    @objc func randomCaption() {
        getCaption(for: getCaptionRequest(words: ["funny"])) { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    self?.caption = response
                    self?.textView.text = response
                }
                return
            case .failure(let error):
                return
            }
        }
    }

    @objc func tryAgain() {
        getCaption(for: getCaptionRequest(words: keys)) { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.caption = response
                    self?.textView.text = response
                }
                return
            case .failure(let error):
                return
            }
        }
    }
}






