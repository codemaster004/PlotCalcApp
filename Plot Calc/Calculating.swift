//
//  Calculating.swift
//  Plot Calc
//
//  Created by Filip Dabkowski on 09/04/2021.
//

import Foundation

class Calculating: ObservableObject {
    @Published var calcData = [
        "plotSize": 0,
        "plotPrice": 0,
        "buildLimit": 0,
        "sellPrice": 0,
        "morgageCost": 0
    ]
    
    func setValue(label: String, value: Int) {
        calcData[label] = value
    }
    
    func getValue(label: String) -> Int {
        return calcData[label] ?? 0
    }
    
}
