# Game protocol

## Message types

* Connect

// request
{}

// answer
{
    "status": "connected",
    "player": "player1"
}

* Character select
// request
{
    "username": "player1",
    "character": "chewbacca"
}

// answer
{
    "status": "OK"
}

* Character select synchnization

// answer
{
    "player1": "chewbacca",
    "player2": "brutus"
}
