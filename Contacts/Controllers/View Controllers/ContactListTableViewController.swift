//
//  ContactListTableViewController.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var resultsArray: [SearchableRecord] = []
    var isSearching = false
    var dataSource: [SearchableRecord] { return isSearching ? resultsArray : ContactController.shared.contacts}
    
    // MARK: - Outlets
    
    @IBOutlet weak var contactListSearchBar: UISearchBar!
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactListSearchBar.delegate = self
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
        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contactToAdd = dataSource[indexPath.row] as? Contact
        
        cell.textLabel?.text = contactToAdd?.name
        // If nil, the textLabel can handle it and leave blank
        cell.detailTextLabel?.text = contactToAdd?.phoneNumber
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDelete = ContactController.shared.contacts[indexPath.row]
            guard let index = ContactController.shared.contacts.firstIndex(of: contactToDelete) else { return }
            
            ContactController.shared.delete(contactToDelete) { (result) in
                switch result {
                case .success(let success):
                    if success {
                        ContactController.shared.contacts.remove(at: index)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                case .failure(let error):
                    print(error.errorDescription ?? error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateVC" {
            guard let indexPath = tableView.indexPathForSelectedRow ,let destinationVC = segue.destination as? ContactDetailViewController else { return }
            
            let contactToSend = ContactController.shared.contacts[indexPath.row]
            
            destinationVC.contact = contactToSend
        }
    }
}

// MARK: - UISearchBarDelegate

extension ContactListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = ContactController.shared.contacts.filter { $0.matches(searchTerm: searchText)}
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = ContactController.shared.contacts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}
