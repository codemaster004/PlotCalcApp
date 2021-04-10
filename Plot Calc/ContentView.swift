//
//  ContentView.swift
//  Plot Calc
//
//  Created by Filip Dabkowski on 07/04/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var calcData: Calculating
    
    @State var inputs = [
        CalcNumObj(name: "Powierzchnia działki", value: "0", maxValue: 10000, round: 10.0, prefix: "m2", label: "plotSize"),
        CalcNumObj(name: "Cena działki", value: "0", maxValue: 1000000, round: 1000.0, prefix: "zł", label: "plotPrice"),
        CalcNumObj(name: "Cena metra sprzedaży", value: "0", maxValue: 10000, round: 100.0, prefix: "zł/m2", label: "sellPrice")
    ]
    @State var inputsPick = [
        CalcPickObj(name: "Powiezchnia zabudowy", values: ["15", "20", "25", "30", "35"], picked: "25", label: "buildLimit")
    ]
    @State var showResult = false
    @State var hideInputs = false
    @State var mainOffset = 0
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            if showResult {
                CalculatedView(show: $showResult, hide: $hideInputs, offset: $mainOffset)
            }
            if !hideInputs {
                CalcInputsView(inputs: $inputs, inputsPick: $inputsPick, showResult: $showResult, hideInputs: $hideInputs, mainOffset: $mainOffset)
            }
        }
        .background(Color("Color1").ignoresSafeArea(.all))
        .onAppear() {
            for i in 0..<inputs.count {
                inputs[i].value = String(calcData.getValue(label: inputs[i].label))
            }
            
            for i in 0..<inputsPick.count {
                inputsPick[i].picked = String(calcData.getValue(label: inputsPick[i].label))
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(Calculating())
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .preferredColorScheme(.dark)
                .environmentObject(Calculating())
        }
    }
}

struct CalcInputsView: View {
    
    @EnvironmentObject var calcData: Calculating
    
    @Binding var inputs: [CalcNumObj]
    @Binding var inputsPick: [CalcPickObj]
    @Binding var showResult: Bool
    @Binding var hideInputs: Bool
    @Binding var mainOffset: Int
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                Text("Kalkulator \n wartości działki")
                    .foregroundColor(Color("Text1"))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(width: width * 0.9, height: 100)
                
                CustomNumInput(inputObj: $inputs[0])
                
                CustomNumInput(inputObj: $inputs[1])
                
                CustomPickInput(inputObj: $inputsPick[0])
                
                CustomNumInput(inputObj: $inputs[2])
                
                Spacer()
                
                Button(action: {
                    
                    for num in inputs {
                        calcData.setValue(label: num.label, value: Int(num.value) ?? 0)
                    }
                    
                    for pick in inputsPick {
                        calcData.setValue(label: pick.label, value: Int(pick.picked) ?? 0)
                    }
                    
//                    showResult.toggle()
                    
                    withAnimation(Animation.spring()) {
                        showResult.toggle()
                        mainOffset = Int(height * 0.55)
                    }
                    withAnimation(Animation.spring().delay(0.23)) {
                        hideInputs.toggle()
                    }
                }) {
                    Text("Oblicz")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(width: width * 0.9, height: 50)
                        .background(Color("Color1"))
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                
            }
            .padding(.top, 30)
            .frame(width: UIScreen.main.bounds.width * 0.9)
        }
        .frame(width: width)
        .background(Color("Color0").clipShape(CustomCorner(corners: [.topLeft, .topRight], size: 40)).ignoresSafeArea(.all))
        .opacity(hideInputs ? 0 : 1)
        .offset(y: CGFloat(mainOffset))
    }
}

struct CalcNumObj {
    var name: String
    var value: String
    var maxValue: Int
    var round: Float
    var prefix: String
    var label: String
}

struct CalcPickObj {
    var name: String
    var values: [String]
    var picked: String
    var label: String
}

struct CustomNumInput: View {
    
    @Binding var inputObj: CalcNumObj
    
    @State var offset: CGFloat = 0
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(inputObj.name)
                .foregroundColor(Color("Text4"))
                .font(.system(size: 14))
                .fontWeight(.semibold)
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                HStack(spacing: -5) {
                    Text(inputObj.prefix)
                        .font(.system(size: 20))
                        .foregroundColor(Color("Text1"))
                    
                    TextField("Placeholder", text: self.$inputObj.value, onCommit: {
                        self.offset = self.getOffset()
                    })
                    .foregroundColor(Color("Text1"))
                    .padding(15)
                    .frame(height: 50)
                    .font(.system(size: 20))
                }
                .padding(.leading, 15)
                .background(Color("Color3"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Color4"), lineWidth: 1)
                )
                
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                    Capsule()
                        .fill(Color("Color4"))
                        .frame(width: width * 0.9 - 15, height: 1)
                    
                    Capsule()
                        .fill(Color("Color2"))
                        .frame(width: offset + 18 - 15, height: 1)
                    
                    Circle()
                        .fill(Color("Color2"))
                        .frame(width: 18, height: 18)
                        .offset(x: offset)
                        .gesture(DragGesture().onChanged({ (value) in
                            if value.location.x > 7 && value.location.x <= width * 0.9 - 18 {
                                offset = value.location.x - 9
                                
                                self.setPrice()
                            }
                        }))
                }
                .offset(y: 9)
                .onAppear() {
                    offset = self.getOffset()
                }
            }
        }
    }
    
    func roundTo(x : Float, roundN: Float) -> Int {
        return Int(roundN) * Int(round(x / roundN))
    }
    
    func setPrice() {
        
        let max_amount: Float = Float(inputObj.maxValue)
        
        let precent = Float(offset) / Float(Int(width * 0.82))
        
        var amount = precent * max_amount
        
        if amount > max_amount {
            amount = max_amount
        } else if amount < 0 {
            amount = 0
        }
        
        self.inputObj.value = "\(roundTo(x: amount, roundN: self.inputObj.round))"
    }
    
    func getOffset() -> CGFloat {
        
        let max_amount: Float = Float(inputObj.maxValue)
        if (Float(inputObj.value) ?? 0.0) > max_amount {
            return CGFloat(width * 0.82)
            
        } else if (Float(inputObj.value) ?? 0.0) < 0 {
            inputObj.value = "0"
        }
        
        let precent = (Float(inputObj.value) ?? 0) / max_amount

        let offset = precent * Float(width * 0.82)

        return CGFloat(offset)
    }
}

struct CustomPickInput: View {
    
    @Binding var inputObj: CalcPickObj
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text(inputObj.name)
                .foregroundColor(Color("Text4"))
                .font(.system(size: 14))
                .fontWeight(.semibold)
            
            HStack(spacing: 10) {
                ForEach(inputObj.values, id: \.self) { item in
                    Button(action: {
                        inputObj.picked = item
                    }) {
                        Text(item)
                            .foregroundColor(inputObj.picked == item ? Color("Text3") : Color("Text2"))
                            .padding(.vertical, 10)
                            .frame(width: (width * 0.9 - 10 * (5 - 1)) / 5)
                            .background(inputObj.picked == item ? Color("Color2") : Color("Color4"))
                            .cornerRadius(10)
                    }
                }
            }
            .frame(width: width * 0.9)
        }
    }
}
