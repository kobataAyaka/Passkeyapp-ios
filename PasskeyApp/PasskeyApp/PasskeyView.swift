//
//  PasskeyView.swift
//  PasskeyApp
//
//  Created by 小幡綾加 on 6/16/25.
//

import SwiftUI

struct PasskeyView: View {
    // ViewModelをViewのライフサイクルに合わせて管理
    @StateObject private var viewModel = PasskeyViewModel()

    var body: some View {
        NavigationView { // ナビゲーションバー表示用
            VStack(spacing: 20) {
                // モード切り替え用のセグメントコントロール [会話履歴, 91]
                Picker("認証タイプ", selection: $viewModel.selectedServiceType) {
                    Text("FIDO2").tag(0)
                    Text("DID/VC").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // 共通アクションボタン [会話履歴, 92]
                Button(action: viewModel.performAuthentication) {
                    Text("認証 / ウォレット生成")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: viewModel.performIssueCredential) {
                    Text("証明書発行")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: viewModel.performVerifyCredential) {
                    Text("証明書検証")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // 結果表示エリア [会話履歴, 92]
                ScrollView {
                    Text(viewModel.resultText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .frame(maxHeight: 200) // スクロール可能にするために高さを制限
                .padding(.horizontal)
                
                Spacer() // 上の要素を中央に寄せる
            }
            .padding(.vertical)
            .navigationTitle("FIDO2 vs DID/VC デモ") // ナビゲーションバーのタイトル
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
