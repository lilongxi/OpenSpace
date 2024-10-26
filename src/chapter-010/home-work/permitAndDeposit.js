/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-26 16:24:51
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-26 16:26:09
 * @FilePath: /OpenSpace/src/chapter-010/home-work/permitAndDeposit.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const { ethers } = require("ethers");

async function permitAndDeposit(tokenBankContract, owner, spender, amount) {
    const nonce = await token.nonces(owner);
    const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10分钟后过期

    // EIP-712 类型定义
    const domain = {
        name: "MyCustomToken",
        version: "1",
        chainId: 1, // 主网的 Chain ID
        verifyingContract: token.address,
    };

    const types = {
        Permit: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
            { name: "value", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" },
        ],
    };

    const value = {
        owner: owner,
        spender: spender,
        value: amount,
        nonce: nonce.toString(),
        deadline: deadline,
    };

    // 生成签名
    const signature = await owner._signTypedData(domain, types, value);
    const { v, r, s } = ethers.utils.splitSignature(signature);

    // 调用 permitDeposit 方法进行授权存款
    await tokenBankContract.permitDeposit(owner, spender, amount, nonce, deadline, v, r, s);
}

// 示例用法
const tokenBankAddress = "0x052EFc2E00cc5968906B3767cC77b5C82018ED5F"; // TokenBank 合约地址
const tokenContractAddress = "0xe7C288Bb298277543481085193B495945BbE1661"; // ERC20Permit 代币合约地址
const ownerPrivateKey = "0xb98700fc90ae944111b6b16b774f45ab56db751d442bdc011add8412a1de6840"; // 代币持有者的私钥
const spender = tokenBankAddress; // 授权的地址
const amount = ethers.utils.parseUnits("1000", 18); // 存款金额（假设代币有18位小数）

const provider = new ethers.providers.JsonRpcProvider("https://sepolia.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231"); // RPC URL
const wallet = new ethers.Wallet(ownerPrivateKey, provider);
const tokenBankContract = new ethers.Contract(tokenBankAddress, TokenBankABI, wallet); // TokenBank 合约 ABI

permitAndDeposit(tokenBankContract, wallet.address, spender, amount)
    .then(() => console.log('存款成功'))
    .catch((error) => console.error('错误:', error));
