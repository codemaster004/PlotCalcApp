//
//  CalculatedView.swift
//  Plot Calc
//
//  Created by Filip Dabkowski on 07/04/2021.
//

import SwiftUI

struct CalculatedView: View {
    @EnvironmentObject var calcObj: Calculating
    
    @State var expecterReward = 0
    @State var optimalSetUp = [
        "sasankiL": 0,
        "sasankiXL": 0,
        "garaze": 0
    ]
    @State var morgageCost = "0"
    @State var livingArea = 0
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @Binding var show: Bool
    @Binding var hide: Bool
    @Binding var offset: Int
    
    var body: some View {
        ZStack {
            VStack(spacing: 50) {
                
                Text("Zwrot \n z inwestycji")
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("\(expecterReward) zł")
                    .foregroundColor(Color.white)
                    .font(.system(size:40))
                    .fontWeight(.thin)
                    .onAppear() {
                        calcNBuildings()
                    }
                
                Spacer()
            }
            .padding(.top, 30)
            .frame(width: width)
            .background(Color("Color1").ignoresSafeArea(.all))
            
            VStack {
                Spacer()
                
                VStack {
                    
                    HStack {
                        Text("Ilość Sasanek L")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        
                        Text("\(optimalSetUp["sasankiL"]!)")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    
                    HStack {
                        Text("Ilość Sasanek XL")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        Text("\(optimalSetUp["sasankiXL"]!)")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    
                    HStack {
                        Text("Ilość Garaży")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        Text("\(optimalSetUp["garaze"]!)")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    
                    HStack {
                        Text("Kosz Kredytu")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        VStack {
                            TextField("", text: $morgageCost, onCommit: {
                                self.caclReward(maxDiff: expecterReward, calcHumanArea: livingArea)
                                self.calcObj.setValue(label: "morgageCost", value: Int(morgageCost) ?? 0)
                            })
                                .padding(.horizontal, 10)
                                .frame(minWidth: 50, idealWidth: 70, maxWidth: 100, maxHeight: 37)
                                .font(.system(size: 18))
                                .background(Color("Color0"))
                                .border(width: 1, edges: [.bottom], color: Color("Text4"))
                                .multilineTextAlignment(.trailing)
                                
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .onAppear() {
                        morgageCost = String(calcObj.getValue(label: "morgageCost"))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            hide.toggle()
                        }
                        withAnimation(Animation.default.delay(0.2)) {
                            offset = 0
                        }
                        withAnimation(Animation.default.delay(0.5)) {
                            show.toggle()
                        }
                    }) {
                        Text("Zmień dane")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(width: width * 0.9, height: 50)
                            .background(Color("Color1"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 30)
                .frame(maxWidth: width, minHeight: height * 0.40, idealHeight: height * 0.40, maxHeight: height * 0.55)
                .background(Color("Color0").clipShape(CustomCorner(corners: [.topLeft, .topRight], size: 40)).ignoresSafeArea(.all))
                
            }
        }
    }
    
    func calcNBuildings() {
        let useablePlotArea: Double = Double(calcObj.calcData["plotSize"]! * calcObj.calcData["buildLimit"]!) / 100.0
        let useableArea = useablePlotArea * 0.75
        
        let sasankaL = [
            "useArea": 33,
        ]
        let sasankaXL = [
            "useArea": 43,
        ]
        let garage = [
            "useArea": 16,
            "buildCost": 27500,
            "sellValue": 35000
        ]
        
        let maxSL = Int(useableArea / Double(sasankaL["useArea"]!))
        let maxSXL = Int(useableArea / Double(sasankaXL["useArea"]!))
        let maxG = Int(useableArea / Double(garage["useArea"]!))
        
        var calcHumanArea = 0
        var maxDiff = 0
        
        for i in 0..<maxSL {
            for j in 0..<maxSXL {
                for l in 0..<maxG {
                    let calcCoveredArea = sasankaL["useArea"]! * i + sasankaXL["useArea"]! * j + garage["useArea"]! * l
                    if calcCoveredArea > Int(useableArea) {
                        continue
                    }
                    if (i + j) * 250 > calcObj.calcData["plotSize"]! {
                        continue
                    }
                    
                    if (i + j) % 2 == 0 && l % 2 != 0 {
                        continue
                    }
                    
                    let calcBuildCost = sasankaL["useArea"]! * 2 * 2500 * i + sasankaXL["useArea"]! * 2 * 2500 * j + garage["useArea"]! * 1250 * l
                    calcHumanArea = sasankaL["useArea"]! * 2 * i + sasankaXL["useArea"]! * 2 * j + garage["useArea"]! * l
                    
                    let calcInvestCost = calcBuildCost + calcObj.calcData["plotPrice"]!
                    let calcSellValue = sasankaL["useArea"]! * 2 * calcObj.calcData["sellPrice"]! * i + sasankaXL["useArea"]! * 2 * calcObj.calcData["sellPrice"]! * j + garage["sellValue"]! * l
                    let difference = calcSellValue - calcInvestCost
                    
                    if difference > maxDiff {
                        maxDiff = difference
                        
                        optimalSetUp = [
                            "sasankiL": i,
                            "sasankiXL": j,
                            "garaze": l
                        ]
                    }
                }
            }
        }
        
        self.livingArea = calcHumanArea
        self.caclReward(maxDiff: maxDiff, calcHumanArea: calcHumanArea)
    }
    
    func caclReward(maxDiff: Int, calcHumanArea: Int) {
        let afterExpenses = maxDiff - calcHumanArea * 100 - (Int(morgageCost) ?? 0)
//        let afterTaxes = Double(afterExpenses) * 0.92 * 0.81
        
        expecterReward = Int(afterExpenses)
    }
    
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

struct CalculatedView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatedView(show: .constant(true), hide: .constant(false), offset: .constant(0))
            .environmentObject(Calculating())
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: size, height: size))
        
        return Path(path.cgPath)
    }
}
