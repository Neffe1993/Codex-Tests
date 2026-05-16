import SwiftUI

struct LevelData {

    static let levels: [GameLevel] = [
        // MARK: - Level 1 — Winter Rescue (Match-3)
        GameLevel(
            id: 0,
            title: "Winterrettung",
            subtitle: "Hilf der Familie!",
            scenario: .winterRescue,
            type: .match3(config: Match3Config(
                rows: 7, cols: 7, tileTypes: 4,
                targetScore: 800, moveLimit: 25,
                specialGoals: [
                    TileGoal(tileColor: .blue, count: 15),
                    TileGoal(tileColor: .red, count: 10)
                ]
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.85, green: 0.93, blue: 1.0)],
                    characters: [ScenarioCharacter(name: "Marie", imageName: "person.fill", speechBubble: "Wir frieren!")],
                    needs: ["jacket", "house.fill"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Marie und ihre Kinder sind in der eisigen Kälte gestrandet. Sie brauchen warme Kleidung und eine sichere Unterkunft."
                )
            ],
            rewardText: "Du hast der Familie geholfen! Eine warme Jacke und ein neues Zuhause!",
            backgroundColors: [Color(red: 0.55, green: 0.75, blue: 0.95), Color(red: 0.9, green: 0.96, blue: 1.0)],
            difficultyLabel: "Leicht"
        ),

