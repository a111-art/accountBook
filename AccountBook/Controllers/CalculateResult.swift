//
//  CalculateResult.swift
//  AccountBook
//
//  Created by a111 on 2021/1/15.
//

import UIKit

class CalculateResult: NSObject {
  
    func calculateWithString(s: String) -> String{
        let str = s
        var strArr = [String]()
        strArr = stringToArray(s: str)

        let numArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."]
        var operandArr = [String]()
        var operatorArr = [String]()
        var num: String = ""

        for i in 0..<strArr.count {
            if numArray.contains(strArr[i]) {
                num.append(strArr[i])
            } else {
                operandArr.append(num)
                operatorArr.append(strArr[i])
                num = ""
            }
        }
        for i in 0..<operatorArr.count-1 {
            if operatorArr[i] == "*" {
                let n = Float(operandArr[i])! * Float(operandArr[i+1])!
                operandArr[i] = String(n)
                operatorArr.remove(at: i)
                operandArr.remove(at: i+1)
            }
        }
        
        let i = 0
        while i < operatorArr.count-1 {
            var n: Float = 0
            if operatorArr[i] == "+" {
                 n = Float(operandArr[i])! + Float(operandArr[i+1])!
            } else {
                 n = Float(operandArr[i])! - Float(operandArr[i+1])!
            }
            operandArr[i] = String(n)
            operatorArr.remove(at: i)
            operandArr.remove(at: i+1)
        }
        
        return operandArr[0]
        
    }
        func stringToArray(s:String) -> Array<String>
        {
            var stringArray = Array<String>()
            let mutableStr = s
            let length = mutableStr.count
            for i in 0...length-1
            {
                let str = mutableStr[mutableStr.index(mutableStr.startIndex, offsetBy: i)..<mutableStr.index(mutableStr.startIndex, offsetBy: (i+1))]
                stringArray.append(String(str))
            }
            return stringArray
        }

    }
