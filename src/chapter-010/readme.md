<!--
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-26 11:46:55
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-27 15:57:53
 * @FilePath: /OpenSpace/src/chapter-010/readme.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# ERC20 支付方式（允许第三方消费我的 Token）

1. Transfer
2. Approve + TransferFrom
3. Transfer + Callback
4. Signature + TransferFrom

# EIP712 和 ERC20Premit
1. 用户线下离线生成签名 数据提交到链上做校验
2. 都使用 ecrecover 和 ECDSA.recover 恢复签名地址
3. 链下签名、链上验证：这两种方法都避免了用户在链上直接发起交易生成授权，从而减少了链上交互，节省了 gas 费用。

# 问题
1. permit 从代码层面看起来虽然合并了两次链上交易 但是并不节省 GAS
2. eip712 结构化签名为什么要设计成这样 解决了什么问题
3. TokenBank 中的 transferFrom 未生效 未报错

# 参考地址
1. https://github.com/cunmao-Jazz/foundry-project/blob/main/first-foundry/src/NFTmarket/NFTmerketpermit.sol