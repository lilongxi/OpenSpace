import { createPublicClient, http, formatEther, getAddress, Address, Hash, keccak256, toHex } from "viem";
import { arbitrumSepolia } from 'viem/chains'

async function main() {
    const client = createPublicClient({
        chain: arbitrumSepolia,
        transport: http()
    })
    const contractAddr = '0x543FF5baFD7fcD727711900A48F040B4405D4618'
    const lengthSlot = ('0x' + '0'.padStart(64, '0')) as Hash // 设置第一个存储槽
    const length = await client.getStorageAt({ address: contractAddr as Address, slot: lengthSlot })
    
    const arrayLength = BigInt(length || '0x0')
    // console.log('arrayLength:', arrayLength)

    const arraySlot = ('0x' + '0'.padStart(64, '0')) as `0x${string}`
    // 获取第一个槽位的存储地址
    const baseSlot = keccak256(arraySlot)
    
    for(let i = BigInt(0); i < arrayLength; i++) {
        // 获取下一个槽位的存储地址
        // 每个元素占两个存储槽 
        /**
         *  struct LockInfo {
                address user;     // 20 bytes
                uint64 startTime; // 8 bytes
                uint256 amount;   // 32 bytes
            }
         */
        const currentSlot = toHex(BigInt(baseSlot) + BigInt(i) * BigInt(2), { size: 32 })
        const slot1 = currentSlot as Hash

        // 从第一个插槽开始
        const data = await client.getStorageAt({
            address: contractAddr as Address,
            slot: slot1
        })

         // read second slot (amount)
        const nextSlot = toHex(BigInt(baseSlot) + BigInt(i) * BigInt(2) + BigInt(1), { size: 32 }) as Hash
        const amountData = await client.getStorageAt({
            address: contractAddr as Address,
            slot: nextSlot
        })

        if (!data || !amountData) continue

        // 根据不同的数据占用的字节大小获取 锁仓信息
        const user = getAddress('0x' + data.slice(-40)) // last 20 bytes are user address
        const startTimeHex = '0x' + data.slice(10, 26) // middle 8 bytes are startTime
        const startTime = Number(BigInt(startTimeHex))
        const amount = BigInt(amountData) // 32 bytes -> uint256

        console.log(`locks[${i}]:`)
        console.log(`  user: ${user}`)
        console.log(`  startTime: ${new Date(startTime * 1000).toLocaleString()} (${startTime})`)
        console.log(`  amount: ${formatEther(amount)} ETH`)

         // Debug information
         console.log(`  Debug - slot1 data: ${data}`)
         console.log(`    Offset: 0 - padding: ${data.slice(2, 10)}`)    // first 4 bytes (padding)
         console.log(`    Offset: 4 - startTime: ${data.slice(10, 26)}`) // middle 8 bytes
         console.log(`    Offset: 12 - user: ${data.slice(-40)}`)        // last 20 bytes
         console.log(`  Debug - slot2 data (amount): ${amountData}`)
         console.log('----------------------------------------')

    }

}

main()