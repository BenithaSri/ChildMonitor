//
//  RestrictedAreasViewController.swift
//  ChildCareApp
//
//  Created by Piyush on 21/02/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class RestrictedAreasViewController: UIViewController {

    @IBOutlet weak var noRecordLBL: UILabel!
    @IBOutlet weak var locationsTV: UITableView!
    
    var childData: ChildModel?
    
    var restrictedLocations: [RestrictedLocationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getRestrictedLocations()
    }
    
    func getRestrictedLocations() {
    guard let id = Auth.auth().currentUser?.uid, !id.isEmpty,
          let child_id = childData?.id, !child_id.isEmpty else {
        print("Invalid parent or child ID")
        return
    }

    let database = Firestore.firestore()
    let docRef = database.collection("Restricted_Locations")
        .whereField("parent_id", isEqualTo: id)
        .whereField("child_id", isEqualTo: child_id)

    docRef.getDocuments { (querySnapshot, error) in
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()

            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            self.restrictedLocations = querySnapshot?.documents.compactMap { document in
                let data = document.data()
                return RestrictedLocationModel(
                    id: document.documentID,
                    parent_id: data["parent_id"] as? String ?? "",
                    child_id: data["child_id"] as? String ?? "",
                    title: data["title"] as? String ?? "",
                    address: data["address"] as? String ?? "",
                    lat: data["lat"] as? Double ?? 0.0,
                    lng: data["lng"] as? Double ?? 0.0
                )
            } ?? []

            let hasRecords = !self.restrictedLocations.isEmpty
            self.locationsTV.isHidden = !hasRecords
            self.noRecordLBL.isHidden = hasRecords
            self.locationsTV.reloadData()
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func deleteLocation(id: String) -> Void {
        
        let db = Firestore.firestore()
        db.collection("Restricted_Locations").document(id).delete { error in
            if let error = error {
                print("❌ Error deleting document: \(error.localizedDescription)")
            } else {
                print("✅ Document successfully deleted!")
                self.getRestrictedLocations()
            }
        }
    }
}

extension RestrictedAreasViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return restrictedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: RestrictedLocationTVC! = tableView.dequeueReusableCell(withIdentifier: "restrictedCell") as? RestrictedLocationTVC
        
        cell.titleLbl.text = restrictedLocations[indexPath.row].title ?? ""
        cell.addressLBL.text = restrictedLocations[indexPath.row].address ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let loc = self.restrictedLocations[indexPath.row]
            showDeleteConfirmation(for: loc.id ?? "", at: indexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showDeleteConfirmation(for documentId: String, at indexPath: IndexPath) {
            let alert = UIAlertController(
                title: "Confirm Deletion",
                message: "Are you sure you want to delete this record?",
                preferredStyle: .alert
            )
            
            // Confirm Action
            let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                
                self.deleteLocation(id: documentId)
            }
            
            // Cancel Action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    
}
