//
//  UserToken.swift
//  AppCovid
//
//  Created by user168611 on 4/27/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

class UserToken: Codable {
    var username: String
    var userID: String
    
    init(username : String, userID: String) {
        self.username = username
        self.userID = userID
    }
}
