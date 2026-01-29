//
//  exchange.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 27.01.2026.
//

import Foundation

public class Exchange: Identifiable, Codable {
    public static func DisplayName(for exchangeId: Int) -> String {
        switch exchangeId {
        case 1: return "Binance"
        case 2: return "Kucoin"
        case 3: return "Huobi"
        case 4: return "AlfaB"
        default: return "\(exchangeId)"
        }
    }
}

