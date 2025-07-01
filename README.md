# checkers

<br>

This project aims at creating a mobile app which will allow users to play checkers against one another locally, or against an AI minmax opponent. As of now, a basic computer opponent has been implemented.

<br>

## Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/899354df-1c8c-4935-96c8-66a58f056fa0" width="200" alt="Game Start">
  <img src="https://github.com/user-attachments/assets/71de7bb8-267e-4dbd-9118-1b2d7beb571e" width="200" alt="Mid Game"> 
  <img src="https://github.com/user-attachments/assets/a9c9ad88-6ea2-4af1-ad20-c1358aa3e343" width="200" alt="King Promotion">
  <img src="https://github.com/user-attachments/assets/51ec97d5-1357-46c1-b465-6c7b6446ca53" width="200" alt="Game Over">
</div>


## Features

✅ **Complete Game Logic**
- Standard 8x8 checkers rules
- Mandatory captures
- King promotion
- Win condition detection

🎨 **Clean UI**
- Minimalist material design
- Responsive layout
- Themed dialog boxes
- Custom piece widgets

🕹️ **Game Flow**
- Turn-based gameplay
- Game over detection
- Winner declaration dialog

## AI Opponent(beta)

- A basic AI opponent has been implemented using the Minimax with alpha beta pruning.
- The tree goes 4 levels deep before running the evaluation function.
- The evaluation function performs a standard material evaluation with a 3x multiplier for king pieces. Positional advantage        scores might be added to the function in the future.   
- The option to switch between AI and a normal human player will be added soon.
- When the AI performs consecutive captures, it will not be shown step by step. This will be changed in the future in favour of a   better UX.
