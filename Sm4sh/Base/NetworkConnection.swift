//
//  NetworkConnection.swift
//  Sm4sh
//
//  Created by José Javier on 12/1/18.
//  Copyright © 2018 José Javier. All rights reserved.
//

import Foundation
import Alamofire

struct NetworkConnection {
  let baseURL = "https://parseapi.back4app.com/classes/Product"
  let header : HTTPHeaders = [
    "X-Parse-Application-Id" : "I9pG8SLhTzFA0ImFkXsEvQfXMYyn0MgDBNg10Aps",
    "X-Parse-REST-API-Key" : "Yvd2eK2LODfwVmkjQVNzFXwd3N0X7oUuwiMI3VDZ"
  ]
}
