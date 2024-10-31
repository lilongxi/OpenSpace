/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-31 18:12:30
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-31 21:07:25
 * @FilePath: /OpenSpace/src/the-graph/nftfactorygraph/src/nftfactorygraph.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import {
  NFTCreated as NFTCreatedEvent,
  NFTRegesitered as NFTRegesiteredEvent,
  OwnershipTransferred as OwnershipTransferredEvent
} from "../generated/nftfactorygraph/nftfactorygraph"
import {
  NFTCreated,
  NFTRegesitered,
  OwnershipTransferred,
  TokenInfo
} from "../generated/schema"

export function handleNFTCreated(event: NFTCreatedEvent): void {
  let entity = new NFTCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNFTRegesitered(event: NFTRegesiteredEvent): void {
  let entity = new NFTRegesitered(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNFTCreatedByNFTCA(event: NFTCreatedEvent): void {

  const nftAddress = event.params.nftCA
  // entity.nftCA = event.params.nftCA

  // entity.blockNumber = event.block.number
  // entity.blockTimestamp = event.block.timestamp
  // entity.transactionHash = event.transaction.hash

  // const entity = new TokenInfo(event.transaction.hash.concatI32(event.logIndex.toI32()).toString())

  // entity.ca = nftAddress
  // entity.tokenId = event.params.name
  // entity.tokenURL = event.params.tokenURL
  // entity.name = tokenInfo.name
  // entity.owner = tokenInfo.owner
  // entity.blockNumber = event.block.number
  // entity.blockTimestamp = event.block.timestamp
  // entity.transactionHash = event.transaction.hash
  // entity.save()

}