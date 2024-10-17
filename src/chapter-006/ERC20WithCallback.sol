// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./isContract.sol";
import "../BaseERC20.sol";

interface IERC20WithCallback  {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external returns(bool);
}

contract ERC20WithCallback is BaseERC20 {

    constructor(string memory name, string memory symbol) BaseERC20(name, symbol) {
    }
    
    event Received(address indexed from, uint256 amount);

    function transferWithCallback(
        address to,
        uint amount,
        bytes calldata data
    ) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        if (Address.isContract(to)) {
            try IERC20WithCallback(address(to)).tokensReceived(_msgSender(), amount, data) {
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

    function transferWithCallbackV2(address to, uint amount) external ERC20Invalid(to) returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        if (Address.isContract(to)) {
             (bool success,) = to.call(
                abi.encodeWithSignature("tokensReceived(address,uint256)", owner, amount)
            );
            require(success, "ERC20WithCallback: tokensReceived failed");
        }
        return true;
    }

}