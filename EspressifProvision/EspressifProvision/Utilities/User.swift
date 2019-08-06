//
//  User.swift
//  EspressifProvision
//
//  Created by Vikas Chandra on 28/06/19.
//  Copyright © 2019 Espressif. All rights reserved.
//

import AWSCognitoIdentityProvider
import Foundation

class User {
    static let shared = User()
    var userID: String?
    var pool: AWSCognitoIdentityUserPool!
    var idToken: String?
    var associatedDevices: [Device]?
    var username: String!

    private init() {
        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: Constants.CognitoIdentityUserPoolRegion, credentialsProvider: nil)

        // create pool configuration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: Constants.CognitoIdentityUserPoolAppClientId,
                                                                        clientSecret: Constants.CognitoIdentityUserPoolAppClientSecret,
                                                                        poolId: Constants.CognitoIdentityUserPoolId)

        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)

        pool = AWSCognitoIdentityUserPool(forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)
        associatedDevices = []
        associatedDevices?.append(Device(name: "Test Device 1", device_id: "fafafe", type: nil))
        associatedDevices?.append(Device(name: "Test Device 2", device_id: "fafafe", type: nil))
        associatedDevices?.append(Device(name: "Test Device 3", device_id: "fafafe", type: nil))
    }

    func currentUser() -> AWSCognitoIdentityUser? {
        return pool.currentUser()
    }

    func getAccessToken(completionHandler: @escaping (String?) -> Void) {
        if idToken == nil, let user = currentUser(), user.isSignedIn {
            user.getSession().continueOnSuccessWith(block: { (task) -> Any? in
                completionHandler(task.result?.idToken?.tokenString)
            })
        } else {
            completionHandler(idToken)
        }
    }
}