/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-20 17:03:36
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-20 17:29:38
 * @FilePath: /OpenSpace/src/chapter-008/index.tsx
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { createPublicClient, http } from 'viem'
import { mainnet } from "viem/chains";
import type { Address } from 'viem';
import ERC721ABI from '@openzeppelin/contracts/build/contracts/ERC721.json';

async function main(contractAddr: Address, tokenId: number) {

    const client = createPublicClient({
        chain: mainnet,
        transport: http()
    })

    try {
        const owner = await client.readContract({
            address: contractAddr,
            abi: ERC721ABI.abi,
            functionName: 'ownerOf',
            args: [
                tokenId
            ]
        })

        const tokenURI = await client.readContract({
            address: contractAddr,
            abi: ERC721ABI.abi,
            functionName: 'tokenURI',
            args: [tokenId],
        })

        return {
            owner,
            tokenURI
        }
    } catch (error) {
        return Promise.reject(error)
    }
}

main('0x0483b0dfc6c78062b9e999a82ffb795925381415', 1).then(({ owner, tokenURI }) => {
    console.log(`NFT 持有者地址: ${owner}`);
    console.log(`NFT 的元数据 URI: ${tokenURI}`);
}).catch(error => {
    console.error('读取合约信息时出错:', error);
})