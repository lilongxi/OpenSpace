// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v4_9/contracts/utils/Address.sol";
import "../BaseERC20.sol";

interface IERC20WithCallback  {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external;
}

contract ERC20WithCallback is BaseERC20 {
    constructor(string memory name, string memory symbol) BaseERC20(name, symbol) {}

    function transferWithCallback(
        address to,
        uint amount,
        bytes calldata data
    ) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        if (Address.isContract(to)) {
            try IERC20WithCallback(address(to)).tokensReceived(_msgSender(), amount, data) {
                
            } catch (bytes memory reason) {
                 revert("ERC20WithCallback: tokensReceived failed");
            }
        }
        return true;
    }

}