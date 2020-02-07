//
//  ContactListTableViewController.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
        
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViews()
    }
    
    // MARK: - Private functions
    
    private func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadData() {
        ContactController.shared.fetchAllContacts { (result) in
            switch result {
            case .success(let contacts):
                ContactController.shared.contacts = contacts
                self.updateViews()
            case .failure(let error):
                print(error.errorDescription ?? error.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contactToAdd = ContactController.shared.contacts[indexPath.row]
        
        cell.textLabel?.text = contactToAdd.name
        // If nil, the textLabel can handle it and leave blank
        cell.detailTextLabel?.text = contactToAdd.phoneNumber
        
        return cell
    }
    
    
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
