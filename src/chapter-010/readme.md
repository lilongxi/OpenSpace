<!--
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-26 11:46:55
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-26 11:47:53
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
