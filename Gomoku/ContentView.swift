import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Gomoku")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Toggle("AI Opponent", isOn: $viewModel.isAIEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(!viewModel.canToggleAI)
                    .accessibilityIdentifier("AI Enabled")
            }
            .padding(.horizontal)
            
            HStack {
                if viewModel.isAIThinking {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("AI is thinking...")
                            .font(.title2)
                    }
                } else {
                    Text("Current Player: \(viewModel.currentPlayer.rawValue)")
                        .font(.title2)
                }
                
                Spacer()
                
                if let winner = viewModel.winner {
                    Text("Winner: \(winner.rawValue)")
                        .font(.title2)
                        .foregroundColor(.green)
                        .accessibilityIdentifier("Winner: \(winner.rawValue)")
                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                let boardSize = min(geometry.size.width, geometry.size.height) - 40
                let cellSize = boardSize / CGFloat(15)
                
                ZStack {
                    BoardGrid(size: 15, cellSize: cellSize)
                        .accessibilityIdentifier("GameBoard")
                    
                    ForEach(0..<15, id: \.self) { row in
                        ForEach(0..<15, id: \.self) { col in
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
                        }
                    }
                }
                .frame(width: boardSize, height: boardSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack(spacing: 20) {
                Button("New Game") {
                    viewModel.reset()
                }
                .buttonStyle(.borderedProminent)
                
                if viewModel.isAIEnabled && viewModel.currentPlayer == .white && !viewModel.isGameOver {
                    Button("AI Move") {
                        Task {
                            await viewModel.makeAIMove()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isAIThinking)
                }
            }
            .padding()
        }
        .padding()
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleMove(row: Int, col: Int) {
        if viewModel.makeMove(row: row, col: col) {
            if viewModel.shouldShowAlert {
                alertTitle = viewModel.alertTitle
                alertMessage = viewModel.alertMessage
                showingAlert = true
            }
        } else {
            alertTitle = "Invalid Move"
            alertMessage = "This position is not available."
            showingAlert = true
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
    
    var body: some View {
        if player != .none {
            Circle()
                .fill(player == .black ? Color.black : Color.white)
                .overlay(
                    Circle()
                        .stroke(isWinning ? Color.red : Color.gray, lineWidth: isWinning ? 3 : 1)
                )
                .shadow(radius: 2)
        }
    }
}

#Preview {
    ContentView()
}