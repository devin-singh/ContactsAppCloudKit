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
    
    func update(_ contact: Contact, completion: @escaping (Result<Contact, ContactError>) -> Void) {
        
        let record = CKRecord(contact: contact)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first, let updatedContact = Contact(ckRecord: record) else {
                return completion(.failure(.couldNotUnwrap))
            }
            
            completion(.success(updatedContact))
        }
        
        privateDB.add(operation)
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
    
    // MARK: - Local Persistance
    
    func createFileForPersistence() -> URL {
         // Grab the users Document directory
         let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         // Create the new fileURL on the users Phone
          let fileUrl = urls[0].appendingPathComponent("Contacts.json")
          return fileUrl
      }
    
    func saveToPersistantStore() {
        // Create an instance of JSONEncoder
        let jsonEncoder = JSONEncoder()
        // Attempt to convert our playlist array into JSON
        // Anytime a method throws, it must be placed in a do, try, catch block
        do {
            let jsonEntries = try jsonEncoder.encode(contacts)
            // With the new JSON(d) playlist arraay, save it to the users device
            try jsonEntries.write(to: createFileForPersistence())
        } catch let encodingError {
            print("There was an error saving the data! \(encodingError)")
        }
    }
    
    func loadFromPersistentStorage() {
        let jsonDecoder = JSONDecoder()
        do {
            let jsonData = try Data(contentsOf: createFileForPersistence())
            let decodedContacts = try jsonDecoder.decode([Contact].self, from: jsonData)
            contacts = decodedContacts
        } catch let decodingError {
            print("Error loading data \(decodingError)")
        }
    }
    
}
