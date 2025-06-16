//
//  FIDOAuthService.swift
//  PasskeyApp
//
//  Created by 小幡綾加 on 6/16/25.
//

import AuthenticationServices

// MARK: - FidoAuthService (Apple Passkey API を利用)
// Singular Key の無料APIキーが入手困難なため、AppleのネイティブAPIを推奨 [会話履歴, 105, 119, 141]
class FidoAuthService: NSObject, AuthService, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private var currentCompletion: ((Result<String, Error>) -> Void)?

    // 実際のアプリでは、Firebase Cloud Functions などバックエンドからチャレンジを取得します [1, 2]
    // ここではデモ用に仮のチャレンジを使用
    private let demoChallenge = Data("YOUR_BACKEND_CHALLENGE_DATA".utf8)

    // FIDO2認証 (ログイン/アサーション)
    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        self.currentCompletion = completion

        // ASAuthorizationPlatformPublicKeyCredentialProvider を使って認証リクエストを作成 [3]
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "localhost") // Relying Party ID はFirebaseのドメインなど [4-6]
        let request = provider.createCredentialAssertionRequest(challenge: demoChallenge)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self // UI提示のために必要
        controller.performRequests() // Face ID/Touch ID プロンプトが表示される
    }

    // パスキー登録 (新規パスキーの発行)
    func issueCredential(completion: @escaping (Result<String, Error>) -> Void) {
        self.currentCompletion = completion

        // ASAuthorizationPlatformPublicKeyCredentialProvider を使って登録リクエストを作成 [7, 8]
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "localhost") // Relying Party ID
        let userID = Data(UUID().uuidString.utf8) // 一意のユーザーID
        let userName = "Test User" // ユーザーに表示される名前

        let registrationRequest = provider.createCredentialRegistrationRequest(challenge: demoChallenge, name: userName, userID: userID)

        let controller = ASAuthorizationController(authorizationRequests: [registrationRequest])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests() // Face ID/Touch ID プロンプトが表示される
    }

    // FIDO2検証 (バックエンドでの検証をシミュレート)
    func verifyCredential(credential: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 実際のアプリでは、この credential を Firebase Cloud Functions の WebAuthn エンドポイントに送信して検証します [2, 6]
        print("FIDO 検証 (シミュレート): \(credential)")
        completion(.success("FIDO Credential が検証されました: \(credential)"))
    }

    // MARK: - ASAuthorizationControllerDelegate
    // 認証・登録が成功した場合に呼ばれる [9-11]
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            let credentialId = credential.credentialID.base64EncodedString()
            currentCompletion?(.success("FIDO 登録成功。Credential ID: \(credentialId)"))
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            let credentialId = credential.credentialID.base64EncodedString()
            currentCompletion?(.success("FIDO 認証成功。Credential ID: \(credentialId)"))
        } else {
            currentCompletion?(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "不明な認証情報タイプ"])))
        }
    }

    // 認証・登録が失敗またはキャンセルされた場合に呼ばれる [12]
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        currentCompletion?(.failure(error))
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding
    // パスキー認証のUIを表示するためのアンカー (UIWindow) を提供 [8]
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // これはデモアプリでよく使われる手法です。プロダクションではより堅牢な方法を検討してください。
        return UIApplication.shared.windows.first!
    }
}
