//
//  SudokuRepository.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class LevelRepository {
    let easy : [String] = [
        "ooooBoooooBoAAooBooooooooooooooooooo",
        "oooooooooxooAAoDoooooDoooCCCoooooooo",
        "ooooooooxCCCAAooFoooooFooDDEEooooooo",
        "ooGBBBFoGooIFoGAAIFCCDDoooHEEEooHooo",
        "ooBBCCoooEFGAAoEFGoDDDFHoooooHoooooo",
        "oooGoooooGBBAAoGoooCCCoHDDDEEHooFFoo",
        "ooBBHooooGHoAAoGHoEFooooEFCCDDoFoooo",
        "IoBBoKICCCoKIAAJoKDDoJEEFFoxoooooHHH"
    ]
    let medium : [String] = [
        "HBBCCoHoIoooAAIJKooDDJKLEEEoKLoFFxoo",
        "oxCCLMDDIJLMAAIJooooIKooHEEKooHFFoxo",
        "FBBBooFCCCooAAHJoooGHJDDoGIEEKooIooK",
        "ooooooooHBBoAAHIooGoHICCGDDIJKEEFFJK",
        "oGBBKMoGooKMoAAILoCCoILoFoHJLxFoHJEE",
        "oHBBCCoHoJKoAAoJKoxoEEKLooIFFLooIGGo",
        "ooxooooooICCAAHIooGoHDDLGEEJKLFFFJKL",
        "xIoCCoHIooKLHIAAKLDDJoKoooJEEooFFGGo"
    ]
    let hard : [String] = [
        "BBHoooGoHCCoGoAAJoDDoIJoEEEIKoFFoIKo",
        "BBBHooFooHJKFAAIJKCCGIJLooGDDLooxooo",
        "BBCCoLoxEEELAAJKoLIoJKFFIGGGooooHHoo",
        "HBBCCCHDDKoMAAJKoMEEJFFMoIooLooIGGLo",
        "ooGBBBooGoooAAHIJKCCHIJKoFDDoKoFEEEo",
        "HBBLooHxJLDDIoJAAMIoKEEMooKFFNoGGooN",
        "oxoKCCDDDKoMAAoLoMIEELxoIoJGGoHHJooo",
        "oHIoBBoHIooLAAIooLGCCDDLGEEJKoFFFJKo"
    ]
    let veryHard : [String] = [
        "IBBxooIooLDDJAALooJoKEEMFFKooMGGHHHM",
        "BBoKMxDDDKMoIAALooIoJLEEooJFFNoGGoxN",
        "ooBBMxDDDKMoAAJKoNooJEENIFFLooIGGLox",
        "ooBBMxDDDKMoAAJKoNooJEENIFFLooIGGLHH",
        "oxCCMoDDDKMoAAJKooooJLEEIFFLoNIGGoxN",
        "oooJLxCCCJLoHAAKooHoIKDDooIEEMoFFoxM",
        "oooJxoCCCJLoHAAKLoHoIKDDooIEEMoFFoxM",
        "BBBKCCDDoKoLIAAKoLIoJEEMFFJooMooxoHH"
    ]

    func validateLevels() {
        //TODO: Implement
    }
    func getLevel(difficulty: Difficulty, level: Int) -> String? {
        var levelNo = level
        if level < 1 {
            return nil
        }
        levelNo = level - 1

        switch difficulty {
        case .Easy:
            if levelNo<easy.count {
                return easy[levelNo]
            }
        case .Medium:
            if levelNo<medium.count {
                return medium[levelNo]
            }
        case .Hard:
            if levelNo<hard.count {
                return hard[levelNo]
            }
        case .VeryHard:
            if levelNo<veryHard.count {
                return veryHard[levelNo]
            }
        }
        return nil
    }
    
    func calculateDifficulty(boardNumbers: String) -> Difficulty {
        return .Easy
    }
    
    func getGeneratedLevel() -> String? {
        return nil
    }
    

    func getGeneratedLevel(difficulty: Difficulty) -> String? {
        return nil
    }
}
