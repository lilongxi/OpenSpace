// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RNT is ERC20, ERC20Permit, Ownable {
    
    string private constant NAME = "RNT";

    constructor(
        uint256 initialSupply
    ) ERC20(NAME, NAME) ERC20Permit(NAME) Ownable(msg.sender) {   
        _mint(msg.sender, initialSupply);
    }
    
}