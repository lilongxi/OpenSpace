// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// contract MyToken is ERC20 {
//     constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
//         // 铸造代币并将其分配给合约的拥有者
//         _mint(msg.sender, initialSupply * 10 ** decimals());
//     }
// }

import "./BaseERC20.sol";

contract HHMyToken is BaseERC20 {
    constructor(uint initialSupply) BaseERC20("HHMyToken", "HHMTK") {
        address owner = _msgSender();
        _mint(owner, initialSupply * 10 ** decimals);
    }
}
