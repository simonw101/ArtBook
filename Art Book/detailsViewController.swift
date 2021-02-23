//
//  detailsViewController.swift
//  Art Book
//
//  Created by Simon Wilson on 22/02/2021.
//

import UIKit
import CoreData

class detailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var artistTextField: UITextField!
    
    var chosenPainting = ""
    
    var chosenPaintingId : UUID?
    
    @IBOutlet weak var savedButton: UIButton!
    
@IBOutlet weak var yearTextField: UITextField!
    override func viewDidLoad() {
       super.viewDidLoad()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        if chosenPainting != "" {

            savedButton.isHidden = true
            
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
            
            if let context = appDelegate?.persistentContainer.viewContext {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
                
                let idString = chosenPaintingId?.uuidString
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        
                        for result in results as! [NSManagedObject] {
                            
                            if let name = result.value(forKey: "name") as? String {
                                
                                nameTextField.text = name
                                
                            }
                            
                            if let artist = result.value(forKey: "artist") as? String {
                                
                                artistTextField.text = artist
                                
                            }
                            
                            if let year = result.value(forKey: "year") as? Int {
                                
                                yearTextField.text = String(year)
                                
                            }
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                
                                let image = UIImage(data: imageData)
                                
                                imageView.image = image
                                
                            }
                            
                        }
                        
                    }
                    
                } catch {
                    
                    print("unable to retrieve data")
                    
                }
                
               
                
            }
            
        } else {
            
            savedButton.isHidden = false
            savedButton.isEnabled = false
            nameTextField.text = ""
            yearTextField.text = ""
            artistTextField.text = ""
            
        }
    }
    
    @objc func selectImage() {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        
        savedButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func saveClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = appDelegate?.persistentContainer.viewContext {
            
            let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
            
            newPainting.setValue(nameTextField.text, forKey: "name")
            
            newPainting.setValue(artistTextField.text, forKey: "artist")
            
            if let year  = Int(yearTextField.text!) {
            
                newPainting.setValue(year, forKey: "year")
                
            }
            
            newPainting.setValue(UUID(), forKey: "id")
            
            let data = imageView.image?.jpegData(compressionQuality: 0.5)
            
            newPainting.setValue(data, forKey: "image")
            
            do {
                
                try context.save()
                
                print("success")
                
            } catch {
                
                print("could not save")
                
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        
            
        }
        
        
    }
    
    @objc func hideKeyBoard() {
        
        view.endEditing(true)
        
    }
}
