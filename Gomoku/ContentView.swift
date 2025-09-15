import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(NSLocalizedString("Gomoku", comment: "App Title"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Toggle(NSLocalizedString("AI Opponent", comment: "AI toggle"), isOn: $viewModel.isAIEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(!viewModel.canToggleAI)
                    .accessibilityIdentifier("AI Enabled")
                    .accessibilityLabel(NSLocalizedString("AI Opponent", comment: "AI toggle"))
                    .accessibilityHint(viewModel.canToggleAI ? NSLocalizedString("Toggle to enable or disable AI opponent", comment: "") : NSLocalizedString("Cannot change AI setting during game", comment: ""))
                    .accessibilityValue(viewModel.isAIEnabled ? NSLocalizedString("Enabled", comment: "") : NSLocalizedString("Disabled", comment: ""))
            }
            .padding(.horizontal)
            
            HStack {
                if viewModel.isAIThinking {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                            Text(viewModel.aiThinkingProgress.isEmpty ? NSLocalizedString("AI is thinking...", comment: "") : viewModel.aiThinkingProgress)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .accessibilityLabel(NSLocalizedString("AI Status", comment: ""))
                                .accessibilityValue(viewModel.aiThinkingProgress)
                                .accessibilityIdentifier("AIStatusLabel")
                        }
                        
                        if viewModel.aiEvaluatedMoves > 0 {
                            HStack(spacing: 15) {
                                Label(String(format: NSLocalizedString("%d positions", comment: "evaluated positions count"), viewModel.aiEvaluatedMoves), systemImage: "checkmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if viewModel.aiSearchDepth > 0 {
                                    Label(String(format: NSLocalizedString("Depth: %d", comment: "search depth"), viewModel.aiSearchDepth), systemImage: "arrow.down.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Text("\(NSLocalizedString("Current Player:", comment: "")) \(viewModel.currentPlayer.localizedName)")
                        .font(.title2)
                        .accessibilityLabel(NSLocalizedString("Current Player:", comment: ""))
                        .accessibilityValue(viewModel.currentPlayer.localizedName)
                        .accessibilityHint(NSLocalizedString("The player who should make the next move", comment: "current player hint"))
                        .accessibilityIdentifier("CurrentPlayerLabel")
                }
                
                Spacer()
                
                if let winner = viewModel.winner {
                    Text("\(NSLocalizedString("Winner:", comment: "")) \(winner.localizedName)")
                        .font(.title2)
                        .foregroundColor(.green)
                        .accessibilityIdentifier("WinnerLabel")
                        .accessibilityLabel(NSLocalizedString("Game Winner", comment: ""))
                        .accessibilityValue(String(format: NSLocalizedString("%@ has won the game", comment: "winner announcement"), winner.localizedName))
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                let boardPixels = min(geometry.size.width, geometry.size.height) - 40
                let gridSize = viewModel.boardSize
                let cellSize = boardPixels / CGFloat(gridSize)
                
                ZStack {
                    BoardGrid(size: gridSize, cellSize: cellSize)
                        .accessibilityIdentifier("GameBoard")
                        .accessibilityLabel(NSLocalizedString("Game Board", comment: ""))
                        .accessibilityHint(
                            String(
                                format: NSLocalizedString("%d by %d grid for playing Gomoku", comment: "grid description"),
                                gridSize, gridSize
                            )
                        )
                        .accessibilityElement(children: .ignore)
                    
                    ForEach(0..<gridSize, id: \.self) { row in
                        ForEach(0..<gridSize, id: \.self) { col in
                            StoneView(
                                player: viewModel.board[row][col],
                                isWinning: viewModel.winningLine.contains { $0.0 == row && $0.1 == col }
                            )
                            .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                            .position(
                                x: CGFloat(col) * cellSize + cellSize / 2,
                                y: CGFloat(row) * cellSize + cellSize / 2
                            )
                            .onTapGesture {
                                if !viewModel.isAIThinking {
                                    handleMove(row: row, col: col)
                                }
                            }
                            .accessibilityIdentifier(viewModel.board[row][col] == .none ? "Cell_\(row)_\(col)" : "Stone_\(viewModel.board[row][col].rawValue)_\(row)_\(col)")
                            .accessibilityLabel(getAccessibilityLabel(row: row, col: col))
                            .accessibilityHint(getAccessibilityHint(row: row, col: col))
                            .accessibilityAddTraits(getAccessibilityTraits(row: row, col: col))
                        }
                    }
                }
                .frame(width: boardPixels, height: boardPixels)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack(spacing: 20) {
                Button(NSLocalizedString("New Game", comment: "")) {
                    viewModel.reset()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("New Game")
                .accessibilityLabel(NSLocalizedString("New Game", comment: ""))
                .accessibilityHint(NSLocalizedString("Start a new game, clearing the board", comment: ""))
                
                if viewModel.isAIEnabled && viewModel.currentPlayer == .white && !viewModel.isGameOver {
                    Button(NSLocalizedString("AI Move", comment: "")) {
                        Task {
                            await viewModel.makeAIMove()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isAIThinking)
                    .accessibilityIdentifier("AI Move")
                    .accessibilityLabel(NSLocalizedString("Make AI Move", comment: ""))
                    .accessibilityHint(viewModel.isAIThinking ? NSLocalizedString("AI is currently thinking", comment: "") : NSLocalizedString("Trigger the AI to make its move", comment: ""))
                }
            }
            .padding()
        }
        .padding()
        .onChange(of: viewModel.isGameOver) { _ in
            if viewModel.shouldShowAlert {
                alertTitle = viewModel.alertTitle
                alertMessage = viewModel.alertMessage
                showingAlert = true
                UIAccessibility.post(notification: .screenChanged, argument: alertMessage)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button(NSLocalizedString("OK", comment: "Alert OK button")) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func getAccessibilityLabel(row: Int, col: Int) -> String {
        let player = viewModel.board[row][col]
        let position = String(
            format: NSLocalizedString("Row %d, Column %d", comment: "grid coordinates"),
            row + 1, col + 1
        )
        if player == .none {
            return String(
                format: NSLocalizedString("Empty cell at %@", comment: "empty cell label"),
                position
            )
        } else {
            let isWinning = viewModel.winningLine.contains { $0.0 == row && $0.1 == col }
            let base = String(
                format: NSLocalizedString("%@ stone at %@", comment: "stone label"),
                player.localizedName, position
            )
            if isWinning {
                return base + " (" + NSLocalizedString("winning stone", comment: "winning suffix") + ")"
            } else {
                return base
            }
        }
    }

    private func getAccessibilityHint(row: Int, col: Int) -> String {
        if viewModel.board[row][col] == .none {
            if !viewModel.isAIThinking && !viewModel.isGameOver {
                return String(
                    format: NSLocalizedString("Double tap to place %@ stone here", comment: "place hint"),
                    viewModel.currentPlayer.localizedName
                )
            } else if viewModel.isAIThinking {
                return NSLocalizedString("AI is thinking, please wait", comment: "thinking hint")
            } else if viewModel.isGameOver {
                return NSLocalizedString("Game is over, start a new game to play", comment: "game over hint")
            }
        }
        return NSLocalizedString("This position is already occupied", comment: "occupied hint")
    }
    
    private func getAccessibilityTraits(row: Int, col: Int) -> AccessibilityTraits {
        var traits = AccessibilityTraits()
        
        if viewModel.board[row][col] == .none && !viewModel.isAIThinking && !viewModel.isGameOver {
            traits.insert(.isButton)
        }
        
        if viewModel.winningLine.contains(where: { $0.0 == row && $0.1 == col }) {
            traits.insert(.isSelected)
        }
        
        return traits
    }
    
    private func handleMove(row: Int, col: Int) {
        let result = viewModel.makeMove(row: row, col: col)
        
        switch result {
        case .success:
            // Announce move for VoiceOver users
            let previousPlayer = viewModel.currentPlayer == .black ? Player.white : Player.black
            let moveAnnouncement = String(
                format: NSLocalizedString("%@ placed stone at row %d, column %d", comment: "move announcement"),
                previousPlayer.localizedName, row + 1, col + 1
            )
            UIAccessibility.post(notification: .announcement, argument: moveAnnouncement)
            
            if viewModel.shouldShowAlert {
                alertTitle = viewModel.alertTitle
                alertMessage = viewModel.alertMessage
                showingAlert = true
                
                // Announce game result for VoiceOver users
                UIAccessibility.post(notification: .screenChanged, argument: alertMessage)
            }
        case .failure(let error):
            alertTitle = NSLocalizedString("Invalid Move", comment: "")
            alertMessage = error.localizedDescription
            showingAlert = true
            
            // Announce error for VoiceOver users
            UIAccessibility.post(notification: .announcement, argument: alertMessage)
        }
    }
}

struct BoardGrid: View {
    let size: Int
    let cellSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let boardSize = CGFloat(self.size) * cellSize
            
            context.fill(
                Path(CGRect(x: 0, y: 0, width: boardSize, height: boardSize)),
                with: .color(Color(red: 0.9, green: 0.7, blue: 0.5))
            )
            
            for i in 0...self.size {
                let position = CGFloat(i) * cellSize
                
                var path = Path()
                path.move(to: CGPoint(x: position, y: 0))
                path.addLine(to: CGPoint(x: position, y: boardSize))
                context.stroke(path, with: .color(.black), lineWidth: 1)
                
                path = Path()
                path.move(to: CGPoint(x: 0, y: position))
                path.addLine(to: CGPoint(x: boardSize, y: position))
                context.stroke(path, with: .color(.black), lineWidth: 1)
            }
        }
    }
}

struct StoneView: View {
    let player: Player
    let isWinning: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        if player != .none {
            ZStack {
                // Glowing effect for winning stones
                if isWinning && !reduceMotion {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .scaleEffect(animationScale * 1.5)
                        .opacity(glowOpacity)
                        .animation(
                            reduceMotion ? nil : Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: glowOpacity
                        )
                }
                
                // Main stone
                Circle()
                    .fill(player == .black ? Color.black : Color.white)
                    .overlay(
                        Circle()
                            .stroke(
                                isWinning ? 
                                LinearGradient(
                                    colors: [Color.red, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [Color.gray],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isWinning ? 4 : 1
                            )
                    )
                    .shadow(color: isWinning ? Color.orange.opacity(0.5) : Color.black.opacity(0.2), 
                           radius: isWinning ? 5 : 2)
                    .scaleEffect(isWinning && !reduceMotion ? animationScale : 1.0)
                    .animation(
                        (isWinning && !reduceMotion) ? 
                        Animation.spring(response: 0.5, dampingFraction: 0.6)
                            .repeatForever(autoreverses: true) : 
                        nil,
                        value: animationScale
                    )
            }
            .onAppear {
                if isWinning && !reduceMotion {
                    withAnimation {
                        animationScale = 1.1
                        glowOpacity = 0.6
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
