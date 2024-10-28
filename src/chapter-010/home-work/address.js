/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-27 11:45:18
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-28 18:50:32
 * @FilePath: /OpenSpace/src/chapter-010/home-work/address.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
// 示例用法
const tokenBankAddress = "0xE3Ca443c9fd7AF40A2B5a95d43207E763e56005F"; // TokenBank 合约地址
const tokenContractAddress = "0xe7C288Bb298277543481085193B495945BbE1661"; // ERC20Permit 代币合约地址
const ownerPrivateKey = "b98700fc90ae944111b6b16b774f45ab56db751d442bdc011add8412a1de6840"; // 代币持有者的私钥
const spender = tokenBankAddress; // 授权的地址
const jsonRpcUrl = 'https://sepolia.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231'
const webscoketRpcUrl = 'wss://sepolia.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231'

module.exports = {
    tokenBankAddress,
    tokenContractAddress,
    ownerPrivateKey,
    spender,
    jsonRpcUrl,
    webscoketRpcUrl
}