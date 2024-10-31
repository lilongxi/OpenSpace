<!--
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-31 17:36:49
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-31 17:42:05
 * @FilePath: /OpenSpace/src/the-graph/readme.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
 cast send --rpc-url <rpc address> --private-key <private key> <nftMarket address> "list(address nft, uint256 tokenId, address payToken, uint256 price, uint256 deadline)" <nft address> 0 <token address> 10ether 2730367557823

  cast send --rpc-url https://sepolia.infura.io/v3/5960cd4ada0f4e5cad9a0fb398d2c231 --private-key b98700fc90ae944111b6b16b774f45ab56db751d442bdc011add8412a1de6840 0xBCBD610f2E4aeaF7265c2fcaa0dd7425fc4b253F "list(address nft, uint256 tokenId, address payToken, uint256 price, uint256 deadline)" 0x2EA7D6f1b6Df8Ca3829DD41A6f30c848F2D47CBC 0 0xBFa9BD1D21709F215664a4959fCdFB9fA0387425 10ether 2730367557823
