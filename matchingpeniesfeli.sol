// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MatchingPennies {
    address public playerA;
    address public playerB;
    uint public betAmount;

    enum Option { None, Heads, Tails }
    Option private playerAChoice;
    Option private playerBChoice;

    enum GameState { WaitingForPlayers, WaitingForChoices, GameEnded }
    GameState public gameState;

    mapping(address => uint) public balances;

    // Events for logging actions
    event GameStarted(address playerA, address playerB, uint betAmount);
    event PlayerMadeChoice(address player, Option choice);
    event GameEnded(address winner, uint reward);

    modifier onlyPlayers() {
        require(msg.sender == playerA || msg.sender == playerB, "Only players can interact with the contract");
        _;
    }

    modifier inState(GameState state) {
        require(gameState == state, "Invalid game state for this action");
        _;
    }

    // Constructor to initialize the game
    constructor(address _playerB, uint _betAmount) {
        playerA = msg.sender;
        playerB = _playerB;
        betAmount = _betAmount;
        gameState = GameState.WaitingForChoices;
        balances[playerA] = 0;
        balances[playerB] = 0;
        emit GameStarted(playerA, playerB, betAmount);
    }

    // Function for Player A to make a choice
    function makeChoiceA(Option choice) external payable onlyPlayers inState(GameState.WaitingForChoices) {
        require(msg.sender == playerA, "Only Player A can make this choice");
        require(msg.value + balances[playerA]>= betAmount, "Insufficient bet amount");
        balances[playerA] += msg.value;
        playerAChoice = choice;
        checkGameEnd();
    }

    // Function for Player B to make a choice
    function makeChoiceB(Option choice) external payable onlyPlayers inState(GameState.WaitingForChoices) {
        require(msg.sender == playerB, "Only Player B can make this choice");
        require(msg.value + balances[playerB] >= betAmount, "Insufficient bet amount");
        balances[playerB] += msg.value;
        playerBChoice = choice;
        checkGameEnd();
    }

    // Check if both players have made a choice and determine the winner
    function checkGameEnd() internal {
        if (playerAChoice != Option.None && playerBChoice != Option.None) {
            //address winner = determineWinner();
            gameState = GameState.GameEnded;
            if (playerAChoice == playerBChoice) {
                balances[playerA] -= betAmount;
                balances[playerB] += (betAmount);  // Player B wins if choices are the same
            } else {
                balances[playerB] -= betAmount;
                balances[playerA]+= (betAmount);  // Player A wins if choices are different
            }
        }
    }


    // Reset the game and allow new game
    function resetGame(address _newPlayerB, uint _betAmount) external inState(GameState.GameEnded) {
        require(msg.sender == playerA, "Only Player A can reset the game");
        playerB = _newPlayerB;
        gameState = GameState.WaitingForChoices;
        playerAChoice = Option.None;
        playerBChoice = Option.None;
        betAmount = _betAmount;
        emit GameStarted(playerA, playerB, betAmount);
    }

    // View function to get the balance of a player
    function getBalance() external view returns (uint) {
        return balances[msg.sender];
    }

    function withdraw() external payable {
        require(gameState != GameState.WaitingForChoices, "You cannot withdraw while game has not ended");
        require(balances[msg.sender]>0, "No money on balance");
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
