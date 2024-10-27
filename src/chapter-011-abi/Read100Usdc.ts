/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-27 17:46:48
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-27 18:17:43
 * @FilePath: /OpenSpace/src/chapter-011-abi/read100Usdc.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { createPublicClient, formatUnits, http, parseAbiItem } from "viem";
import { mainnet } from "viem/chains";

const client = createPublicClient({
    chain: mainnet,
    // transport: http('https://sepolia.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231'),
    // transport: http('https://mainnet.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231')
    transport: http('https://rpc.flashbots.net')
})


// USDC 合约地址（以太坊主网）
//  0x25f8123B0fF2A3DAFA8F3F0C1443B1E35E25A0F5
const USDC_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
// Transfer 事件的 ABI 格式
const TRANSFER_EVENT_ABI = parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)');

async function readRecentUsdcTransfers() {
    const latestBlock = await client.getBlockNumber();
    const fromBlock = latestBlock - BigInt(100);

    console.log(fromBlock)
    
    try {
        const logsFilter = await client.createEventFilter({
            address: USDC_ADDRESS,
            fromBlock,
            toBlock: 'latest',
            event:TRANSFER_EVENT_ABI
        })
        const logs = await client.getFilterLogs({ filter: logsFilter });
        logs.forEach((log) => {
            const { from, to, value } = log.args || {}
            const formattedValue = Number(formatUnits(value!, 6)).toFixed(5);
            console.log(`从 ${from} 转账给 ${to} ${formattedValue} USDC, 交易ID：${log.transactionHash}`);
        })
    } catch (error) {
        console.log(error)
    }

}

readRecentUsdcTransfers()