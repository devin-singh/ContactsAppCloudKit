//
//  Contact.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation
import CloudKit

struct ContactStrings {
    static let recordTypeKey = "Contact"
    fileprivate static let nameKey = "name"
    fileprivate static let phoneNumberKey = "cellNum"
    fileprivate static let emailKey = "email"
}


class Contact: Codable {
    
    var name: String
    var phoneNumber: String?
    var email: String?
    var recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)
    
    private enum CodingKeys: String, CodingKey {
        case name, phoneNumber, email
    }
    
    init(name: String, phoneNumber: String?, email: String?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.recordID = recordID
        
    }
}

extension Contact {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[ContactStrings.nameKey] as? String else { return nil }
        
        let phoneNumber = ckRecord[ContactStrings.phoneNumberKey] as? String
        let email = ckRecord[ContactStrings.emailKey] as? String
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactStrings.recordTypeKey, recordID: contact.recordID)
        
        self.setValuesForKeys([
            ContactStrings.nameKey : contact.name
        ])
        
        if let phoneNumber = contact.phoneNumber {
            self.setValue(phoneNumber, forKey: ContactStrings.phoneNumberKey)
        }
        
        if let email = contact.email {
            self.setValue(email, forKey: ContactStrings.emailKey)
        }
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

extension Contact: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if name.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else if phoneNumber?.lowercased().contains(searchTerm.lowercased()) ?? false {
            return true
        } else if email?.lowercased().contains(searchTerm.lowercased()) ?? false {
            return true
        }
        return false
    }
}
