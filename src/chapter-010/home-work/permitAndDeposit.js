/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-26 16:24:51
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-27 12:17:12
 * @FilePath: /OpenSpace/src/chapter-010/home-work/permitAndDeposit.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const { ethers } = require("ethers");
const { tokenBankAddress, tokenContractAddress, ownerPrivateKey, jsonRpcUrl } = require('./address')
const TokenBankABI = require("./artifacts/TokenBank.json");
const MyCustomToken = require("./artifacts/MyCustomToken.json");

async function permitDeposit(tokenBankAddress, tokenAddress, ownerPrivateKey, amount) {
    // 初始化 provider 和 signer
    const provider = new ethers.JsonRpcProvider(jsonRpcUrl);
    const ownerSigner = new ethers.Wallet(ownerPrivateKey, provider);
    
    // 获取合约实例
    // const tokenABI = [
    //     "function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)",
    //     "function nonces(address owner) view returns (uint256)",
    //     "function name() view returns (string)"
    // ];

    const tokenContract = new ethers.Contract(tokenAddress, MyCustomToken.abi, ownerSigner);

    // const tokenBankABI = [
    //     "function permitDeposit(address token, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)"
    // ];
    const tokenBankContract = new ethers.Contract(tokenBankAddress, TokenBankABI.abi, provider);

    // 设置 permit 相关参数
    const nonce = await tokenContract.nonces(ownerSigner.address);
    const deadline = Math.floor(Date.now() / 1000) + 3600; // 1小时过期

    // EIP-712 域
    const name = await tokenContract.name();
    const domain = {
        name,
        version: "1",
        chainId: await provider.getNetwork().then(net => net.chainId),
        verifyingContract: tokenAddress,
    };

    const types = {
        Permit: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
            { name: "value", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" }
        ],
    };

    const value = {
        owner: ownerSigner.address,
        spender: tokenBankAddress,
        value: amount,
        nonce: nonce,
        deadline: deadline
    };

    // 生成签名
    const signature = await ownerSigner.signTypedData(domain, types, value);
    const { v, r, s } = ethers.Signature.from(signature);

    // 调用 permitDeposit
    const tx = await tokenBankContract.connect(ownerSigner).permitDeposit(
        tokenAddress,
        amount,
        deadline,
        v,
        r,
        s
    );

    console.log("Transaction Hash:", tx.hash);
    const receipt = await tx.wait();
    console.log("Transaction was mined in block:", receipt.blockNumber);
}

permitDeposit(
    tokenBankAddress,
    tokenContractAddress,
    ownerPrivateKey,
    ethers.parseUnits("1000", 18) // 存款金额（假设代币有18位小数）
)
    .then(() => console.log('存款成功'))
    .catch((error) => console.error('错误:', error));
