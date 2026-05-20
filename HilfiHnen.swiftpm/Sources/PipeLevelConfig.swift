import SwiftUI

// Alle Level-Konfigurationen für die 10 Rohr/Pfad-Rätsel
struct PipeLevelConfig: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let timeLimit: Double
    let targetPercent: Double
    let joints: [JointDef]
    let puzzleVariant: PuzzleVariant
    let bgColorTop: Color
    let bgColorBot: Color

    enum PuzzleVariant {
        case pipe        // klassisches Rohr-Puzzle (Gelenke verschieben)
        case scissors    // Scherengestänge ausziehen
        case chain       // Kettenglieder verbinden
        case gravity     // Münzen durch Kippen führen
    }
}

struct JointDef {
    var pos: CGPoint
    let fixed: Bool
    let hasBar: Bool   // zeigt Querbalken zum Nachbar
}

// Container-Größe für alle Level
let C: CGFloat = 290   // Spielfeld-Seite

let allPipeLevels: [PipeLevelConfig] = [

    // Level 1 – Einfaches L-Rohr
    PipeLevelConfig(
        id: 0, title: "Spiele Minispiele!", subtitle: "Führe die Münzen zum Behälter",
        timeLimit: 60, targetPercent: 0.7,
        joints: [
            JointDef(pos: p(60,40),    fixed:true,  hasBar:false),
            JointDef(pos: p(60,160),   fixed:false, hasBar:true),
            JointDef(pos: p(220,230),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.20,green:0.28,blue:0.55), bgColorBot: Color(red:0.28,green:0.42,blue:0.75)
    ),

    // Level 2 – S-Kurve
    PipeLevelConfig(
        id: 1, title: "Spiele Minispiele!", subtitle: "Drei Gelenke, eine S-Kurve",
        timeLimit: 55, targetPercent: 0.7,
        joints: [
            JointDef(pos: p(55,35),    fixed:true,  hasBar:false),
            JointDef(pos: p(180,100),  fixed:false, hasBar:true),
            JointDef(pos: p(80,175),   fixed:false, hasBar:true),
            JointDef(pos: p(230,250),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.18,green:0.32,blue:0.50), bgColorBot: Color(red:0.28,green:0.50,blue:0.72)
    ),

    // Level 3 – Scheren-Gestänge
    PipeLevelConfig(
        id: 2, title: "Strecke das Gestänge!", subtitle: "Ziehe die Scheren auseinander",
        timeLimit: 50, targetPercent: 0.65,
        joints: [
            JointDef(pos: p(50,50),    fixed:true,  hasBar:false),
            JointDef(pos: p(100,110),  fixed:false, hasBar:true),
            JointDef(pos: p(160,110),  fixed:false, hasBar:true),
            JointDef(pos: p(200,170),  fixed:false, hasBar:true),
            JointDef(pos: p(235,240),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .scissors,
        bgColorTop: Color(red:0.22,green:0.20,blue:0.42), bgColorBot: Color(red:0.38,green:0.32,blue:0.62)
    ),

    // Level 4 – Zickzack
    PipeLevelConfig(
        id: 3, title: "Spiele Minispiele!", subtitle: "Zickzack zum Ziel",
        timeLimit: 45, targetPercent: 0.70,
        joints: [
            JointDef(pos: p(60,30),    fixed:true,  hasBar:false),
            JointDef(pos: p(200,100),  fixed:false, hasBar:true),
            JointDef(pos: p(60,160),   fixed:false, hasBar:true),
            JointDef(pos: p(220,200),  fixed:false, hasBar:true),
            JointDef(pos: p(60,260),   fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.20,green:0.30,blue:0.52), bgColorBot: Color(red:0.30,green:0.46,blue:0.74)
    ),

    // Level 5 – Doppelkurve
    PipeLevelConfig(
        id: 4, title: "Doppelkurve!", subtitle: "Zwei Kurven überwinden",
        timeLimit: 42, targetPercent: 0.72,
        joints: [
            JointDef(pos: p(55,35),    fixed:true,  hasBar:false),
            JointDef(pos: p(160,80),   fixed:false, hasBar:true),
            JointDef(pos: p(55,145),   fixed:false, hasBar:true),
            JointDef(pos: p(180,195),  fixed:false, hasBar:true),
            JointDef(pos: p(55,255),   fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.18,green:0.25,blue:0.48), bgColorBot: Color(red:0.28,green:0.38,blue:0.68)
    ),

    // Level 6 – Spirale
    PipeLevelConfig(
        id: 5, title: "Spirale!", subtitle: "Lenke die Münzen durch die Spirale",
        timeLimit: 40, targetPercent: 0.68,
        joints: [
            JointDef(pos: p(145,30),   fixed:true,  hasBar:false),
            JointDef(pos: p(240,80),   fixed:false, hasBar:true),
            JointDef(pos: p(220,170),  fixed:false, hasBar:true),
            JointDef(pos: p(100,200),  fixed:false, hasBar:true),
            JointDef(pos: p(70,120),   fixed:false, hasBar:true),
            JointDef(pos: p(150,145),  fixed:false, hasBar:true),
            JointDef(pos: p(145,260),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.25,green:0.18,blue:0.45), bgColorBot: Color(red:0.40,green:0.28,blue:0.65)
    ),

    // Level 7 – Kurze Zeit
    PipeLevelConfig(
        id: 6, title: "Schnell!", subtitle: "Wenig Zeit — handle schnell!",
        timeLimit: 28, targetPercent: 0.60,
        joints: [
            JointDef(pos: p(60,35),    fixed:true,  hasBar:false),
            JointDef(pos: p(200,100),  fixed:false, hasBar:true),
            JointDef(pos: p(100,200),  fixed:false, hasBar:true),
            JointDef(pos: p(220,255),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.42,green:0.18,blue:0.12), bgColorBot: Color(red:0.62,green:0.28,blue:0.12)
    ),

    // Level 8 – Viele Gelenke
    PipeLevelConfig(
        id: 7, title: "Viele Gelenke!", subtitle: "6 Gelenke kontrollieren",
        timeLimit: 38, targetPercent: 0.75,
        joints: [
            JointDef(pos: p(55,30),    fixed:true,  hasBar:false),
            JointDef(pos: p(180,75),   fixed:false, hasBar:true),
            JointDef(pos: p(80,120),   fixed:false, hasBar:true),
            JointDef(pos: p(200,155),  fixed:false, hasBar:true),
            JointDef(pos: p(75,195),   fixed:false, hasBar:true),
            JointDef(pos: p(195,225),  fixed:false, hasBar:true),
            JointDef(pos: p(75,265),   fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.20,green:0.28,blue:0.50), bgColorBot: Color(red:0.30,green:0.44,blue:0.72)
    ),

    // Level 9 – Scherengestänge Meister
    PipeLevelConfig(
        id: 8, title: "Meister-Gestänge!", subtitle: "Komplexes Scherengestänge",
        timeLimit: 35, targetPercent: 0.72,
        joints: [
            JointDef(pos: p(55,35),    fixed:true,  hasBar:false),
            JointDef(pos: p(120,90),   fixed:false, hasBar:true),
            JointDef(pos: p(190,90),   fixed:false, hasBar:true),
            JointDef(pos: p(130,155),  fixed:false, hasBar:true),
            JointDef(pos: p(200,155),  fixed:false, hasBar:true),
            JointDef(pos: p(140,220),  fixed:false, hasBar:true),
            JointDef(pos: p(220,255),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .scissors,
        bgColorTop: Color(red:0.22,green:0.18,blue:0.40), bgColorBot: Color(red:0.38,green:0.30,blue:0.60)
    ),

    // Level 10 – Finale
    PipeLevelConfig(
        id: 9, title: "Das Finale!", subtitle: "Alles auf einmal — schaffst du es?",
        timeLimit: 25, targetPercent: 0.80,
        joints: [
            JointDef(pos: p(145,28),   fixed:true,  hasBar:false),
            JointDef(pos: p(220,80),   fixed:false, hasBar:true),
            JointDef(pos: p(70,120),   fixed:false, hasBar:true),
            JointDef(pos: p(220,155),  fixed:false, hasBar:true),
            JointDef(pos: p(70,195),   fixed:false, hasBar:true),
            JointDef(pos: p(210,230),  fixed:false, hasBar:true),
            JointDef(pos: p(145,268),  fixed:true,  hasBar:false),
        ],
        puzzleVariant: .pipe,
        bgColorTop: Color(red:0.35,green:0.15,blue:0.10), bgColorBot: Color(red:0.58,green:0.25,blue:0.08)
    ),
]

// Hilfsfunktion: Punkt im Spielfeld-Koordinatensystem
private func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x:x, y:y) }
