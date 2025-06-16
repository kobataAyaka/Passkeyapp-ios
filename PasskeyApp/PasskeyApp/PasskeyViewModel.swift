//
//  PasskeyViewModel.swift
//  PasskeyApp
//
//  Created by 小幡綾加 on 6/16/25.
//

import SwiftUI

// MARK: - ViewModel (UIロジックと状態管理)
class PasskeyViewModel: ObservableObject {
    // UIの選択状態をPublishしてViewを更新
    @Published var selectedServiceType: Int = 0 { // 0: FIDO2, 1: DID/VC
        didSet {
            updateAuthService()
        }
    }
    // 結果表示用のテキストをPublishしてViewを更新
    @Published var resultText: String = "Ready."

    // 現在選択されている AuthService のインスタンス
    var authService: AuthService

    init() {
        // 初期状態はFIDO2サービス (Apple Passkey)
        self.authService = FidoAuthService()
    }

    // セグメントコントロールの選択に応じてサービスを切り替える
    private func updateAuthService() {
        if selectedServiceType == 0 {
            authService = FidoAuthService()
            resultText = "FIDO2モードが選択されました。準備完了。"
        } else {
//            authService = DidAuthService()
            resultText = "DID/VCモードが選択されました。この機能はまだテスト中。"
        }
    }

    // 「Authenticate / Generate Wallet」ボタンのアクション
    func performAuthentication() {
        resultText = "認証/ウォレット生成中..."
        authService.authenticate { [weak self] result in
            // UI更新はメインスレッドで行う
            DispatchQueue.main.async {
                switch result {
                case .success(let msg):
                    self?.resultText = msg
                case .failure(let error):
                    self?.resultText = "エラー: \(error.localizedDescription)"
                }
            }
        }
    }

    // 「Issue Credential」ボタンのアクション
    func performIssueCredential() {
        resultText = "証明書発行中..."
        authService.issueCredential { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let msg):
                    self?.resultText = msg
                case .failure(let error):
                    self?.resultText = "エラー: \(error.localizedDescription)"
                }
            }
        }
    }

    // 「Verify Credential」ボタンのアクション
    func performVerifyCredential() {
        resultText = "証明書検証中 (現在は簡易シミュレーション)..."
        // 実際には、発行されたVCをUI入力や保存されたものから取得して渡す
        let dummyCredential = "{\"example\":\"credential_json\"}" // またはユーザーにVCのJSONを入力させるなど
        authService.verifyCredential(credential: dummyCredential) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let msg):
                    self?.resultText = msg
                case .failure(let error):
                    self?.resultText = "エラー: \(error.localizedDescription)"
                }
            }
        }
    }
}
