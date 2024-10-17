// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v4_9/contracts/utils/Address.sol";
import "../BaseERC20.sol";

interface IERC20WithCallback  {
    function tokensReceived(address from, uint256 amount) external returns(bool);
}


contract ERC20WithCallback is BaseERC20 {

    constructor(string memory name, string memory symbol) BaseERC20(name, symbol) {
    }
    
    event Received(address indexed from, uint256 amount);

    function transferWithCallback(
        address to,
        uint amount
    ) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        if (Address.isContract(to)) {
            try IERC20WithCallback(address(to)).tokensReceived(_msgSender(), amount) {
                emit Received(_msgSender(), amount);
            } catch (bytes memory reason) {
                 if (reason.length == 0) {
                    revert("ERC20WithCallback: tokensReceived failed");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
        return true;
    }

}