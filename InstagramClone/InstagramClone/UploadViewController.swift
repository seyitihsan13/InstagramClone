//
//  UploadViewController.swift
//  InstagramClone
//
//  Created by İhsan Elkatmış on 1.07.2022.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textfield: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(chooseimage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        photo.isUserInteractionEnabled = true
        let gestureRecognizerr =  UITapGestureRecognizer(target: self, action: #selector(choosephotos))
        photo.addGestureRecognizer(gestureRecognizerr)
        
    }
    @objc func chooseimage(){
       let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
        @objc func choosephotos(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
    
    func makerAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageRefence = storage.reference()
        
        let mediaFolder = storageRefence.child("media")
        
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuıd = UUID().uuidString
            
            let imageReferance = mediaFolder.child("\(uuıd).jpg")
            imageReferance.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makerAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                } else {
                    
                    imageReferance.downloadURL { (url, error) in
                        
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            
                            //DATABASE
                            
                            let firestoreDatabase = Firestore.firestore()
                            
                            var firestoreReference : DocumentReference? = nil
                            
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.textfield.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0 ] as [String : Any]
                                                 
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                    
                                    self.makerAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                    
                                } else {
                                    
                                    self.imageView.image = UIImage(named: "select.png")
                                    self.textfield.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                    
                                }
                            })
                            
                            
                            
                            
                            
                            
                        }
                    }
                    
                }
            }
            
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
