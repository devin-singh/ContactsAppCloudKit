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
    
    var contact: Contact? {
        didSet {
            loadViewIfNeeded()
            self.updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Private functions
    
    private func updateViews() {
        guard let contact = contact else { return }
        nameTextField.text = contact.name
        phoneNumberTextField.text = contact.phoneNumber
        emailTextField.text = contact.email
    }
    
    private func popCurrentVC() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        if let contact = self.contact {
            contact.name = name
            contact.email = emailTextField.text
            contact.phoneNumber = phoneNumberTextField.text
            
            ContactController.shared.update(contact) { (result) in
                switch result {
                case .success(_):
                    self.popCurrentVC()
                case .failure(let error):
                    print(error.errorDescription ?? error.localizedDescription)
                }
            }
        } else {
            ContactController.shared.saveContact(withName: name, phoneNumber: phoneNumberTextField.text, email: emailTextField.text) { (result) in
                switch result {
                case .success(let contact):
                    ContactController.shared.contacts.insert(contact, at: 0)
                    self.popCurrentVC()
                case .failure(let error):
                    print(error.errorDescription ?? error.localizedDescription)
                }
            }
        }
    }
}
