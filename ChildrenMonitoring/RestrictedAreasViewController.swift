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
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRestrictedLocations()
    }

    private func setupTableView() {
        locationsTV.delegate = self
        locationsTV.dataSource = self
        locationsTV.tableFooterView = UIView()
    }

    private func fetchRestrictedLocations() {
        guard let parentId = Auth.auth().currentUser?.uid,
              let childId = childData?.id,
              !parentId.isEmpty, !childId.isEmpty else {
            print("❌ Invalid parent or child ID")
            return
        }

        SVProgressHUD.show()
        let db = Firestore.firestore()
        db.collection("Restricted_Locations")
            .whereField("parent_id", isEqualTo: parentId)
            .whereField("child_id", isEqualTo: childId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                SVProgressHUD.dismiss()

                if let error = error {
                    print("❌ Error fetching restricted locations: \(error.localizedDescription)")
                    return
                }

                self.restrictedLocations = snapshot?.documents.compactMap {
                    let data = $0.data()
                    return RestrictedLocationModel(
                        id: $0.documentID,
                        parent_id: data["parent_id"] as? String ?? "",
                        child_id: data["child_id"] as? String ?? "",
                        title: data["title"] as? String ?? "",
                        address: data["address"] as? String ?? "",
                        lat: data["lat"] as? Double ?? 0.0,
                        lng: data["lng"] as? Double ?? 0.0
                    )
                } ?? []

                let hasData = !self.restrictedLocations.isEmpty
                self.locationsTV.isHidden = !hasData
                self.noRecordLBL.isHidden = hasData
                self.locationsTV.reloadData()
            }
    }

    private func deleteLocation(with id: String) {
        Firestore.firestore().collection("Restricted_Locations").document(id).delete { [weak self] error in
            if let error = error {
                print("❌ Error deleting location: \(error.localizedDescription)")
            } else {
                print("✅ Location deleted successfully")
                self?.fetchRestrictedLocations()
            }
        }
    }

    private func showDeleteConfirmation(for id: String) {
        let alert = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this restricted location?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteLocation(with: id)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension RestrictedAreasViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restrictedLocations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restrictedCell") as? RestrictedLocationTVC else {
            return UITableViewCell()
        }

        let location = restrictedLocations[indexPath.row]
        cell.titleLbl.text = location.title
        cell.addressLBL.text = location.address
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = restrictedLocations[indexPath.row]
            if let locationId = location.id {
                showDeleteConfirmation(for: locationId)
            }
        }
    }
}
