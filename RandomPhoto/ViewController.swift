//
//  ViewController.swift
//  RandomPhoto
//
//  Created by Vivek Mhatre on 1/29/23.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    let catImageView = UIImageView(frame: CGRect(x: 50, y: 200, width: 300, height: 300))
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black
        button.setTitle("Change Color", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black
        button.setTitle("Like", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let dislikeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black
        button.setTitle("Dislike", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private var currentImageURL: String = ""
        
    private var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ref = Database.database().reference().child("liked_photos")
        ref = Database.database().reference()
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        view.addSubview(likeButton)
        
        dislikeButton.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
        view.addSubview(dislikeButton)
        
        catImageView.contentMode = .scaleAspectFit
        catImageView.center = view.center
        view.addSubview(catImageView)
        
        getRandomPhoto()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button.frame = CGRect(
            x: 30,
            y: view.frame.size.height-150-view.safeAreaInsets.bottom,
            width: view.frame.size.width-60,
            height: 60
        )
        
        likeButton.frame = CGRect(
            x: view.frame.size.width/2 + 30,
            y: view.frame.size.height-80-view.safeAreaInsets.bottom,
            width: view.frame.size.width/2-60,
            height: 60
        )
        
        dislikeButton.frame = CGRect(
            x: 30,
            y: view.frame.size.height-80-view.safeAreaInsets.bottom,
            width: view.frame.size.width/2-60,
            height: 60
        )

    }
    
    @objc func buttonTapped(_ sender: Any) {
        let randomColor = UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
        view.backgroundColor = randomColor
        getRandomPhoto()
    }
    
    @objc func likeButtonTapped(_ sender: Any) {
        // child reference to store liked photos
        
        let likedPhotosReference = ref.child("likedPhotos")
        let k = likedPhotosReference.childByAutoId().key
        
        likedPhotosReference.child(k!).setValue(currentImageURL) { (error, reference) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            print("Success: Liked photo URL stored in Firebase with key: \(k!)")
        }
        view.backgroundColor = UIColor.systemPink
    }
    
    @objc func dislikeButtonTapped(_ sender: Any) {
        // child reference to store liked photos
        
        let dislikedPhotosReference = ref.child("dislikedPhotos")
        let k = dislikedPhotosReference.childByAutoId().key
        
        dislikedPhotosReference.child(k!).setValue(currentImageURL) { (error, reference) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            print("Success: Disliked photo URL stored in Firebase with key: \(k!)")
        }
        view.backgroundColor = UIColor.systemGray
    }
    
    func getRandomPhoto() {
        let url = URL(string: "https://api.thecatapi.com/v1/images/search?size=med")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error: Invalid data or response")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let catAPIResponse = try decoder.decode([CatImage].self, from: data)
                self?.currentImageURL = catAPIResponse[0].url
                let imageURL = URL(string: catAPIResponse[0].url)!
                let imageData = try Data(contentsOf: imageURL)
                DispatchQueue.main.async {
                    self?.catImageView.image = UIImage(data: imageData)
                }
            } catch {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
}

struct CatImage: Decodable {
    let url: String
}







