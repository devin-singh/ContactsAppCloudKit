//
//  ContactError.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation

enum ContactError: LocalizedError {
    
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get hype and uw it."
        case .unexpectedRecordsFound:
            return "Unexpected records were returned when trying to delete"
        case .noUserLoggedIn:
            return "No user logged in."
        }
        
    }
}
