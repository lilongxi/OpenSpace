/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-26 15:47:00
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-26 16:25:47
 * @FilePath: /OpenSpace/src/chapter-010/home-work/index.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const { ethers } = require("ethers");
const MyCustomToken = require("./artifacts/MyCustomToken.json");

// 创建一个提供者和钱包
const provider = new ethers.providers.JsonRpcProvider("https://sepolia.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231"); // 替换为你的 RPC URL
const wallet = new ethers.Wallet("0xb98700fc90ae944111b6b16b774f45ab56db751d442bdc011add8412a1de6840", provider); // 替换为你的私钥


async function permitAndTransfer(tokenContract , owner, spender, amount) {
    const tokenContract = new ethers.Contract("0xe7C288Bb298277543481085193B495945BbE1661", MyCustomToken.abi, wallet); // 替换为你的合约地址
    const nonce = await tokenContract.nonces(owner);
    const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10 分钟后过期

    // EIP-712 类型定义
    const domain = {
        name: "MyCustomToken",
        version: "1",
        chainId: 1, // 主网的 Chain ID，替换为对应的 Chain ID
        verifyingContract: tokenContract.address,
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

    // 调用 permit 方法授权
    await tokenContract.permit(owner, spender, amount, deadline, v, r, s);
    
    // 现在 spender 可以使用 transferFrom
    await tokenContract.transferFrom(owner, recipient, transferAmount);
}

const owner = wallet.address; // 当前钱包地址
const spender = "0x052EFc2E00cc5968906B3767cC77b5C82018ED5F"; // 授权的地址
const amount = ethers.utils.parseUnits("1000", 18); // 授权的代币数量（假设代币有18位小数）
const recipient = "0xRecipientAddress"; // 代币接收者的地址

permitAndTransfer(owner, spender, amount, recipient)
    .then(() => console.log('授权成功并转账'))
    .catch((error) => console.error('错误:', error));