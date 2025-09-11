# checkers

<br>

This project aims at creating a mobile app which will allow users to play checkers against one another locally, or against an AI minimax opponent. Users can choose whether to play against a human or AI opponent via the homepage of the app.
<br/>
The user can also choose a max-non capture move count. This refers to the total number of non-capture moves that can take place before the game ends in a tie.

<br>


## Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/5d043ec4-c6f9-429c-a4f2-8a7d2693cba0" width="200" alt="Game Homepage">
  <img src="https://github.com/user-attachments/assets/a171baf5-0bd3-4fce-9f2f-54401b5370b2" width="200" alt="Max-cap move"> 
  <img src="https://github.com/user-attachments/assets/943017c6-4a4c-4d57-b61c-4d8be71fa8ea" width="200" alt="mid-game">
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

## AI Opponent

- A basic AI opponent has been implemented using the Minimax with alpha beta pruning.
- The tree goes 4 levels deep before running the evaluation function.
- The evaluation function performs a standard material evaluation with a 3x multiplier for king pieces. Positional advantage scores are not taken into consideration.
