// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./IERC20.sol";
import "./SafeMath.sol";

contract Registration {
    
    using SafeMath for uint;
    
    uint PERIOD = 1 weeks;
    uint LOCK_AMOUNT = 100;
    struct regInfo {
        string name;
        uint regTime;
    }
    mapping(address=>string) public infoOf;
    IERC20 public token;
    
    uint txCounter;
    
    constructor (address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }
    
    function register(string memory _name, uint _txCounter) external {
        // this function is called by user when they want to register a new name
        require(txCounter == _txCounter, "Unintended transaction");
        require(infoOf[msg.sender].name == '', "You have already registered. You can renew existing name");
        require(token.balanceOf(msg.sender) > LOCK_AMOUNT, "Insufficient amount to register the name");
        infoOf[msg.sender].name = _name;
        txCounter = txCounter.add(1);
        infoOf[msg.sender].regTime = block.timestamp;
        token.transferFrom(msg.sender, address(this), LOCK_AMOUNT);
    }
    
    function renew() external {
        // this function is called by user when they want to renew their registration
        require(infoOf[msg.sender].regTime.add(PERIOD) < block.timestamp, "Your registration was already expired");
        infoOf[msg.sender].regTime = block.timestamp;
        txCounter = txCounter.add(1);
    }
    
    function expire(address _userAddress) external {
        // this function is called automatically by external service when registration period of certain user expires
        require(infoOf[_userAddress].name != '', "Registration of this address was already expired");
        uint feeAmount = bytes(infoOf[_userAddress].name).length;
        uint unlockAmount = LOCK_AMOUNT.sub(feeAmount);
        infoOf[_userAddress].name = '';
        txCounter = txCounter.add(1);
        token.transfer(_userAddress, unlockAmount);
    }
    
}