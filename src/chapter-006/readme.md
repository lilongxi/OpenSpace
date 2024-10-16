<!--
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-16 09:36:16
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-16 09:38:25
 * @FilePath: /OpenSpace/src/chapter-006/readme.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# ERC20
1. 转帐无法携带额外信息
2. 没有转帐回调（依赖授权、误入合约锁死）

# ERC777
1. send(dest, value, data)
2. 防止误入合约被锁死
3. 普通地址实现回调
4. 全局注册合约表（ERC1820）注册回调监听