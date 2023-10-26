//
//  Caracter+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/21.
//

import Foundation

extension Character {
    /// - SeeAlso: https://qiita.com/4q_sano/items/8cfdb4d0b45a744c5610
    /// `isEmoji`は、数字の「3」などの修飾子を追加することで絵文字に変換できるすべての文字に対してtrueとなります。
    /// これを回避するために、"0x203C"未満の文字には絵文字修飾子が添付されていることを確認します。
    /// "0x203C"は、修飾子を必要としないUTF16絵文字の最初のインスタンスです。
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value >= 0x203C || unicodeScalars.count > 1)
    }
}
