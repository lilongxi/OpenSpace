// // SPDX-License-Identifier: SEE LICENSE IN LICENSE

// pragma solidity >=0.7.0 <0.9.0;

// import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";
// import "permit2/src/Permit2.sol"; // Permit2合约的接口或具体实现

// contract TokenBankPermit2 {

//     ERC20Permit public token;
//     Permit2 public permit2;

//     mapping (address => uint) public balances;

//     event Desposit(address indexed user, uint amount);
//     event DespositWithPermit2(address indexed user, uint amount);

//     constructor(address _token, address _permit2) {
//         token = ERC20Permit(_token);
//         permit2 = Permit2(_permit2);
//     }

//     function  depositWithPermit2(
//         address owner,
//         uint amount,
//         uint deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     )  external {
//           // 使用 Permit2 进行授权
//         permit2.permit(owner, address(this), amount, deadline, v, r, s);
//         // 执行存款逻辑
//         token.transferFrom(owner, address(this), amount);
//         balances[owner] += amount;
//         emit DespositWithPermit2(owner, amount);
//     }

//     function balanceOf(address account) external view returns (uint) {
//         return balances[account];
//     }

// }