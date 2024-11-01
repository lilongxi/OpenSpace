/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-31 20:47:50
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-11-01 13:05:13
 * @FilePath: /OpenSpace/src/the-graph/nftfactorygraph/src/nftcontract.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
// import { NFTContract as NFTContractTemplate } from "../generated/templates/NFTContract/nft";
import { Transfer, nft } from "../generated/templates/NFTContract/NFT";
import { TokenInfo } from "../generated/schema";

export function handleTransfer(event: Transfer): void {
    
    const tokenId = event.params.tokenId;
    const id = event.address.toHex() + "-" + tokenId.toString();
    let tokenInfo = TokenInfo.load(id)
    if (tokenInfo == null) {
        tokenInfo = new TokenInfo(id);
        tokenInfo.ca = event.address;
        tokenInfo.tokenId = tokenId;
        // 获取合约信息
        let contract = nft.bind(event.address);
        let name = contract.try_name();
        let tokenURI = contract.try_tokenURI(tokenId);
        tokenInfo.name = name.reverted ? "" : name.value;
        tokenInfo.tokenURL = tokenURI.reverted ? "" : tokenURI.value;
    }
    // 更新 NFT 所有者及交易信息
    tokenInfo.owner = event.params.to;
    tokenInfo.blockNumber = event.block.number;
    tokenInfo.blockTimestamp = event.block.timestamp;
    tokenInfo.transactionHash = event.transaction.hash;

    tokenInfo.save();
}