//
//  SearchableRecord.swift
//  Contacts
//
//  Created by Devin Singh on 2/7/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation

protocol SearchableRecord {
  func matches(searchTerm: String) -> Bool
}
