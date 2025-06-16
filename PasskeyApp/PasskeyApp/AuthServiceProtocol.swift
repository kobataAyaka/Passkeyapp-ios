//
//  AuthService.swift
//  PasskeyApp
//
//  Created by 小幡綾加 on 6/16/25.
//

import Foundation
import AuthenticationServices // FIDO2 (Apple Passkey) 用
//import Trinsic // DID/VC (Trinsic) 用

// MARK: - AuthService プロトコル
// クラスタイプに限定 (ASAuthorizationControllerDelegateを使うため)
protocol AuthService: AnyObject {
    func authenticate(completion: @escaping (Result<String, Error>) -> Void)
    func issueCredential(completion: @escaping (Result<String, Error>) -> Void)
    func verifyCredential(credential: String, completion: @escaping (Result<String, Error>) -> Void)
}
