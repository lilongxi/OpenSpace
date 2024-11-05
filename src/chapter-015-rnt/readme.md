<!--
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-11-05 08:58:06
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-11-05 09:11:20
 * @FilePath: /OpenSpace/src/chapter-015-rnt/readme.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->

# Token 质押挖矿,挖矿得到 esRNT，esRNT 可兑换成 RNT

stakepool: 一个流动性池子, 可以质押RNT, 解押RNT, 以及产生的收益(奖励)获取esRNT
用RNT买入(这时候是不会立马获取到等价的esRNT), 可以随时赎回RNT
收益: 本金 * 10% = 1天的利润, 收益去兑换esRNT
RNT: 是一个流动性ERC20的Token

esRNT: 一个质押token, 虽然也是ERC20, 但是性质不一样不会在市面上流动, 只会在stakepool流动, 去兑换RNT的逻辑

锁仓性: 不能直接转让或兑换
当esRNT被兑换的时候, 兑换RNT并且burn掉
