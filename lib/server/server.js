const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

const GRID_SIZE = 5;
const players = {
  'Player1': {
    characters: [
      { name: 'P1', type: 'Pawn', position: [0, 0] },
      { name: 'P2', type: 'Pawn', position: [1, 0] },
      { name: 'H1', type: 'Hero1', position: [2, 0] },
      { name: 'H2', type: 'Hero2', position: [3, 0] },
      { name: 'P3', type: 'Pawn', position: [4, 0] }
    ],
    eliminated: []
  },
  'Player2': {
    characters: [
      { name: 'P1', type: 'Pawn', position: [0, 4] },
      { name: 'P2', type: 'Pawn', position: [1, 4] },
      { name: 'H1', type: 'Hero1', position: [2, 4] },
      { name: 'H2', type: 'Hero2', position: [3, 4] },
      { name: 'P3', type: 'Pawn', position: [4, 4] }
    ],
    eliminated: []
  }
};

const initializeGameState = () => ({
  board: [
    'Player1-P1', 'Player1-P2', 'Player1-H1', 'Player1-H2', 'Player1-P3',
    null, null, null, null, null,
    null, null, null, null, null,
    null, null, null, null, null,
    'Player2-P1', 'Player2-P2', 'Player2-H1', 'Player2-H2', 'Player2-P3'
  ],
  players,
  currentPlayer: 'Player1',
  gameOver: false
});

let gameState = initializeGameState();

function broadcastGameState() {
  const state = JSON.stringify({ type: 'gameState', state: gameState });
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(state);
    }
  });
}

function getIndex(x, y) {
  return y * GRID_SIZE + x;
}

function isInBounds(x, y) {
  return x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE;
}

function handleMove(move) {
  const { player, characterName, move: moveCommand } = move;
  const opponent = player === 'Player1' ? 'Player2' : 'Player1';
  const playerData = gameState.players[player];
  const character = playerData.characters.find(c => c.name === characterName);

  if (!character || gameState.gameOver) {
    return { type: 'invalidMove', message: 'Character not found or game over' };
  }

  const position = character.position;
  const [x, y] = position;
  let newX = x;
  let newY = y;

  switch (moveCommand) {
    case 'L':
      newX -= 1;
      break;
    case 'R':
      newX += 1;
      break;
    case 'F':
      newY -= 1;
      break;
    case 'B':
      newY += 1;
      break;
    case 'FL':
      newX -= 2;
      newY -= 2;
      break;
    case 'FR':
      newX += 2;
      newY -= 2;
      break;
    case 'BL':
      newX -= 2;
      newY += 2;
      break;
    case 'BR':
      newX += 2;
      newY += 2;
      break;
    default:
      return { type: 'invalidMove', message: 'Invalid move command' };
  }

  if (!isInBounds(newX, newY)) {
    return { type: 'invalidMove', message: 'Move out of bounds' };
  }

  const targetIndex = getIndex(newX, newY);
  const targetCell = gameState.board[targetIndex];
  if (targetCell && targetCell.startsWith(player)) {
    return { type: 'invalidMove', message: 'Move targets own character' };
  }
  gameState.board[getIndex(x, y)] = null;
  character.position = [newX, newY];
  gameState.board[targetIndex] = `${player}-${characterName}`;
  if (character.type === 'Hero1' || character.type === 'Hero2') {
    const directions = {
      'L': [-1, 0], 'R': [1, 0], 'F': [0, -1], 'B': [0, 1],
      'FL': [-1, -1], 'FR': [1, -1], 'BL': [-1, 1], 'BR': [1, 1]
    };

    const [dx, dy] = directions[moveCommand];
    let step = 1;
    while (step <= (character.type === 'Hero1' ? 2 : 2)) {
      const checkX = x + step * dx;
      const checkY = y + step * dy;
      if (isInBounds(checkX, checkY)) {
        const checkIndex = getIndex(checkX, checkY);
        const target = gameState.board[checkIndex];
        if (target && !target.startsWith(player)) {
          gameState.players[opponent].eliminated.push(target);
          gameState.board[checkIndex] = null;
        }
      }
      step++;
    }
  }
  gameState.currentPlayer = gameState.currentPlayer === 'Player1' ? 'Player2' : 'Player1';
  const allEliminated = Object.keys(gameState.players).some(p =>
    gameState.players[p].characters.every(c => gameState.players[opponent].eliminated.includes(c.name))
  );
  if (allEliminated) {
    gameState.gameOver = true;
    return { type: 'gameOver', message: `${player} wins!` };
  }

  return { type: 'gameState', state: gameState };
}

wss.on('connection', ws => {
  ws.send(JSON.stringify({ type: 'gameState', state: gameState }));

  ws.on('message', message => {
    const data = JSON.parse(message);
    let response;

    switch (data.type) {
      case 'playerMove':
        response = handleMove(data.move);
        broadcastGameState();
        break;
      case 'initializeGame':
        break;
      default:
        response = { type: 'error', message: 'Unknown message type' };
    }

    if (response) {
      ws.send(JSON.stringify(response));
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

console.log('WebSocket server is running on ws://localhost:8080');
