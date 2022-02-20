# @title Voting Smart Contract
# @notice This is a smart contract that facilitates voting exercise directly on the blockchain without any intermediaries
# @author Timileyin Pelumi http://github.com/timmy-oss
# @dev Written in Vyper




event Vote:
    voter : address
    choice : bytes32

event VotingEnded:
    winner : bytes32


anchor : public(address)
voters : public( HashMap[ address, bool] )
votes : public(HashMap[ uint256 , uint256])
proposals : public(bytes32[3])
startTime : public(uint256)
endTime : public( uint256)
winner :  bytes32
isOver : public(bool)


@external
def __init__( _proposals : bytes32[3], _startTime : uint256, _duration  :uint256):
    self.anchor = msg.sender
    self.endTime = self.startTime + _duration
    assert self.startTime > block.timestamp
    assert self.endTime > block.timestamp
    assert _proposals != empty(bytes32[3])
    self.isOver  = False

    for i in range(3):
        self.proposals[i] = _proposals[i]



@external
def vote( _choice : uint256):

    # @dev Validation checks
    # @dev Add up vote and register voter as 'voted'

    assert _choice < 3 , 'Invalid choice index, 0 - 2'
    assert self.anchor != msg.sender
    assert block.timestamp > self.startTime, 'Voting has not started'
    assert self.endTime > block.timestamp, 'Voting has ended'
    assert self.voters[msg.sender] != True, 'Voted already'
    self.voters[msg.sender] = True
    self.votes[_choice] += 1
    log Vote(msg.sender, self.proposals[_choice])


@external
def determineWinner() -> bytes32:

    # @dev Performs validation checks first
    # @dev Calculates the choice with the highest vote and sets it as the winner
    assert msg.sender == self.anchor
    assert block.timestamp > self.endTime

    if( self.isOver):
        return self.winner

    winnerVotes : uint256  = 0
    for i in range(3):
        if (self.votes[i] > winnerVotes):
            self.winner = self.proposals[i]
            winnerVotes = self.votes[i]

    self.isOver = True
    log VotingEnded(self.winner)
    return self.winner






