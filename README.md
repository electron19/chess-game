# Chess Game

A native macOS chess game built with Swift and SwiftUI.

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 13.0 or later

## Features

- Full chess rules implementation
- All special moves: castling, en passant, pawn promotion (auto-queen)
- Check and checkmate detection
- Stalemate detection
- Captured pieces panel
- Board coordinates (a–h, 1–8)
- Clean, native macOS UI

## Getting Started

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Select the `ChessGame` scheme and run

## Architecture

```
Sources/
├── ChessCore/          — Game logic library (no SwiftUI dependency)
│   ├── Models/         — Piece, Position, Move, Board, GameState
│   └── Engine/         — MoveGenerator (legal moves, check detection)
└── ChessGame/          — macOS SwiftUI application
    └── Views/          — BoardView, SquareView, GameInfoView, CapturedPiecesView

Tests/
└── ChessGameTests/     — Unit tests for ChessCore
```

## License

MIT
