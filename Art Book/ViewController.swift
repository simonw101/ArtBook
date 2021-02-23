//
//  ViewController.swift
//  Art Book
//
//  Created by Simon Wilson on 20/02/2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedPaintingid : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
        
    }
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
            
        if let context = appDelegate?.persistentContainer.viewContext {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            
                            nameArray.append(name)
                            
                        }
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            idArray.append(id)
                            
                        }
                        
                        tableView.reloadData()
                        
                    }
                    
                }
                
            } catch {
                
                print("Unable to retrieve data")
                
            }
            
        }
        
    }
    
    
    @objc func addButtonClicked() {
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            
            let destinationVC = segue.destination as? detailsViewController
            destinationVC?.chosenPainting = selectedPainting
            destinationVC?.chosenPaintingId = selectedPaintingid
            
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingid = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appdelegate = (UIApplication.shared.delegate as? AppDelegate)
            
            if let context = appdelegate?.persistentContainer.viewContext {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
                
                let idString = idArray[indexPath.row].uuidString
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
                
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        
                        for result in results as! [NSManagedObject] {
                            
                            if let id = result.value(forKey: "id") as? UUID {
                                
                                if id == idArray[indexPath.row] {
                                    
                                    context.delete(result)
                                    
                                    nameArray.remove(at: indexPath.row)
                                    
                                    idArray.remove(at: indexPath.row)
                                    
                                    self.tableView.reloadData()
                                    
                                    do {
                                        
                                        try context.save()
                                        
                                    } catch {
                                        
                                        print("unable to save")
                                        
                                    }
                                    
                                    break
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                } catch {
                    
                    print("unable to delete")
                    
                }
                
            }
            
        }
    }
    
}

