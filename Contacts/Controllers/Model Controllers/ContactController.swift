//
//  ContactController.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    // MARK: - Properties
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    static let shared = ContactController()
    
    var contacts: [Contact] = []
    
    // MARK: - CRUD Functions
    
    func saveContact(withName name: String, phoneNumber: String?, email: String?, completion: @escaping (Result<Contact, ContactError>) -> Void) {
        
        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        
        let ckRecord = CKRecord(contact: newContact)
        
        privateDB.save(ckRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record else { return completion(.failure(.couldNotUnwrap)) }
            
            guard let contactToAppend = Contact(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(contactToAppend))
        }
    }
    
    func fetchAllContacts(completion: @escaping (Result<[Contact], ContactError>) -> Void) {
        
        let queryAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: ContactStrings.recordTypeKey, predicate: queryAllPredicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap))}
            
            let contacts = records.compactMap({ Contact(ckRecord: $0) })
            
            completion(.success(contacts))
        }
    }
    
    func delete(_ contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                completion(.success(true))
            }else {
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        privateDB.add(operation)
    }
}
