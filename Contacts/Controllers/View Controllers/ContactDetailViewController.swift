//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        ContactController.shared.saveContact(withName: name, phoneNumber: phoneNumberTextField.text, email: emailTextField.text) { (result) in
            switch result {
            case .success(let contact):
                ContactController.shared.contacts.insert(contact, at: 0)
            case .failure(let error):
                print(error.errorDescription ?? error.localizedDescription)
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
