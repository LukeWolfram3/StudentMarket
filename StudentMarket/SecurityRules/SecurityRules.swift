//
//  SecurityRules.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/24/25.
//

//import Foundation

//https://firebase.google.com/docs/firestore/security/rules-structure
//https://firebase.google.com/docs/rules/rules-language

//rules_version = '2';
//
//service cloud.firestore {
//  match /databases/{database}/documents {
//          match /users/{userId} {
//          allow read: if request.auth != null;
//        allow write: if request.auth.uid == userId;
//    }
//    
//    match /users/{userId}/favorite_products/{userFavoriteProductID} {
//    allow read: if request.auth != null;
//    allow write: if request.auth != null && request.auth.uid == userId;
//    }
//    
//    match /products/{productId} {
//    allow read: if request.auth != null;
//    allow create: if request.auth != null;
//    allow update: if request.auth != null;
//    allow delete: if request.auth != null
//    }
//    
//    function isAdmin(userId) {
//    return exists(/databases/$(database)/documents/admins/$(userId));
//    }
//  }
//}
// allow read: if request.auth != null && isAdmin(request.auth.uid)
//
// READ - includes get and list
// GET - single document reads
// LIST - queries and collection read requests
//
// WRITE
// create - add document
// update - edit document
// delete - delete document