        // MARK: - Level 2 — Broken Home (Pipe Puzzle)
        GameLevel(
            id: 1,
            title: "Kaputtes Zuhause",
            subtitle: "Repariere das Zimmer!",
            scenario: .brokenHome,
            type: .pipePuzzle(config: PipeConfig(
                gridSize: 5,
                segments: [
                    PipeSegment(row: 0, col: 2, type: .end, isFixed: true),
                    PipeSegment(row: 1, col: 1, type: .curve, isFixed: false),
                    PipeSegment(row: 1, col: 2, type: .straight, isFixed: false),
                    PipeSegment(row: 2, col: 2, type: .junction, isFixed: false),
                    PipeSegment(row: 3, col: 2, type: .curve, isFixed: false),
                    PipeSegment(row: 4, col: 2, type: .end, isFixed: true)
                ],
                coinTarget: 50
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.2, green: 0.22, blue: 0.3), Color(red: 0.35, green: 0.38, blue: 0.5)],
                    characters: [
                        ScenarioCharacter(name: "Marie", imageName: "person.fill", speechBubble: "Der Ventilator macht Funken!"),
                        ScenarioCharacter(name: "Kind", imageName: "person.2.fill", speechBubble: "Ich friere!")
                    ],
                    needs: ["fan", "window.casement", "fireplace"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Das Zimmer ist in einem schrecklichen Zustand. Der Ventilator sprüht Funken, das Fenster ist kaputt, und der Kamin geht nicht."
                )
            ],
            rewardText: "Das Zimmer ist repariert! Alle sind wieder warm und sicher.",
            backgroundColors: [Color(red: 0.18, green: 0.2, blue: 0.28), Color(red: 0.3, green: 0.35, blue: 0.48)],
            difficultyLabel: "Mittel"
        ),

        // MARK: - Level 3 — Snow Storm (Balance)
        GameLevel(
            id: 2,
            title: "Schneesturm",
            subtitle: "Stell dich der Herausforderung!",
            scenario: .snowStorm,
            type: .balanceChallenge(config: BalanceConfig(
                sliderCount: 4,
                targetRatio: 0.5,
                tolerance: 0.08
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.7, green: 0.82, blue: 0.95), Color(red: 0.88, green: 0.93, blue: 0.98)],
                    characters: [
                        ScenarioCharacter(name: "Vater", imageName: "person.fill", speechBubble: "Wir brauchen Wasser!"),
                        ScenarioCharacter(name: "Tochter", imageName: "figure.child", speechBubble: "Ich habe Hunger!")
                    ],
                    needs: ["drop.fill", "fork.knife"],
                    titleText: "Stell dich der Herausforderung!",
                    bodyText: "Ein Schneesturm hat die Familie von allem abgeschnitten. Balanciere die Ressourcen um zu überleben!"
                )
            ],
            rewardText: "Perfekt ausbalanciert! Die Familie hat genug Wasser und Nahrung.",
            backgroundColors: [Color(red: 0.65, green: 0.8, blue: 0.95), Color(red: 0.88, green: 0.95, blue: 1.0)],
            difficultyLabel: "Mittel"
        ),

        // MARK: - Level 4 — Fire Rescue (Thermometer Match-3)
        GameLevel(
            id: 3,
            title: "Feuerrettung",
            subtitle: "Lösch die Flammen!",
            scenario: .fireRescue,
            type: .thermometer(config: ThermometerConfig(
                targetFill: 0.8,
                moveLimit: 20,
                tileTypes: 5
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 1.0, green: 0.5, blue: 0.15), Color(red: 0.95, green: 0.85, blue: 0.2)],
                    characters: [
                        ScenarioCharacter(name: "Familie", imageName: "person.3.fill", speechBubble: "Hilfe! Feuer!")
                    ],
                    needs: ["flame", "drop.fill"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Ein Feuer bedroht die Familie! Sammle genug Wasser um die Flammen zu löschen."
                )
            ],
            rewardText: "Das Feuer ist gelöscht! Die Familie ist in Sicherheit.",
            backgroundColors: [Color(red: 0.95, green: 0.45, blue: 0.1), Color(red: 1.0, green: 0.8, blue: 0.2)],
            difficultyLabel: "Schwer"
        ),

        // MARK: - Level 5 — Flood Rescue (Match-3)
        GameLevel(
            id: 4,
            title: "Überschwemmung",
            subtitle: "Rette die Familie!",
            scenario: .floodRescue,
            type: .match3(config: Match3Config(
                rows: 8, cols: 8, tileTypes: 5,
                targetScore: 1200, moveLimit: 30,
                specialGoals: [
                    TileGoal(tileColor: .blue, count: 20),
                    TileGoal(tileColor: .green, count: 15)
                ]
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.15, green: 0.4, blue: 0.75), Color(red: 0.3, green: 0.6, blue: 0.9)],
                    characters: [
                        ScenarioCharacter(name: "Familie", imageName: "person.3.fill", speechBubble: "Das Wasser steigt!")
                    ],
                    needs: ["boat", "house.fill"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Überschwemmungen haben das Dorf getroffen. Sammle Materialien um ein Boot zu bauen und die Familie zu retten!"
                )
            ],
            rewardText: "Alle sind gerettet! Das neue Haus steht auf sicherem Boden.",
            backgroundColors: [Color(red: 0.15, green: 0.38, blue: 0.72), Color(red: 0.28, green: 0.58, blue: 0.88)],
            difficultyLabel: "Mittel"
        ),

        // MARK: - Level 6 — Desert Heat (Pipe Puzzle)
        GameLevel(
            id: 5,
            title: "Wüstenhitze",
            subtitle: "Finde Wasser!",
            scenario: .desertHeat,
            type: .pipePuzzle(config: PipeConfig(
                gridSize: 6,
                segments: [
                    PipeSegment(row: 0, col: 0, type: .end, isFixed: true),
                    PipeSegment(row: 0, col: 3, type: .curve, isFixed: false),
                    PipeSegment(row: 2, col: 2, type: .junction, isFixed: false),
                    PipeSegment(row: 3, col: 4, type: .straight, isFixed: false),
                    PipeSegment(row: 5, col: 5, type: .end, isFixed: true)
                ],
                coinTarget: 80
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.95, green: 0.75, blue: 0.3), Color(red: 1.0, green: 0.88, blue: 0.55)],
                    characters: [
                        ScenarioCharacter(name: "Reisender", imageName: "person.fill", speechBubble: "Ich brauche Wasser!")
                    ],
                    needs: ["drop.fill", "sun.max.fill"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Mitten in der Wüste ist eine Familie auf der Suche nach Wasser. Verbinde die Rohre um eine Wasserleitung zu bauen!"
                )
            ],
            rewardText: "Das Wasser fließt! Die Familie kann wieder trinken.",
            backgroundColors: [Color(red: 0.9, green: 0.7, blue: 0.25), Color(red: 1.0, green: 0.85, blue: 0.5)],
            difficultyLabel: "Mittel"
        ),

        // MARK: - Level 7 — City Rebuild (Match-3)
        GameLevel(
            id: 6,
            title: "Stadtwiederaufbau",
            subtitle: "Bau die Stadt wieder auf!",
            scenario: .cityRebuild,
            type: .match3(config: Match3Config(
                rows: 9, cols: 9, tileTypes: 6,
                targetScore: 2000, moveLimit: 35,
                specialGoals: [
                    TileGoal(tileColor: .red, count: 25),
                    TileGoal(tileColor: .yellow, count: 20),
                    TileGoal(tileColor: .blue, count: 15)
                ]
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.4, green: 0.4, blue: 0.5), Color(red: 0.6, green: 0.65, blue: 0.75)],
                    characters: [
                        ScenarioCharacter(name: "Bürgermeister", imageName: "person.fill", speechBubble: "Wir brauchen Ressourcen!"),
                        ScenarioCharacter(name: "Bürger", imageName: "person.2.fill", speechBubble: "Bitte hilf uns!")
                    ],
                    needs: ["building.2.fill", "hammer.fill"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Nach einer Katastrophe liegt die Stadt in Trümmern. Sammle Baumaterialien um die wichtigsten Gebäude wiederherzustellen!"
                )
            ],
            rewardText: "Die Stadt erstrahlt in neuem Glanz! Alle Bürger sind dankbar.",
            backgroundColors: [Color(red: 0.38, green: 0.42, blue: 0.55), Color(red: 0.58, green: 0.63, blue: 0.78)],
            difficultyLabel: "Schwer"
        ),

        // MARK: - Level 8 — Forest Restore (Balance)
        GameLevel(
            id: 7,
            title: "Waldrettung",
            subtitle: "Rette den Wald!",
            scenario: .forestRestore,
            type: .balanceChallenge(config: BalanceConfig(
                sliderCount: 5,
                targetRatio: 0.65,
                tolerance: 0.06
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.15, green: 0.5, blue: 0.2), Color(red: 0.3, green: 0.7, blue: 0.3)],
                    characters: [
                        ScenarioCharacter(name: "Försterin", imageName: "person.fill", speechBubble: "Der Wald stirbt!")
                    ],
                    needs: ["leaf.fill", "drop.fill"],
                    titleText: "Stell dich der Herausforderung!",
                    bodyText: "Der Wald leidet unter Trockenheit. Balanciere Wasser und Nährstoffe um die Bäume zu retten!"
                )
            ],
            rewardText: "Der Wald erholt sich! Die Natur dankt dir.",
            backgroundColors: [Color(red: 0.12, green: 0.48, blue: 0.18), Color(red: 0.28, green: 0.68, blue: 0.28)],
            difficultyLabel: "Schwer"
        ),

        // MARK: - Level 9 — Ocean Clean (Thermometer)
        GameLevel(
            id: 8,
            title: "Meeresreinigung",
            subtitle: "Rette den Ozean!",
            scenario: .oceanClean,
            type: .thermometer(config: ThermometerConfig(
                targetFill: 0.9,
                moveLimit: 28,
                tileTypes: 5
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.05, green: 0.4, blue: 0.7), Color(red: 0.1, green: 0.6, blue: 0.85)],
                    characters: [
                        ScenarioCharacter(name: "Meeresbiologin", imageName: "person.fill", speechBubble: "Das Meer ist vergiftet!")
                    ],
                    needs: ["fish.fill", "drop.fill"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Ölverschmutzung bedroht das Meeresleben. Sammle Reinigungsmittel um das Ökosystem zu retten!"
                )
            ],
            rewardText: "Das Meer ist wieder sauber! Die Fische sind gerettet.",
            backgroundColors: [Color(red: 0.05, green: 0.38, blue: 0.68), Color(red: 0.1, green: 0.58, blue: 0.82)],
            difficultyLabel: "Sehr Schwer"
        ),

        // MARK: - Level 10 — Mountain Survival (Match-3)
        GameLevel(
            id: 9,
            title: "Bergrettung",
            subtitle: "Überlebe den Sturm!",
            scenario: .mountainSurvival,
            type: .match3(config: Match3Config(
                rows: 9, cols: 9, tileTypes: 6,
                targetScore: 3000, moveLimit: 40,
                specialGoals: [
                    TileGoal(tileColor: .purple, count: 30),
                    TileGoal(tileColor: .orange, count: 25),
                    TileGoal(tileColor: .red, count: 20)
                ]
            )),
            storySlides: [
                StorySlide(
                    backgroundGradient: [Color(red: 0.5, green: 0.5, blue: 0.6), Color(red: 0.75, green: 0.8, blue: 0.88)],
                    characters: [
                        ScenarioCharacter(name: "Bergsteiger", imageName: "figure.hiking", speechBubble: "Wir sitzen fest!"),
                        ScenarioCharacter(name: "Retter", imageName: "person.fill", speechBubble: "Ich komme euch holen!")
                    ],
                    needs: ["mountain.2.fill", "wind"],
                    titleText: "Hilf ihnen!",
                    bodyText: "Eine Gruppe Bergsteiger ist auf dem Gipfel eingeschlossen. Ein Sturm zieht auf! Sammle schnell Überlebensausrüstung!"
                )
            ],
            rewardText: "Alle Bergsteiger sind in Sicherheit! Ein wahrer Held!",
            backgroundColors: [Color(red: 0.48, green: 0.52, blue: 0.62), Color(red: 0.72, green: 0.78, blue: 0.88)],
            difficultyLabel: "Experte"
        )
    ]
}
