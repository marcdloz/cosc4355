//
//  BasicListingsProtocol.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

protocol BasicListingsProtocol {
  var title: String { get set }
  var description: String { get set }
  
  /* To the project the entity is referring to */
  var posting_id: String { get set }
  
  /* Use who owns the entity */
  var user_id: String { get set }
}
